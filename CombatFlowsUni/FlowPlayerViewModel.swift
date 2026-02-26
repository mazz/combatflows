//
//  FlowPlayerViewModel.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//

import AVKit
import Foundation
import Observation

@Observable
class FlowPlayerViewModel {
    var flow: Flow
    var sortedLessons: [Lesson] = []
    var selectedLesson: Lesson?
    var player: AVPlayer = AVPlayer()
    
    // The "Playlist Task" that waits for the video to end
    private var playbackTask: Task<Void, Never>?

    init(flow: Flow) {
        self.flow = flow
        let order: [LessonPlaybackType: Int] = [.teaching: 0, .application: 1, .graphicGuide: 2]
        self.sortedLessons = flow.lessons.sorted {
            (order[$0.type] ?? 99) < (order[$1.type] ?? 99)
        }
        self.selectedLesson = sortedLessons.first
    }
    
    func playCurrent() {
        // 1. Cancel any previous "waiting for end" task immediately
        playbackTask?.cancel()
        
        guard let filename = selectedLesson?.filename,
              let url = getLegacyVideoURL(for: filename) else { return }
        
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()
        
        // 2. Start a new Async Task to wait for this specific item to finish
        playbackTask = Task { [weak self] in
            // Listen for the notification as an AsyncSequence
            let sequence = NotificationCenter.default.notifications(
                named: .AVPlayerItemDidPlayToEndTime,
                object: item // Filter strictly to THIS item
            )
            
            // Wait for the first notification (the end of the video)
            for await _ in sequence {
                // Check if task was cancelled while waiting (e.g., user tapped another tab)
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self?.advancePlaylist()
                }
                break // We only care about the first "end" event for this item
            }
        }
    }
    
    private func advancePlaylist() {
        guard let current = selectedLesson,
              let currentIndex = sortedLessons.firstIndex(of: current) else { return }
        
        let nextIndex = currentIndex + 1
        
        if nextIndex < sortedLessons.count {
            // Updating this will trigger the View's .onChange
            selectedLesson = sortedLessons[nextIndex]
        } else {
            print("Playlist finished.")
        }
    }
    
    func getLegacyVideoURL(for fileName: String) -> URL? {
        if let bundleURL = Bundle.main.url(forResource: fileName, withExtension: nil) {
            return bundleURL
        }
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let legacyPath = documentsURL
                .appendingPathComponent("CombatMMA/combatflows/purchased_content")
                .appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: legacyPath.path) { return legacyPath }
        }
        return nil
    }
}
