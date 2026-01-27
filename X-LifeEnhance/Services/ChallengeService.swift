//
//  ChallengeService.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

class ChallengeService {
    private let challengesKey = "SavedChallenges"
    
    func saveChallenges(_ challenges: [Challenge]) {
        if let encoded = try? JSONEncoder().encode(challenges) {
            UserDefaults.standard.set(encoded, forKey: challengesKey)
        }
    }
    
    func loadChallenges() -> [Challenge] {
        guard let data = UserDefaults.standard.data(forKey: challengesKey),
              let challenges = try? JSONDecoder().decode([Challenge].self, from: data) else {
            return createSampleChallenges()
        }
        return challenges
    }
    
    func deleteAllChallenges() {
        UserDefaults.standard.removeObject(forKey: challengesKey)
    }
    
    func createSampleChallenges() -> [Challenge] {
        let calendar = Calendar.current
        let today = Date()
        let oneWeekLater = calendar.date(byAdding: .day, value: 7, to: today) ?? today
        let twoWeeksLater = calendar.date(byAdding: .day, value: 14, to: today) ?? today
        let oneMonthLater = calendar.date(byAdding: .month, value: 1, to: today) ?? today
        
        return [
            Challenge(
                title: "7-Day Meditation",
                description: "Meditate for at least 10 minutes every day for a week",
                category: .wellness,
                startDate: today,
                endDate: oneWeekLater,
                participants: 1247,
                goal: 7
            ),
            Challenge(
                title: "30-Day Fitness",
                description: "Complete 30 minutes of exercise daily for a month",
                category: .fitness,
                startDate: today,
                endDate: oneMonthLater,
                participants: 3542,
                goal: 30
            ),
            Challenge(
                title: "Read 5 Books",
                description: "Read 5 books in 2 weeks",
                category: .learning,
                startDate: today,
                endDate: twoWeeksLater,
                participants: 892,
                goal: 5
            ),
            Challenge(
                title: "Productivity Sprint",
                description: "Complete daily tasks on time for 14 days",
                category: .productivity,
                startDate: today,
                endDate: twoWeeksLater,
                participants: 2156,
                goal: 14
            )
        ]
    }
}
