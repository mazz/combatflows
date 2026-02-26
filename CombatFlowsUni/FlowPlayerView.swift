//
//  FlowPlayerView.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//


import SwiftUI
import AVKit

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
        
        // Find the video in the app bundle
        let fileBase = (filename as NSString).deletingPathExtension
        let fileExt = (filename as NSString).pathExtension
        
        if let url = Bundle.main.url(forResource: fileBase, withExtension: fileExt) {
            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
            player.play()
        } else {
            print("Video not found: \(filename)")
        }
    }
}
