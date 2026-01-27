//
//  ChallengeModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

struct Challenge: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var category: ChallengeCategory
    var startDate: Date
    var endDate: Date
    var participants: Int
    var goal: Int
    var userProgress: Int
    var isJoined: Bool
    
    init(id: UUID = UUID(), title: String, description: String, category: ChallengeCategory, startDate: Date, endDate: Date, participants: Int, goal: Int, userProgress: Int = 0, isJoined: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.participants = participants
        self.goal = goal
        self.userProgress = userProgress
        self.isJoined = isJoined
    }
    
    var progressPercentage: Double {
        guard goal > 0 else { return 0 }
        return min(Double(userProgress) / Double(goal), 1.0)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(components.day ?? 0, 0)
    }
}

enum ChallengeCategory: String, Codable, CaseIterable {
    case fitness = "Fitness"
    case wellness = "Wellness"
    case productivity = "Productivity"
    case learning = "Learning"
    
    var icon: String {
        switch self {
        case .fitness: return "flame"
        case .wellness: return "heart"
        case .productivity: return "target"
        case .learning: return "brain"
        }
    }
}
