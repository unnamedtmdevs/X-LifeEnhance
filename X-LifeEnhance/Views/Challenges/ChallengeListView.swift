//
//  ChallengeListView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct ChallengeListView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    @State private var selectedChallenge: Challenge?
    @State private var showingJoinedOnly = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter picker
                    Picker("Filter", selection: $showingJoinedOnly) {
                        Text("All Challenges").tag(false)
                        Text("My Challenges").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(displayedChallenges) { challenge in
                                ChallengeCardView(challenge: challenge)
                                    .onTapGesture {
                                        selectedChallenge = challenge
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeDetailView(challenge: challenge, viewModel: viewModel)
            }
        }
    }
    
    private var displayedChallenges: [Challenge] {
        if showingJoinedOnly {
            return viewModel.joinedChallenges
        } else {
            return viewModel.challenges
        }
    }
}

struct ChallengeCardView: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: challenge.category.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(challenge.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                if challenge.isJoined {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.appSecondary)
                }
            }
            
            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
            
            HStack {
                Label("\(challenge.participants)", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Label("\(challenge.daysRemaining) days left", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Progress bar (if joined)
            if challenge.isJoined {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Your Progress")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(challenge.userProgress)/\(challenge.goal)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.appSecondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * challenge.progressPercentage, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .background(
            challenge.isJoined ?
            LinearGradient(
                gradient: Gradient(colors: [Color.appPrimary.opacity(0.2), Color.appSecondary.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.05), Color.white.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}
