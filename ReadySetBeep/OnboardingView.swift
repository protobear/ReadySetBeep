//
//  OnboardingView.swift
//  ReadySetBeep
//
//  Created by Marnick De Grave on 03/11/2024.
//
import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Welcome to Ready, Set, Beep!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()

            Text("Create custom run/walk intervals with clear audio cues, all without interrupting your music.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: {
                showOnboarding = false
            }) {
                Text("Get Started")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}
