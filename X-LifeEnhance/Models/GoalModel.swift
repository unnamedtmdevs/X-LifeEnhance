//
//  GoalModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

struct Goal: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var category: GoalCategory
    var targetDate: Date
    var steps: [GoalStep]
    var progress: Double
    var createdDate: Date
    
    init(id: UUID = UUID(), title: String, description: String, category: GoalCategory, targetDate: Date, steps: [GoalStep] = [], progress: Double = 0.0, createdDate: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.targetDate = targetDate
        self.steps = steps
        self.progress = progress
        self.createdDate = createdDate
    }
    
    mutating func updateProgress() {
        let completedSteps = steps.filter { $0.isCompleted }.count
        progress = steps.isEmpty ? 0 : Double(completedSteps) / Double(steps.count)
    }
}

struct GoalStep: Identifiable, Codable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

enum GoalCategory: String, Codable, CaseIterable {
    case fitness = "Fitness"
    case mindfulness = "Mindfulness"
    case creativity = "Creativity"
    case career = "Career"
    case learning = "Learning"
    case relationships = "Relationships"
    
    var icon: String {
        switch self {
        case .fitness: return "figure.run"
        case .mindfulness: return "brain.head.profile"
        case .creativity: return "paintpalette"
        case .career: return "briefcase"
        case .learning: return "book"
        case .relationships: return "person.2"
        }
    }
}
