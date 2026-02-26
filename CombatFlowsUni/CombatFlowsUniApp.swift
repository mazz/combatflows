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
    // Initialize both managers at the top level
    @StateObject private var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeManager)
            // We inject the manager so all child views (like LockedUpsellView)
            // can see the purchase states and products.
        }
    }
}
