//
//  HabitViewModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation
import SwiftUI
import Combine

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    private let habitService = HabitService()
    
    init() {
        loadHabits()
    }
    
    func loadHabits() {
        habits = habitService.loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habits[index]
            
            if updatedHabit.isCompletedToday() {
                // Remove today's completion
                updatedHabit.completedDates.removeAll { Calendar.current.isDateInToday($0) }
            } else {
                // Add today's completion
                updatedHabit.completedDates.append(Date())
            }
            
            habits[index] = updatedHabit
            saveHabits()
        }
    }
    
    func getCompletionData(for habit: Habit, days: Int) -> [HabitCompletion] {
        let calendar = Calendar.current
        var completions: [HabitCompletion] = []
        
        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let count = habit.completedDates.filter { calendar.isDate($0, inSameDayAs: date) }.count
            completions.append(HabitCompletion(date: date, count: count > 0 ? 1 : 0))
        }
        
        return completions.reversed()
    }
    
    private func saveHabits() {
        habitService.saveHabits(habits)
    }
    
    func deleteAll() {
        habits = []
        habitService.deleteAllHabits()
    }
}
