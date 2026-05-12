//
//  Group_14App.swift
//  Group-14
//
//  Created by Medha Kuchimanchi on 5/11/26.
//

import SwiftUI

@main
struct Group_14App: App {
    @AppStorage("userId")   private var userId:   String = ""
    @AppStorage("userRole") private var userRole: String = ""

    var body: some Scene {
        WindowGroup {
            // Root gate: until the user has both a role and an id we show
            // the Welcome flow (sign-up learner / sign-up mentor / log in).
            // Once both are set, we hand them to the main tab app.
            if userRole.isEmpty || userId.isEmpty {
                WelcomeView()
            } else {
                MainTabView()
            }
        }
    }
}
