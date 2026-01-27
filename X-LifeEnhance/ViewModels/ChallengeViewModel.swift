//
//  ChallengeViewModel.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import Foundation
import SwiftUI
import Combine

class ChallengeViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    private let challengeService = ChallengeService()
    
    init() {
        loadChallenges()
    }
    
    func loadChallenges() {
        challenges = challengeService.loadChallenges()
    }
    
    func joinChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].isJoined = true
            challenges[index].participants += 1
            saveChallenges()
        }
    }
    
    func leaveChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].isJoined = false
            challenges[index].participants -= 1
            saveChallenges()
        }
    }
    
    func updateProgress(for challenge: Challenge, progress: Int) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].userProgress = progress
            saveChallenges()
        }
    }
    
    func incrementProgress(for challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].userProgress += 1
            saveChallenges()
        }
    }
    
    var joinedChallenges: [Challenge] {
        challenges.filter { $0.isJoined }
    }
    
    var availableChallenges: [Challenge] {
        challenges.filter { !$0.isJoined }
    }
    
    private func saveChallenges() {
        challengeService.saveChallenges(challenges)
    }
    
    func deleteAll() {
        challenges = challengeService.createSampleChallenges()
        challengeService.deleteAllChallenges()
    }
}
