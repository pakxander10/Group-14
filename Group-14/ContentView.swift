//
//  ContentView.swift
//  Group-14
//
//  Created by Medha Kuchimanchi on 5/11/26.
//

import SwiftUI

// NOTE: ContentView is preserved for Xcode compatibility.
// The app entry point (Group_14App.swift) now loads MainTabView directly.
// This file can be safely deleted once the project is fully migrated.

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
