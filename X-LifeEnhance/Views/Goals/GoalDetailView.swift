//
//  GoalDetailView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct GoalDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let goal: Goal
    @ObservedObject var viewModel: GoalViewModel
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: goal.category.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            Text(goal.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(goal.description)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text("\(Int(goal.progress * 100))%")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appSecondary)
                                    Text("Complete")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                    .frame(height: 40)
                                
                                VStack {
                                    Text(daysRemaining(for: goal.targetDate))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Remaining")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding()
                        }
                        .padding(.top)
                        
                        // Progress bar
                        VStack(alignment: .leading, spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 16)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * goal.progress, height: 16)
                                }
                            }
                            .frame(height: 16)
                        }
                        .padding(.horizontal)
                        
                        // Steps
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Steps to Achieve")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(goal.steps) { step in
                                StepRow(
                                    step: step,
                                    onToggle: {
                                        viewModel.toggleStepCompletion(goalId: goal.id, stepId: step.id)
                                    }
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Delete button
                        Button(action: { showingDeleteAlert = true }) {
                            Text("Delete Goal")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Goal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Goal"),
                    message: Text("Are you sure you want to delete this goal?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteGoal(goal)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func daysRemaining(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        let days = components.day ?? 0
        
        if days < 0 {
            return "Overdue"
        } else if days == 0 {
            return "Today"
        } else {
            return "\(days) days"
        }
    }
}

struct StepRow: View {
    let step: GoalStep
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(step.isCompleted ? .appSecondary : .white.opacity(0.3))
            }
            
            Text(step.title)
                .foregroundColor(.white)
                .strikethrough(step.isCompleted)
                .opacity(step.isCompleted ? 0.6 : 1.0)
            
            Spacer()
        }
    }
}
