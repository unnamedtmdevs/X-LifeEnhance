//
//  ChallengeDetailView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct ChallengeDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    
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
                                
                                Image(systemName: challenge.category.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            Text(challenge.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(challenge.description)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Stats
                        HStack(spacing: 20) {
                            StatBox(
                                icon: "person.2.fill",
                                value: "\(challenge.participants)",
                                label: "Participants"
                            )
                            
                            StatBox(
                                icon: "clock.fill",
                                value: "\(challenge.daysRemaining)",
                                label: "Days Left"
                            )
                            
                            StatBox(
                                icon: "target",
                                value: "\(challenge.goal)",
                                label: "Goal"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Progress (if joined)
                        if challenge.isJoined {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Progress")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Text("\(challenge.userProgress) / \(challenge.goal)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("\(Int(challenge.progressPercentage * 100))%")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.appSecondary)
                                        
                                        Text("Complete")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                
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
                                            .frame(width: geometry.size.width * challenge.progressPercentage, height: 16)
                                    }
                                }
                                .frame(height: 16)
                                
                                Button(action: {
                                    viewModel.incrementProgress(for: challenge)
                                }) {
                                    Text("Log Progress (+1)")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                }
                                .disabled(challenge.userProgress >= challenge.goal)
                                .opacity(challenge.userProgress >= challenge.goal ? 0.5 : 1.0)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Join/Leave button
                        Button(action: {
                            if challenge.isJoined {
                                viewModel.leaveChallenge(challenge)
                            } else {
                                viewModel.joinChallenge(challenge)
                            }
                        }) {
                            Text(challenge.isJoined ? "Leave Challenge" : "Join Challenge")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    Group {
                                        if challenge.isJoined {
                                            Color.red.opacity(0.8)
                                        } else {
                                            LinearGradient(
                                                gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        }
                                    }
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Challenge Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.appPrimary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
