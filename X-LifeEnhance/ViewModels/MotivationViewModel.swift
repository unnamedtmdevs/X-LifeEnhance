//
//  MotivationViewModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation
import SwiftUI
import Combine

class MotivationViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var articles: [Article] = []
    @Published var quoteOfTheDay: Quote?
    
    private let motivationService = MotivationService()
    
    init() {
        loadContent()
    }
    
    func loadContent() {
        quotes = motivationService.loadQuotes()
        articles = motivationService.loadArticles()
        quoteOfTheDay = motivationService.getQuoteOfTheDay()
    }
    
    func refreshContent() {
        // Simulate background refresh by rotating content
        loadContent()
    }
    
    func deleteAll() {
        quotes = []
        articles = []
        quoteOfTheDay = nil
        motivationService.deleteAllMotivation()
    }
}
