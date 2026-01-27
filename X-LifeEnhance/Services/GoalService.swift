//
//  GoalService.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

class GoalService {
    private let goalsKey = "SavedGoals"
    
    func saveGoals(_ goals: [Goal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
    
    func loadGoals() -> [Goal] {
        guard let data = UserDefaults.standard.data(forKey: goalsKey),
              let goals = try? JSONDecoder().decode([Goal].self, from: data) else {
            return []
        }
        return goals
    }
    
    func deleteAllGoals() {
        UserDefaults.standard.removeObject(forKey: goalsKey)
    }
    
    func createSampleGoals() -> [Goal] {
        let calendar = Calendar.current
        let threeMonthsLater = calendar.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        
        return [
            Goal(
                title: "Run a 5K",
                description: "Complete a 5K race in under 30 minutes",
                category: .fitness,
                targetDate: threeMonthsLater,
                steps: [
                    GoalStep(title: "Week 1-2: Run 1 mile 3x/week"),
                    GoalStep(title: "Week 3-4: Run 2 miles 3x/week"),
                    GoalStep(title: "Week 5-6: Run 3 miles 3x/week"),
                    GoalStep(title: "Week 7-8: Run full 5K"),
                    GoalStep(title: "Week 9-12: Improve time")
                ]
            ),
            Goal(
                title: "Learn Photography",
                description: "Master basic photography techniques",
                category: .creativity,
                targetDate: threeMonthsLater,
                steps: [
                    GoalStep(title: "Study composition basics"),
                    GoalStep(title: "Practice daily for 30 days"),
                    GoalStep(title: "Take an online course"),
                    GoalStep(title: "Create a portfolio")
                ]
            )
        ]
    }
}
