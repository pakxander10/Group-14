//
//  Group_14App.swift
//  Group-14
//
//  Created by Medha Kuchimanchi on 5/11/26.
//

import SwiftUI

@main
struct Group_14App: App {
    @AppStorage("learnerId") private var learnerId: String = ""

    var body: some Scene {
        WindowGroup {
            // Root gate: onboarding screen until the learner has an id,
            // then the four-tab app. Signing out clears learnerId and
            // re-presents onboarding without any sheet/cover indirection.
            if learnerId.isEmpty {
                LearnerProfileCreationView { created in
                    learnerId = created.id
                }
            } else {
                MainTabView()
            }
        }
    }
}
