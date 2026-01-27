//
//  SettingsView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @EnvironmentObject var goalViewModel: GoalViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @EnvironmentObject var motivationViewModel: MotivationViewModel
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    
    @State private var showingDeleteAlert = false
    @State private var showingResetOnboardingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile section
                        profileSection
                        
                        // Preferences
                        preferencesSection
                        
                        // Data management
                        dataSection
                        
                        // About
                        aboutSection
                        
                        // Version
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
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
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            Text("X:LifeEnhance User")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Building better habits every day")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    color: .appPrimary
                ) {
                    Toggle("", isOn: $enableNotifications)
                        .labelsHidden()
                        .tint(.appPrimary)
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    color: .appSecondary
                ) {
                    Toggle("", isOn: $darkModeEnabled)
                        .labelsHidden()
                        .tint(.appPrimary)
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Data Management")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                Button(action: {
                    showingResetOnboardingAlert = true
                }) {
                    SettingsRow(
                        icon: "arrow.clockwise",
                        title: "Reset Onboarding",
                        color: .appPrimary
                    ) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 60)
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    SettingsRow(
                        icon: "trash.fill",
                        title: "Delete Account",
                        color: .red
                    ) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("This will reset all your data and return the app to its initial state. This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAccount()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("About")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "About X:LifeEnhance",
                    color: .appPrimary
                ) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "Privacy Policy",
                    color: .appSecondary
                ) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 60)
                
                SettingsRow(
                    icon: "checkmark.seal.fill",
                    title: "Terms of Service",
                    color: .appAccent
                ) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .alert(isPresented: $showingResetOnboardingAlert) {
            Alert(
                title: Text("Reset Onboarding"),
                message: Text("This will show the onboarding screens again the next time you launch the app."),
                primaryButton: .default(Text("Reset")) {
                    hasCompletedOnboarding = false
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func deleteAccount() {
        // Reset all data
        habitViewModel.deleteAll()
        goalViewModel.deleteAll()
        challengeViewModel.deleteAll()
        motivationViewModel.deleteAll()
        
        // Reset onboarding
        hasCompletedOnboarding = false
        
        // Reset preferences
        enableNotifications = true
        darkModeEnabled = true
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            content()
        }
        .padding()
    }
}
