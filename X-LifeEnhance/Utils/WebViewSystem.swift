//
//  WebViewSystem.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI
import Combine
import WebKit

struct WebSystem: View {
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea(.all)
            
            WControllerRepresentable()
        }
    }
}

class WController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @AppStorage("first_open") var firstOpen: Bool = true
    @AppStorage("silka") var silka: String = ""
    
    @Published var url_link: URL = URL(string: "https://google.com")!
    
    var webView = WKWebView()
    var loadCheckTimer: Timer?
    var isPageLoadedSuccessfully = false
    
    // Защита от спама алертов и диплинков
    private var lastAlertTime: Date = Date.distantPast
    private var lastAlertScheme: String = ""
    private let alertCooldownInterval: TimeInterval = 5.0 // 5 секунд между алертами
    
    // Защита от повторных попыток открытия диплинков
    private var lastDeeplinkAttempt: [String: Date] = [:]
    private let deeplinkCooldownInterval: TimeInterval = 2.0 // 2 секунды между попытками
    
    // Защита от слишком частых алертов
    private var alertCount: Int = 0
    private var alertCountResetTime: Date = Date()
    private let maxAlertsPerMinute: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        getRequest()
    }
    
    private func setupKeyboardObservers() {
        // Подписываемся на уведомления о клавиатуре
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Ничего не делаем - позволяем клавиатуре просто появиться поверх WebView
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // Ничего не делаем - позволяем клавиатуре просто исчезнуть
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getRequest() {
        
        guard let url = URL(string: DataManagers().server) else { return }
        self.url_link = url
        self.getInfo()
    }
    
    private func getInfo() {
        var request: URLRequest?
        
        if silka == "about:blank" || silka.isEmpty {
            request = URLRequest(url: self.url_link)
        } else {
            if let currentURL = URL(string: silka) {
                request = URLRequest(url: currentURL)
            }
        }
        
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        request?.allHTTPHeaderFields = headers
        
        DispatchQueue.main.async {
            self.setupWebView()
        }
    }
    
    private func setupWebView() {
        let urlString = silka.isEmpty ? url_link.absoluteString : silka
        
        // Создаем конфигурацию WebView с настройками для обхода детекции
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Полная поддержка мультимедиа для казино и слотов
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Поддержка WebRTC для видео/аудио чатов
        if #available(iOS 14.3, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        // Разрешаем автовоспроизведение для казино игр
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Отключаем автоматический скролл к полям ввода
        config.suppressesIncrementalRendering = false
        
        // Настройки для современных версий iOS
        if #available(iOS 13.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        if #available(iOS 14.0, *) {
            config.limitsNavigationsToAppBoundDomains = false
        }
        
        // Дополнительные настройки для лучшей совместимости
        if #available(iOS 15.0, *) {
            config.upgradeKnownHostsToHTTPS = false
        }
        
        // Настройки для HTML5 и WebRTC
        setupHTML5AndWebRTCSupport(config)
        
        // Безопасная настройка приватных ключей для старых версий iOS
        configureLegacyWebViewSettings(config)
        
        // Создаем новый WebView с правильной конфигурацией
        webView = WKWebView(frame: .zero, configuration: config)
        
        view.backgroundColor = .black
        view.addSubview(webView)
        
        // scrollview settings
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.contentInset = .zero
        webView.scrollView.scrollIndicatorInsets = .zero
        
        // Отключаем автоматическое изменение contentInset при появлении клавиатуры
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // remove space at bottom when scrolldown
        if #available(iOS 11.0, *) {
            let insets = view.safeAreaInsets
            webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -insets.bottom, right: 0)
            webView.scrollView.scrollIndicatorInsets = webView.scrollView.contentInset
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        // Настройка User-Agent как у реального iPhone Safari
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // Дополнительные настройки для мультимедиа и казино игр
        // (scrollView настройки уже установлены выше)
        
        loadCookie()
        
        // Check if the current URL matches the landing_request URL
        if urlString == url_link.absoluteString {
            
            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            // Добавляем заголовки для обхода anti-bot защиты
            addBrowserHeaders(to: &request)

            webView.load(request)
        } else {
            print("DEFAULT TO: \(urlString)")
            // Load the web view without the POST request if the URL does not match
            if let requestURL = URL(string: urlString) {
                var request = URLRequest(url: requestURL)
                
                // Добавляем заголовки для обхода anti-bot защиты
                addBrowserHeaders(to: &request)
                
                webView.load(request)
            }
        }
    }
    
    // Функция для добавления заголовков браузера
    private func addBrowserHeaders(to request: inout URLRequest) {
        
        // Заголовки как у реального Safari на iPhone
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("1", forHTTPHeaderField: "DNT")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("?1", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("?1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        // Добавляем Referer если есть предыдущая страница
        if let currentURL = webView.url {
            request.setValue(currentURL.absoluteString, forHTTPHeaderField: "Referer")
        }
    }
    
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        completionHandler(nil)
    }
    
    // Обработка создания новых окон (popup)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        print("🪟 Creating popup sheet for: \(url.absoluteString)")
        
        // Создаем новый WebView для popup
        let popupWebView = WKWebView(frame: .zero, configuration: configuration)
        popupWebView.navigationDelegate = self
        popupWebView.uiDelegate = self
        popupWebView.backgroundColor = .white
        popupWebView.translatesAutoresizingMaskIntoConstraints = false
        
        // Создаем контейнер для sheet
        let sheetContainer = UIView()
        sheetContainer.backgroundColor = .white
        sheetContainer.layer.cornerRadius = 16
        sheetContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetContainer.layer.shadowColor = UIColor.black.cgColor
        sheetContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        sheetContainer.layer.shadowOpacity = 0.3
        sheetContainer.layer.shadowRadius = 10
        sheetContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем затемненный фон
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем элементы на экран
        view.addSubview(backgroundView)
        view.addSubview(sheetContainer)
        sheetContainer.addSubview(popupWebView)
        
        // Настраиваем constraints
        NSLayoutConstraint.activate([
            // Фон на весь экран
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            // Sheet занимает 80% высоты экрана снизу
            sheetContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sheetContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            sheetContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            sheetContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            
            // WebView внутри sheet с отступами
            popupWebView.topAnchor.constraint(equalTo: sheetContainer.topAnchor, constant: 50),
            popupWebView.bottomAnchor.constraint(equalTo: sheetContainer.safeAreaLayoutGuide.bottomAnchor),
            popupWebView.leftAnchor.constraint(equalTo: sheetContainer.leftAnchor),
            popupWebView.rightAnchor.constraint(equalTo: sheetContainer.rightAnchor)
        ])
        
        // Анимация появления sheet снизу
        sheetContainer.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        backgroundView.alpha = 0.0
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            sheetContainer.transform = .identity
            backgroundView.alpha = 1.0
        }
        
        // Добавляем кнопку закрытия и handle
        addCloseButtonToSheet(sheetContainer, popupWebView: popupWebView, backgroundView: backgroundView)
        addSheetHandle(sheetContainer)
        
        return popupWebView
    }
    
    // Добавляем кнопку закрытия для sheet
    private func addCloseButtonToSheet(_ sheetContainer: UIView, popupWebView: WKWebView, backgroundView: UIView) {
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        closeButton.setTitleColor(.gray, for: .normal)
        closeButton.backgroundColor = UIColor.systemGray5
        closeButton.layer.cornerRadius = 15
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        sheetContainer.addSubview(closeButton)
        
        // Позиционируем кнопку в правом верхнем углу sheet
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: sheetContainer.topAnchor, constant: 15),
            closeButton.rightAnchor.constraint(equalTo: sheetContainer.rightAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Добавляем действие для закрытия sheet
        closeButton.addTarget(self, action: #selector(closeSheet(_:)), for: .touchUpInside)
        
        // Сохраняем ссылки для закрытия
        closeButton.tag = popupWebView.hash
        
        // Добавляем жест для закрытия по тапу на фон
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeSheetByBackground(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        backgroundView.tag = popupWebView.hash
    }
    
    // Добавляем handle (полоску) для sheet
    private func addSheetHandle(_ sheetContainer: UIView) {
        
        let handle = UIView()
        handle.backgroundColor = UIColor.systemGray3
        handle.layer.cornerRadius = 2
        handle.translatesAutoresizingMaskIntoConstraints = false
        
        sheetContainer.addSubview(handle)
        
        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: sheetContainer.topAnchor, constant: 8),
            handle.centerXAnchor.constraint(equalTo: sheetContainer.centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 40),
            handle.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    // Закрытие sheet окна
    @objc private func closeSheet(_ sender: UIButton) {
        closeSheetWithAnimation(webViewHash: sender.tag)
    }
    
    // Закрытие sheet по тапу на фон
    @objc private func closeSheetByBackground(_ sender: UITapGestureRecognizer) {
        closeSheetWithAnimation(webViewHash: sender.view?.tag ?? 0)
    }
    
    // Анимированное закрытие sheet
    private func closeSheetWithAnimation(webViewHash: Int) {
        
        print("🪟 Closing sheet window")
        
        // Находим элементы sheet
        guard let sheetContainer = view.subviews.first(where: { subview in
            subview.subviews.contains { $0.hash == webViewHash }
        }) else {
            print("❌ Sheet container not found")
            return
        }
        
        let backgroundView = view.subviews.first { $0.backgroundColor == UIColor.black.withAlphaComponent(0.5) }
        
        // Анимация закрытия sheet вниз
        UIView.animate(withDuration: 0.3, animations: {
            sheetContainer.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            backgroundView?.alpha = 0.0
        }) { _ in
            sheetContainer.removeFromSuperview()
            backgroundView?.removeFromSuperview()
        }
    }
    
    // Обработка закрытия окна JavaScript'ом
    func webViewDidClose(_ webView: WKWebView) {
        
        print("🪟 WebView closed by JavaScript")
        
        // Если это popup (не основной WebView), закрываем sheet
        if webView != self.webView {
            closeSheetWithAnimation(webViewHash: webView.hash)
        }
    }
    
    // Обработка JavaScript алертов
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        
        if let topController = topViewController() {
            topController.present(alert, animated: true)
        } else {
            completionHandler()
        }
    }
    
    // Обработка JavaScript подтверждений
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "Подтверждение", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
            completionHandler(false)
        })
        
        if let topController = topViewController() {
            topController.present(alert, animated: true)
        } else {
            completionHandler(false)
        }
    }
    
    // Обработка запросов разрешений для WebRTC (камера/микрофон)
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        
        print("🎥 WebRTC permission request for: \(origin.host) - Type: \(type.rawValue)")
        
        // Автоматически разрешаем доступ к камере/микрофону для казино и игр
        decisionHandler(.grant)
    }
    
    // Обработчик диплинков - перехватываем все нестандартные схемы URL
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let urlString = url.absoluteString
        
        // Игнорируем пустые URL или специальные случаи
        if urlString.isEmpty || urlString == "about:blank" {
            decisionHandler(.allow)
            return
        }
        
        print("🔗 Navigation to: \(urlString)")
        
        // Проверяем, является ли это диплинком (не http/https)
        if let scheme = url.scheme?.lowercased() {
            
            // Разрешаем обычные веб-ссылки
            if scheme == "http" || scheme == "https" {
                decisionHandler(.allow)
                return
            }
            
            // Игнорируем служебные схемы WebView
            if scheme == "about" || scheme == "data" || scheme == "blob" || scheme == "javascript" || 
               scheme == "file" || scheme == "webkit-fake-url" {
                print("🔧 Allowing internal WebView scheme: \(scheme)")
                decisionHandler(.allow)
                return
            }
            
            // Специальная обработка для tel: и mailto: - открываем сразу без алерта
            if scheme == "tel" || scheme == "mailto" || scheme == "sms" {
                print("📞 Opening system URL: \(urlString)")
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            
            // Проверяем, не пытались ли мы недавно открыть этот же диплинк
            let currentTime = Date()
            if let lastAttempt = lastDeeplinkAttempt[urlString],
               currentTime.timeIntervalSince(lastAttempt) < deeplinkCooldownInterval {
                print("🚫 Deeplink cooldown active for: \(urlString)")
                decisionHandler(.cancel)
                return
            }
            
            // Записываем время попытки
            lastDeeplinkAttempt[urlString] = currentTime
            
            // Очищаем старые записи (старше 10 секунд)
            cleanupOldDeeplinkAttempts()
            
            // Для всех остальных схем (диплинки) пытаемся открыть в приложении
            print("🚀 Attempting to open deeplink: \(urlString)")
            print("📱 Scheme detected: \(scheme)")
            
            if UIApplication.shared.canOpenURL(url) {
                print("✅ App available for scheme: \(scheme)")
                UIApplication.shared.open(url, options: [:]) { success in
                    print(success ? "✅ Deeplink opened successfully" : "❌ Failed to open deeplink")
                }
            } else {
                print("❌ No app can handle deeplink: \(urlString)")
                
                // Показываем алерт только для "настоящих" диплинков, не для служебных схем
                if !isInternalScheme(scheme) {
                    // Более агрессивная защита от спама
                    let currentTime = Date()
                    if currentTime.timeIntervalSince(lastAlertTime) >= alertCooldownInterval && lastAlertScheme != scheme {
                        showDeeplinkAlert(for: scheme)
                    } else {
                        print("🚫 Skipping alert due to cooldown or same scheme")
                    }
                }
            }
            
            // Блокируем навигацию в WebView для диплинков
            decisionHandler(.cancel)
            return
        }
        
        // Разрешаем все остальные переходы
        decisionHandler(.allow)
    }
    
    // Проверяем, является ли схема служебной
    private func isInternalScheme(_ scheme: String) -> Bool {
        let internalSchemes = ["about", "data", "blob", "javascript", "file", "webkit-fake-url", "applewebdata"]
        return internalSchemes.contains(scheme.lowercased())
    }
    
    // Очищаем старые записи попыток открытия диплинков
    private func cleanupOldDeeplinkAttempts() {
        let currentTime = Date()
        let cleanupThreshold: TimeInterval = 10.0 // Удаляем записи старше 10 секунд
        
        lastDeeplinkAttempt = lastDeeplinkAttempt.filter { _, date in
            currentTime.timeIntervalSince(date) < cleanupThreshold
        }
    }
    
    // Настройка поддержки HTML5, WebRTC и мультимедиа
    private func setupHTML5AndWebRTCSupport(_ config: WKWebViewConfiguration) {
        
        // Настройки для полной поддержки HTML5
        let html5Keys = [
            "allowsInlineMediaPlayback": true,
            "mediaPlaybackRequiresUserAction": false,
            "mediaPlaybackAllowsAirPlay": true,
            "allowsPictureInPictureMediaPlayback": true
        ]
        
        // Применяем настройки безопасно
        for (key, value) in html5Keys {
            do {
                if config.preferences.responds(to: Selector(key)) {
                    config.preferences.setValue(value, forKey: key)
                    print("✅ HTML5 setting: \(key) = \(value)")
                }
            } catch {
                print("⚠️ HTML5 setting not supported: \(key)")
            }
        }
        
        // Настройки для WebRTC (камера/микрофон)
        if #available(iOS 15.0, *) {
            // Разрешаем доступ к камере и микрофону для WebRTC
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        print("🎮 HTML5, WebRTC and multimedia support configured")
    }
    
    // Безопасная настройка устаревших параметров WebView
    private func configureLegacyWebViewSettings(_ config: WKWebViewConfiguration) {
        
        // Список устаревших ключей, которые могут не поддерживаться
        let legacyKeys = [
            "allowFileAccessFromFileURLs",
            "allowUniversalAccessFromFileURLs"
        ]
        
        // Пытаемся установить каждый ключ безопасно
        for key in legacyKeys {
            do {
                // Проверяем, поддерживается ли ключ
                if config.preferences.responds(to: Selector(key)) {
                    config.preferences.setValue(true, forKey: key)
                    print("✅ Set legacy key: \(key)")
                }
            } catch {
                print("⚠️ Legacy key not supported: \(key)")
            }
        }
    }
    
    // Показываем алерт, если приложение для диплинка не установлено
    private func showDeeplinkAlert(for scheme: String) {
        
        let currentTime = Date()
        
        // Сбрасываем счетчик алертов каждую минуту
        if currentTime.timeIntervalSince(alertCountResetTime) > 60.0 {
            alertCount = 0
            alertCountResetTime = currentTime
        }
        
        // Проверяем лимит алертов
        if alertCount >= maxAlertsPerMinute {
            print("🚫 Alert limit reached (\(maxAlertsPerMinute) per minute)")
            return
        }
        
        // Проверяем, не показывали ли мы недавно алерт для этой же схемы
        if currentTime.timeIntervalSince(lastAlertTime) < alertCooldownInterval && lastAlertScheme == scheme {
            print("🚫 Alert cooldown active for scheme: \(scheme)")
            return
        }
        
        // Обновляем время последнего алерта и счетчик
        lastAlertTime = currentTime
        lastAlertScheme = scheme
        alertCount += 1
        
        DispatchQueue.main.async {
            
            // Проверяем, нет ли уже показанного алерта
            if let topController = self.topViewController(),
               topController.presentedViewController is UIAlertController {
                print("🚫 Alert already showing, skipping")
                return
            }
            
            let alert = UIAlertController(
                title: "Приложение не найдено",
                message: "Для открытия этой ссылки требуется установить соответствующее приложение.",
                preferredStyle: .alert
            )
            
            // Кнопка для перехода в App Store (опционально)
            alert.addAction(UIAlertAction(title: "App Store", style: .default) { _ in
                self.openAppStore(for: scheme)
            })
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            
            // Находим текущий контроллер для показа алерта
            if let topController = self.topViewController() {
                topController.present(alert, animated: true)
            }
        }
    }
    
    // Открываем App Store для популярных приложений
    private func openAppStore(for scheme: String) {
        
        var appStoreURL: String?
        
        // Популярные диплинки и их App Store ID
        switch scheme {
        case "tg", "telegram":
            appStoreURL = "https://apps.apple.com/app/telegram-messenger/id686449807"
        case "sberbank":
            appStoreURL = "https://apps.apple.com/app/sberbank/id492224193"
        case "tinkoff":
            appStoreURL = "https://apps.apple.com/app/tinkoff/id298813222"
        case "alfabank":
            appStoreURL = "https://apps.apple.com/app/alfa-bank/id1067895403"
        case "whatsapp":
            appStoreURL = "https://apps.apple.com/app/whatsapp-messenger/id310633997"
        case "viber":
            appStoreURL = "https://apps.apple.com/app/viber-messenger/id382617920"
        default:
            // Для неизвестных схем просто открываем App Store
            appStoreURL = "https://apps.apple.com"
        }
        
        if let urlString = appStoreURL, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // Находим верхний контроллер для показа алертов
    private func topViewController() -> UIViewController? {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var topController = window.rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
        loadCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            if let strongSelf = self, !strongSelf.isPageLoadedSuccessfully {
                print("Страница не загрузилась в течение 5 секунд.")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isPageLoadedSuccessfully = true
        loadCheckTimer?.invalidate()
        
        if let currentURL = webView.url?.absoluteString, currentURL != url_link.absoluteString {
            silka = currentURL
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isPageLoadedSuccessfully = false
        loadCheckTimer?.invalidate()
    }
    
    func saveCookie() {
        let cookieJar = HTTPCookieStorage.shared
        
        if let cookies = cookieJar.cookies {
            let data = NSKeyedArchiver.archivedData(withRootObject: cookies)
            UserDefaults.standard.set(data, forKey: "cookie")
        }
    }
    
    func loadCookie() {
        let ud = UserDefaults.standard
        
        if let data = ud.object(forKey: "cookie") as? Data, let cookies = NSKeyedUnarchiver.unarchiveObject(with: data) as? [HTTPCookie] {
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

struct WControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = WController
    
    func makeUIViewController(context: Context) -> WController {
        return WController()
    }
    
    func updateUIViewController(_ uiViewController: WController, context: Context) {}
}

// SSL Delegate для обработки сертификатов
class SSLDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Принимаем любые сертификаты (только для разработки!)
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

// Класс для отключения автоматических редиректов
class RedirectHandler: NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        print("🔄 Redirect blocked: \(response.statusCode) -> \(request.url?.absoluteString ?? "unknown")")
        
        // Возвращаем nil, чтобы НЕ следовать редиректу
        completionHandler(nil)
    }
}
