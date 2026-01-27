//
//  MainTabView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var goalViewModel = GoalViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @StateObject private var motivationViewModel = MotivationViewModel()
    
    var body: some View {
        TabView {
            HabitListView()
                .environmentObject(habitViewModel)
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }
            
            GoalListView()
                .environmentObject(goalViewModel)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
            
            ChallengeListView()
                .environmentObject(challengeViewModel)
                .tabItem {
                    Label("Challenges", systemImage: "flame.fill")
                }
            
            MotivationView()
                .environmentObject(motivationViewModel)
                .tabItem {
                    Label("Inspire", systemImage: "sparkles")
                }
            
            SettingsView()
                .environmentObject(habitViewModel)
                .environmentObject(goalViewModel)
                .environmentObject(challengeViewModel)
                .environmentObject(motivationViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.appPrimary)
    }
}
