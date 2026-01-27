//
//  MotivationService.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

class MotivationService {
    private let quotesKey = "SavedQuotes"
    private let articlesKey = "SavedArticles"
    private let lastRefreshKey = "LastMotivationRefresh"
    
    func getQuoteOfTheDay() -> Quote {
        let quotes = loadQuotes()
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % quotes.count
        return quotes[index]
    }
    
    func loadQuotes() -> [Quote] {
        guard let data = UserDefaults.standard.data(forKey: quotesKey),
              let quotes = try? JSONDecoder().decode([Quote].self, from: data) else {
            return createSampleQuotes()
        }
        return quotes
    }
    
    func loadArticles() -> [Article] {
        guard let data = UserDefaults.standard.data(forKey: articlesKey),
              let articles = try? JSONDecoder().decode([Article].self, from: data) else {
            return createSampleArticles()
        }
        return articles
    }
    
    func saveQuotes(_ quotes: [Quote]) {
        if let encoded = try? JSONEncoder().encode(quotes) {
            UserDefaults.standard.set(encoded, forKey: quotesKey)
        }
    }
    
    func saveArticles(_ articles: [Article]) {
        if let encoded = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(encoded, forKey: articlesKey)
        }
    }
    
    func deleteAllMotivation() {
        UserDefaults.standard.removeObject(forKey: quotesKey)
        UserDefaults.standard.removeObject(forKey: articlesKey)
        UserDefaults.standard.removeObject(forKey: lastRefreshKey)
    }
    
    func createSampleQuotes() -> [Quote] {
        return [
            Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: "Inspiration"),
            Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill", category: "Motivation"),
            Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", category: "Confidence"),
            Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt", category: "Dreams"),
            Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", category: "Persistence"),
            Quote(text: "Everything you've ever wanted is on the other side of fear.", author: "George Addair", category: "Courage"),
            Quote(text: "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine.", author: "Roy T. Bennett", category: "Self-Belief"),
            Quote(text: "I learned that courage was not the absence of fear, but the triumph over it.", author: "Nelson Mandela", category: "Courage"),
            Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins", category: "Action"),
            Quote(text: "Your limitation—it's only your imagination.", author: "Unknown", category: "Mindset"),
            Quote(text: "Great things never come from comfort zones.", author: "Unknown", category: "Growth"),
            Quote(text: "Dream it. Wish it. Do it.", author: "Unknown", category: "Action"),
            Quote(text: "Success doesn't just find you. You have to go out and get it.", author: "Unknown", category: "Success"),
            Quote(text: "The harder you work for something, the greater you'll feel when you achieve it.", author: "Unknown", category: "Achievement"),
            Quote(text: "Dream bigger. Do bigger.", author: "Unknown", category: "Ambition")
        ]
    }
    
    func createSampleArticles() -> [Article] {
        return [
            Article(
                title: "5 Morning Habits That Will Transform Your Life",
                content: "Starting your day with the right habits can set the tone for success. Here are five powerful morning habits:\n\n1. Wake up early: Give yourself time before the world demands your attention.\n\n2. Hydrate immediately: Drink a glass of water to kickstart your metabolism.\n\n3. Exercise: Even 10 minutes of movement energizes your body and mind.\n\n4. Practice gratitude: Write down three things you're grateful for.\n\n5. Plan your day: Set clear intentions and priorities.\n\nImplementing these habits consistently will lead to remarkable improvements in your productivity, mood, and overall well-being.",
                category: "Productivity",
                readTime: 3
            ),
            Article(
                title: "The Science of Building Unbreakable Habits",
                content: "Research shows that habits are formed through a loop of cue, routine, and reward. Understanding this cycle is key to building lasting habits.\n\nThe Habit Loop:\n- Cue: A trigger that initiates the behavior\n- Routine: The behavior itself\n- Reward: The benefit you gain\n\nTo build a new habit:\n1. Make it obvious (clear cue)\n2. Make it attractive (appealing reward)\n3. Make it easy (simple routine)\n4. Make it satisfying (immediate gratification)\n\nStudies indicate it takes an average of 66 days to form a new habit. Be patient with yourself and focus on consistency rather than perfection.",
                category: "Personal Growth",
                readTime: 5
            ),
            Article(
                title: "Mindfulness in the Digital Age",
                content: "In our hyper-connected world, mindfulness has become more important than ever. Here's how to stay present:\n\nDigital Detox: Schedule regular breaks from screens. Even 5 minutes away can reset your mind.\n\nMindful Breathing: Take three deep breaths before checking your phone or email.\n\nSingle-Tasking: Focus on one task at a time. Multitasking reduces productivity by up to 40%.\n\nMindful Eating: Put away devices during meals and savor each bite.\n\nEvening Routine: Create a tech-free hour before bed to improve sleep quality.\n\nPracticing mindfulness doesn't require hours of meditation. Small, consistent moments of presence throughout your day can dramatically improve your mental health and focus.",
                category: "Wellness",
                readTime: 4
            ),
            Article(
                title: "Goal Setting That Actually Works",
                content: "Most people set goals, but few achieve them. Here's a proven framework:\n\nSMART Goals:\n- Specific: Clearly define what you want\n- Measurable: Track your progress\n- Achievable: Set realistic targets\n- Relevant: Align with your values\n- Time-bound: Set a deadline\n\nBeyond SMART:\n1. Write it down: Goals written down are 42% more likely to be achieved\n2. Share it: Accountability increases success rates\n3. Break it down: Divide big goals into small, actionable steps\n4. Review regularly: Weekly check-ins keep you on track\n5. Celebrate milestones: Acknowledge progress to stay motivated\n\nRemember, the journey matters as much as the destination. Enjoy the process of becoming the person who achieves the goal.",
                category: "Success",
                readTime: 4
            )
        ]
    }
}
