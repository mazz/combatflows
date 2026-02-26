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

enum LoopMode: String, CaseIterable {
    case off = "repeat"
    case loopOne = "repeat.1"
    case loopAll = "repeat.circle.fill"
    
    var icon: String { self.rawValue }
}

@Observable
class FlowPlayerViewModel {
    var flow: Flow
    var sortedLessons: [Lesson] = []
    var selectedLesson: Lesson?
    var player: AVPlayer = AVPlayer()
    var loopMode: LoopMode = .off // Default state
    
    private var playbackTask: Task<Void, Never>?

    init(flow: Flow) {
        self.flow = flow
        let order: [LessonPlaybackType: Int] = [.teaching: 0, .application: 1, .graphicGuide: 2]
        self.sortedLessons = flow.lessons.sorted {
            (order[$0.type] ?? 99) < (order[$1.type] ?? 99)
        }
        self.selectedLesson = sortedLessons.first
    }
    
    func toggleLoopMode() {
        let allModes = LoopMode.allCases
        if let currentIndex = allModes.firstIndex(of: loopMode) {
            let nextIndex = (currentIndex + 1) % allModes.count
            loopMode = allModes[nextIndex]
        }
    }

    func playCurrent() {
        playbackTask?.cancel()
        
        guard let filename = selectedLesson?.filename,
              let url = getLegacyVideoURL(for: filename) else { return }
        
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()
        
        playbackTask = Task { [weak self] in
            let sequence = NotificationCenter.default.notifications(
                named: .AVPlayerItemDidPlayToEndTime,
                object: item
            )
            
            for await _ in sequence {
                if Task.isCancelled { return }
                await MainActor.run {
                    self?.handleVideoEnd()
                }
                break
            }
        }
    }
    
    private func handleVideoEnd() {
        switch loopMode {
        case .off:
            advancePlaylist(allowLoopAll: false)
        case .loopOne:
            // Seek to start and play again without changing the selection
            player.seek(to: .zero)
            player.play()
            // We must restart the notification listener for the same item
            playCurrent()
        case .loopAll:
            advancePlaylist(allowLoopAll: true)
        }
    }
    
    private func advancePlaylist(allowLoopAll: Bool) {
        guard let current = selectedLesson,
              let currentIndex = sortedLessons.firstIndex(of: current) else { return }
        
        let nextIndex = currentIndex + 1
        
        if nextIndex < sortedLessons.count {
            selectedLesson = sortedLessons[nextIndex]
        } else if allowLoopAll {
            // Restart the entire playlist
            selectedLesson = sortedLessons.first
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
