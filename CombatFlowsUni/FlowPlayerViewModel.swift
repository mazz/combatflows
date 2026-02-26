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

    var countdownRemaining: Int = 0
    var isCountingDown: Bool = false
    
    var playbackRate: Float = 1.0
    
    // Toggle between 1.0x and 0.5x
    func toggleSlowMotion() {
        playbackRate = (playbackRate == 1.0) ? 0.5 : 1.0
        player.rate = playbackRate
    }
    
    func togglePlayPause() {
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
            player.rate = playbackRate // Ensure it resumes at correct speed
        }
    }
    
    func skipToNextLesson() {
        guard let current = selectedLesson,
              let currentIndex = sortedLessons.firstIndex(of: current),
              currentIndex + 1 < sortedLessons.count else { return }
        selectedLesson = sortedLessons[currentIndex + 1]
    }
    
    func skipToPreviousLesson() {
        guard let current = selectedLesson,
              let currentIndex = sortedLessons.firstIndex(of: current),
              currentIndex - 1 >= 0 else { return }
        selectedLesson = sortedLessons[currentIndex - 1]
    }
    
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
    
    private func prepareNextLesson(allowLoopAll: Bool) {
        guard let current = selectedLesson,
              let currentIndex = sortedLessons.firstIndex(of: current) else { return }
        
        let nextIndex = currentIndex + 1
        
        if nextIndex < sortedLessons.count || allowLoopAll {
            startCountdown {
                if nextIndex < self.sortedLessons.count {
                    self.selectedLesson = self.sortedLessons[nextIndex]
                } else {
                    self.selectedLesson = self.sortedLessons.first
                }
            }
        }
    }
    
    private func startCountdown(completion: @escaping () -> Void) {
        isCountingDown = true
        countdownRemaining = 5 // 5 second reset window
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdownRemaining > 1 {
                self.countdownRemaining -= 1
            } else {
                timer.invalidate()
                self.isCountingDown = false
                completion()
            }
        }
    }
    
    private func handleVideoEnd() {
        switch loopMode {
        case .off:
            prepareNextLesson(allowLoopAll: false)
        case .loopOne:
            player.seek(to: .zero)
            player.play()
            playCurrent()
        case .loopAll:
            prepareNextLesson(allowLoopAll: true)
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
