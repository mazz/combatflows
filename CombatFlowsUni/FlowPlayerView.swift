//
//  FlowPlayerView.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//


import SwiftUI
import AVKit
import swiftui_loop_videoplayer

struct FlowPlayerView: View {
    let flow: Flow
    @State private var selectedLesson: Lesson?
    @State private var player: AVPlayer? // 1. Change to optional
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 2. Safely unwrap the player for the VideoPlayer view
            if let player = player {
                VideoPlayer(player: player)
                    .overlay(alignment: .topLeading) {
                        Button {
                            player.pause() // Stop audio before leaving
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 50)
                                .padding(.leading, 20)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .top)
            } else {
                // Background color while player initializes
                Color.black
                    .ignoresSafeArea()
                    .onAppear {
                        // 3. Initialize the player ONLY ONCE here
                        if player == nil {
                            player = AVPlayer()
                        }
                        selectedLesson = flow.lessons.first
                        playCurrentLesson()
                    }
            }
            
            // ... (Your Picker Code) ...
            Picker("Lesson Type", selection: $selectedLesson) {
                ForEach(flow.lessons, id: \.self) { lesson in
                    Text(lesson.type.rawValue.capitalized).tag(lesson as Lesson?)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .onChange(of: selectedLesson) { _ in
                playCurrentLesson()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.container, edges: .bottom)
        .onDisappear {
            player?.pause()
            player = nil // 4. Clean up the player entirely
        }
    }
    
    private func playCurrentLesson() {
        guard let filename = selectedLesson?.filename else { return }
        
        if let url = getLegacyVideoURL(for: filename) {
            let item = AVPlayerItem(url: url)
            // Use optional chaining
            player?.replaceCurrentItem(with: item)
            player?.play()
        }
    }
    
    func getLegacyVideoURL(for fileName: String) -> URL? {
        // 1. Check Bundle (for free content)
        if let bundleURL = Bundle.main.url(forResource: fileName, withExtension: nil) {
            return bundleURL
        }
        
        // 2. Check the legacy Documents path
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let legacyPath = documentsURL
                .appendingPathComponent("CombatMMA")
                .appendingPathComponent("combatflows")
                .appendingPathComponent("purchased_content")
                .appendingPathComponent(fileName)
            
            if fileManager.fileExists(atPath: legacyPath.path) {
                return legacyPath
            }
        }
        return nil
    }
}

struct LoopingThumbnailView: View {
    let fileName: String
    
    var body: some View {
        // Remove ONLY the extension, do NOT change casing
        let cleanName = fileName.replacingOccurrences(of: ".m4v", with: "")
                                .replacingOccurrences(of: ".mp4", with: "")
        
        ExtVideoPlayer {
            VideoSettings {
                SourceName(cleanName)
                Ext("m4v")
                Gravity(.resizeAspectFill)
                Loop()
                Mute()
            }
        }
        .onAppear {
            // Check your Xcode Console (Cmd + Shift + C)
            // If this prints the wrong name, that's why it's black.
//            print("🎬 Attempting to play: \(cleanName)")
        }
    }
}

