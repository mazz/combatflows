//
//  AppDelegate.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//


import UIKit
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        configureAudioSession()
        
        return true
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // .playback allows audio to continue when the silent switch is on 
            // and when the screen locks (essential for workout tools).
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}
