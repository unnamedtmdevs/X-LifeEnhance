//
//  QuoteModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

struct Quote: Identifiable, Codable {
    var id: UUID
    var text: String
    var author: String
    var category: String
    
    init(id: UUID = UUID(), text: String, author: String, category: String = "Motivation") {
        self.id = id
        self.text = text
        self.author = author
        self.category = category
    }
}

struct Article: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var category: String
    var readTime: Int
    var publishDate: Date
    
    init(id: UUID = UUID(), title: String, content: String, category: String, readTime: Int, publishDate: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.readTime = readTime
        self.publishDate = publishDate
    }
}
