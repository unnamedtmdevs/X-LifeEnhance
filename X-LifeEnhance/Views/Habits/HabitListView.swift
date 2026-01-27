//
//  HabitListView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if viewModel.habits.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Today's progress
                            todayProgressCard
                            
                            // Habits list
                            ForEach(viewModel.habits) { habit in
                                HabitCardView(habit: habit, onToggle: {
                                    viewModel.toggleHabitCompletion(habit)
                                }, onTap: {
                                    selectedHabit = habit
                                })
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit, viewModel: viewModel)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.appPrimary.opacity(0.5))
            
            Text("No Habits Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Start building better habits by\nadding your first one!")
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
            
            Button(action: { showingAddHabit = true }) {
                Text("Add Habit")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            .padding(.top)
        }
    }
    
    private var todayProgressCard: some View {
        let completedToday = viewModel.habits.filter { $0.isCompletedToday() }.count
        let totalHabits = viewModel.habits.count
        let progress = totalHabits > 0 ? Double(completedToday) / Double(totalHabits) : 0
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Today's Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completedToday) of \(totalHabits)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("habits completed")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appPrimary.opacity(0.3), Color.appSecondary.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct HabitCardView: View {
    let habit: Habit
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(habit.isCompletedToday() ? Color.appSecondary : Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Habit info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(habit.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Checkmark
            Button(action: onToggle) {
                Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(habit.isCompletedToday() ? .appSecondary : .white.opacity(0.3))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .onTapGesture {
            onTap()
        }
    }
}
