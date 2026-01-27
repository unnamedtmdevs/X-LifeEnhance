//
//  HabitService.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

class HabitService {
    private let habitsKey = "SavedHabits"
    
    func saveHabits(_ habits: [Habit]) {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
    }
    
    func loadHabits() -> [Habit] {
        guard let data = UserDefaults.standard.data(forKey: habitsKey),
              let habits = try? JSONDecoder().decode([Habit].self, from: data) else {
            return []
        }
        return habits
    }
    
    func deleteAllHabits() {
        UserDefaults.standard.removeObject(forKey: habitsKey)
    }
    
    func createSampleHabits() -> [Habit] {
        return [
            Habit(
                name: "Morning Meditation",
                description: "Start your day with 10 minutes of meditation",
                icon: "brain.head.profile",
                color: "Blue",
                frequency: .daily
            ),
            Habit(
                name: "Exercise",
                description: "30 minutes of physical activity",
                icon: "figure.run",
                color: "Green",
                frequency: .daily
            ),
            Habit(
                name: "Read",
                description: "Read for at least 20 minutes",
                icon: "book",
                color: "Orange",
                frequency: .daily
            )
        ]
    }
}
