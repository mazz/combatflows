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
    @Binding var columnVisibility: NavigationSplitViewVisibility
    
    @State private var isTheaterMode: Bool = false
    @State private var showFlashIcon: String? = nil
    
    @Environment(\.dismiss) var dismiss
    
//    init(flow: Flow) {
    init(flow: Flow, columnVisibility: Binding<NavigationSplitViewVisibility>) {
        _vm = State(initialValue: FlowPlayerViewModel(flow: flow))
        _columnVisibility = columnVisibility
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VideoPlayer(player: vm.player) {
                // --- GESTURE LAYER OVERLAY ---
                HStack(spacing: 0) {
                    // 1. LEFT ZONE: Rewind 10s
                    Color.black.opacity(0.001)
                        .onTapGesture(count: 2) {
                            vm.skipTime(by: -10)
                            triggerHaptic(.light)
                            flash(icon: "gobackward.10")
                        }
                    
                    // 2. CENTER ZONE: Momentary Slo-Mo
                    Color.black.opacity(0.001)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    // Handle Slo-Mo
                                    if abs(value.translation.width) < 50 {
                                        vm.setPlaybackRate(0.5)
                                    }
                                }
                                .onEnded { value in
                                    vm.setPlaybackRate(1.0)
                                    
                                    if value.translation.width < -100 {
                                        vm.skipToNextLesson()
                                        flash(icon: "forward.end.fill")
                                    } else if value.translation.width > 100 {
                                        vm.skipToPreviousLesson()
                                        flash(icon: "backward.end.fill")
                                    } else if abs(value.translation.width) < 10 {
                                        // This handles a single tap to Play/Pause
                                        vm.togglePlayPause()
                                        let isPlaying = vm.player.rate > 0
                                        flash(icon: isPlaying ? "play.fill" : "pause.fill")
                                    }
                                }
                        )
                    // 3. RIGHT ZONE: Fast Forward 10s
                    Color.black.opacity(0.001)
                        .onTapGesture(count: 2) {
                            vm.skipTime(by: 10)
                            triggerHaptic(.light)
                            flash(icon: "goforward.10")
                        }
                }
                .contentShape(Rectangle())
            }
            .overlay(alignment: .topLeading) {
                backButton
            }
            
            .overlay {
                // Indicators (set to ignore hits so they don't block gestures)
                Group {
                    if vm.isCountingDown { countdownOverlay }
                    if vm.playbackRate == 0.5 { slowMoIndicator }
                    if let icon = showFlashIcon {
                        Image(systemName: icon)
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.5), radius: 10) // Helps with visibility
                            .transition(.scale.combined(with: .opacity))
                    }                }
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .top)
            
            pickerToolbar
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { vm.playCurrent() }
        .onDisappear { vm.player.pause() }
        .onChange(of: vm.selectedLesson) { oldLesson, newLesson in
            if oldLesson != newLesson {
                vm.playCurrent()
                vm.updateNowPlayingInfo()
            }
        }
    }
    
    // MARK: - Sub-components
    
    private var backButton: some View {
        Button {
            vm.player.pause()
            dismiss()
        } label: {
            Image(systemName: "chevron.left.circle.fill")
                .font(.title)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.leading, 20)
        .padding(.top, 8) // Small extra padding
        // This automatically respects the notch/status bar height
        .safeAreaPadding(.top)
    }
    
    private var slowMoIndicator: some View {
        VStack {
            Spacer()
            Text("SLOW MOTION (0.5x)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.yellow)
                .clipShape(Capsule())
                .padding(.bottom, 80)
        }
    }
    
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
    
    private func flash(icon: String) {
        showFlashIcon = icon
        withAnimation(.easeInOut(duration: 0.4)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showFlashIcon = nil
            }
        }
    }
    
    private var pickerToolbar: some View {
        HStack(spacing: 12) {
//            if !isTheaterMode {
                Picker("Lesson Type", selection: $vm.selectedLesson) {
                    ForEach(vm.sortedLessons, id: \.self) { lesson in
                        Text(lesson.type == .graphicGuide ? "Graphic" : lesson.type.rawValue.capitalized)
                            .tag(lesson as Lesson?)
                    }
                }
                .pickerStyle(.segmented)
                .transition(.move(edge: .leading).combined(with: .opacity))
//            } else {
//                // Optional: Show current lesson title when picker is hidden
//                Text(vm.selectedLesson?.type.rawValue.capitalized ?? "")
//                    .font(.caption.bold())
//                    .foregroundColor(.secondary)
//                Spacer()
//            }
            
            // Loop Button
            Button { vm.toggleLoopMode() } label: {
                Image(systemName: vm.loopMode.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(vm.loopMode == .off ? .primary : .blue)
                    .frame(width: 40, height: 40)
                    .background(.ultraThickMaterial)
                    .clipShape(Circle())
            }
            
            // Theater Mode Button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isTheaterMode.toggle()
                    
                    // COLLAPSE/EXPAND LOGIC
                    if isTheaterMode {
                        columnVisibility = .detailOnly // Hides sidebar
                    } else {
                        columnVisibility = .all // Shows sidebar
                    }
                }
            } label: {
                Image(systemName: isTheaterMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isTheaterMode ? .blue : .primary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThickMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
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

