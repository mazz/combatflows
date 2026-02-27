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
    
    var body: some Scene {
        WindowGroup {
            // Remove the (storeManager: storeManager) parameter
            ContentView()
                .environment(storeManager)
        }
    }
}
