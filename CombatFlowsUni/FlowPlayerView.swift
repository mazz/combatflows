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
    @State private var vm: FlowPlayerViewModel
    @Environment(\.dismiss) var dismiss
    
    init(flow: Flow) {
        _vm = State(initialValue: FlowPlayerViewModel(flow: flow))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VideoPlayer(player: vm.player) {
                // 1. Move the GESTURE LAYER inside the player's control content
                // This allows it to coexist with system controls
                Color.black.opacity(0.001)
                    .contentShape(Rectangle())
                    .highPriorityGesture(
                        TapGesture(count: 2).onEnded { vm.togglePlayPause() }
                    )
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            vm.toggleSlowMotion()
                        }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 50).onEnded { value in
                            if value.translation.width < -100 { vm.skipToNextLesson() }
                            else if value.translation.width > 100 { vm.skipToPreviousLesson() }
                        }
                    )
            }
            .overlay(alignment: .topLeading) {
                // 2. The Back Button
                Button {
                    vm.player.pause()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 50)
                .padding(.leading, 20)
            }
            .overlay {
                // 3. Countdown and Indicators (set to ignore hits)
                Group {
                    if vm.isCountingDown { countdownOverlay }
                    if vm.playbackRate == 0.5 { slowMoIndicator }
                }
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .top)
            
            pickerToolbar
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { vm.playCurrent() }
        .onDisappear { vm.player.pause() }
    }
    
    // Sub-views for cleanliness
    private var countdownOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
            VStack {
                Text("NEXT DRILL IN").font(.system(size: 24, weight: .black))
                Text("\(vm.countdownRemaining)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
            }
            .foregroundColor(.yellow)
        }
    }
    
    private var slowMoIndicator: some View {
        VStack {
            Spacer()
            Text("SLOW MOTION (0.5x)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(8)
                .background(Color.yellow)
                .clipShape(Capsule())
                .padding(.bottom, 60) // High enough to stay above the scrubber
        }
    }
    
    private var pickerToolbar: some View {
        HStack(spacing: 15) {
            Picker("Lesson Type", selection: $vm.selectedLesson) {
                ForEach(vm.sortedLessons, id: \.self) { lesson in
                    Text(lesson.type == .graphicGuide ? "Graphic Guide" : lesson.type.rawValue.capitalized)
                        .tag(lesson as Lesson?)
                }
            }
            .pickerStyle(.segmented)
            
            Button { vm.toggleLoopMode() } label: {
                Image(systemName: vm.loopMode.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(vm.loopMode == .off ? .primary : .blue)
                    .frame(width: 44, height: 44)
                    .background(.ultraThickMaterial)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .onChange(of: vm.selectedLesson) { old, new in
            if old != new { vm.playCurrent() }
        }
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

