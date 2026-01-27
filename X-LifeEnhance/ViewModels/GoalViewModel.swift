//
//  GoalViewModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation
import SwiftUI
import Combine

class GoalViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    private let goalService = GoalService()
    
    init() {
        loadGoals()
    }
    
    func loadGoals() {
        goals = goalService.loadGoals()
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func toggleStepCompletion(goalId: UUID, stepId: UUID) {
        if let goalIndex = goals.firstIndex(where: { $0.id == goalId }),
           let stepIndex = goals[goalIndex].steps.firstIndex(where: { $0.id == stepId }) {
            goals[goalIndex].steps[stepIndex].isCompleted.toggle()
            goals[goalIndex].updateProgress()
            saveGoals()
        }
    }
    
    private func saveGoals() {
        goalService.saveGoals(goals)
    }
    
    func deleteAll() {
        goals = []
        goalService.deleteAllGoals()
    }
}
