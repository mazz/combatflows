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
    @State private var player = AVPlayer()
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. The Native Video Player
            VideoPlayer(player: player)
                .onAppear {
                    // Default to the first lesson (usually Teaching or Application)
                    selectedLesson = flow.lessons.first
                    playCurrentLesson()
                }
                .onDisappear {
                    player.pause()
                }
            
            // 2. Lesson Switcher (Teaching / Application / Graphic Guide)
            Picker("Lesson Type", selection: $selectedLesson) {
                ForEach(flow.lessons, id: \.self) { lesson in
                    Text(lesson.type.rawValue.capitalized).tag(lesson as Lesson?)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedLesson) { _ in
                playCurrentLesson()
            }
        }
        .navigationTitle("Flow \(flow.nominal)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        // This ensures the video takes advantage of the full screen width on iPhone
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func playCurrentLesson() {
        guard let filename = selectedLesson?.filename else { return }
        
        // USE THE HELPER HERE
        if let url = getLegacyVideoURL(for: filename) {
            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
            player.play()
        } else {
            // This will now only print if it's missing from BOTH the bundle and Documents
            print("Video not found: \(filename)")
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

