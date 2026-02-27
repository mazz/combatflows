//
//  CombatFlowsUniApp.swift
//  CombatFlowsUni
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI

@main
struct CombatFlowsUniApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var storeManager = StoreManager()
    
    // Check if user has already accepted
    @AppStorage("hasAcceptedDisclaimer") var hasAcceptedDisclaimer: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(storeManager)
                // Show modal if not accepted
                .fullScreenCover(isPresented: .init(
                    get: { !hasAcceptedDisclaimer },
                    set: { _ in } // Managed by the modal's internal state
                )) {
                    DisclaimerModalView()
                }
        }
    }
}
