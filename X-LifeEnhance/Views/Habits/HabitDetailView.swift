//
//  HabitDetailView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct HabitDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel
    
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
                                
                                Image(systemName: habit.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            Text(habit.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(habit.description)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Stats
                        statsCard
                        
                        // Progress chart
                        progressChart
                        
                        // Delete button
                        Button(action: { showingDeleteAlert = true }) {
                            Text("Delete Habit")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Habit Details")
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
                    title: Text("Delete Habit"),
                    message: Text("Are you sure you want to delete this habit?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteHabit(habit)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private var statsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatItem(
                    title: "Current Streak",
                    value: "\(calculateStreak())",
                    unit: "days"
                )
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                StatItem(
                    title: "30-Day Rate",
                    value: "\(Int(habit.completionRate(for: 30) * 100))",
                    unit: "%"
                )
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                StatItem(
                    title: "Total",
                    value: "\(habit.completedDates.count)",
                    unit: "times"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var progressChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 7 Days")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.getCompletionData(for: habit, days: 7)) { completion in
                    VStack(spacing: 4) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(completion.count > 0 ? 
                                  LinearGradient(
                                    gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                  ) : 
                                  LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                  )
                            )
                            .frame(height: completion.count > 0 ? 60 : 20)
                        
                        // Day label
                        Text(dayLabel(for: completion.date))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .frame(height: 100)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            if habit.completedDates.contains(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
