//
//  PHASEShowcaseApp.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 09/01/2025.
//

import SwiftUI

@main
struct PHASEShowcaseApp: App {
    @StateObject private var phaseAudioController = PHASEAudioController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(phaseAudioController)
        }
    }
}
