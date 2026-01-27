//
//  AddGoalView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GoalViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = GoalCategory.fitness
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var steps: [String] = [""]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Title")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            TextField("e.g., Run a 5K", text: $title)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        // Description field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            TextField("What do you want to achieve?", text: $description)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        // Category picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(GoalCategory.allCases, id: \.self) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category,
                                            action: { selectedCategory = category }
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Target date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Date")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            DatePicker("", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .colorScheme(.dark)
                                .accentColor(.appPrimary)
                        }
                        
                        // Steps
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Steps to Achieve")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Button(action: addStep) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.appPrimary)
                                }
                            }
                            
                            ForEach(0..<steps.count, id: \.self) { index in
                                HStack {
                                    TextField("Step \(index + 1)", text: $steps[index])
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    
                                    if steps.count > 1 {
                                        Button(action: { removeStep(at: index) }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Create button
                        Button(action: createGoal) {
                            Text("Create Goal")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(title.isEmpty)
                        .opacity(title.isEmpty ? 0.5 : 1)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
        }
    }
    
    private func addStep() {
        steps.append("")
    }
    
    private func removeStep(at index: Int) {
        steps.remove(at: index)
    }
    
    private func createGoal() {
        let goalSteps = steps.filter { !$0.isEmpty }.map { GoalStep(title: $0) }
        
        let goal = Goal(
            title: title,
            description: description,
            category: selectedCategory,
            targetDate: targetDate,
            steps: goalSteps
        )
        
        viewModel.addGoal(goal)
        presentationMode.wrappedValue.dismiss()
    }
}

struct CategoryButton: View {
    let category: GoalCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.appPrimary : Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}
