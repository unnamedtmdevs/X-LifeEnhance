//
//  ContentView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    RootView()
}
