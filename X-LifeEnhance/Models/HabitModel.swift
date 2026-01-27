//
//  HabitModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation

struct Habit: Identifiable, Codable {
    var id: UUID
    var name: String
    var description: String
    var icon: String
    var color: String
    var frequency: HabitFrequency
    var reminderTime: Date?
    var createdDate: Date
    var completedDates: [Date]
    
    init(id: UUID = UUID(), name: String, description: String, icon: String, color: String, frequency: HabitFrequency, reminderTime: Date? = nil, createdDate: Date = Date(), completedDates: [Date] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.frequency = frequency
        self.reminderTime = reminderTime
        self.createdDate = createdDate
        self.completedDates = completedDates
    }
    
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return completedDates.contains { calendar.isDateInToday($0) }
    }
    
    func completionRate(for days: Int) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else { return 0 }
        
        let completedInRange = completedDates.filter { $0 >= startDate && $0 <= endDate }
        return Double(completedInRange.count) / Double(days)
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case custom = "Custom"
}

struct HabitCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
