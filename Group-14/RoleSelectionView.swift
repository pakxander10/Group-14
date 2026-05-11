//
//  RoleSelectionView.swift
//  Group-14
//
//  Created by Xander Pak on 5/11/26.
//

import SwiftUI

struct RoleSelectionView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("How are you joining Ascend?")
                    .font(.title)
                    .fontWeight(.bold)

                // Routes to YOUR code (Xander)
                NavigationLink(destination: LearnerOnboardingView(onComplete: {})) {
                    Text("I am a Learner")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Routes to YOUR PARTNER'S code
                NavigationLink(destination: MentorProfileView()) {
                    Text("I am a Mentor")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

