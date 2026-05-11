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
            MainTabView()
                .sheet(isPresented: Binding(
                    get: { learnerId.isEmpty },
                    set: { _ in }
                )) {
                    LearnerProfileCreationView { created in
                        learnerId = created.id
                    }
                    .interactiveDismissDisabled(true)
                }
        }
    }
}
