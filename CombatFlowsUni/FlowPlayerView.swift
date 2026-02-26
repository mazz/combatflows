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
            VideoPlayer(player: vm.player)
                .overlay {
                    if vm.isCountingDown {
                        ZStack {
                            Color.black.opacity(0.8)
                            VStack {
                                Text("NEXT DRILL IN")
                                    .font(.system(size: 24, weight: .black))
                                Text("\(vm.countdownRemaining)")
                                    .font(.system(size: 120, weight: .black, design: .rounded))
                                    .transition(.scale)
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                }
                .overlay(alignment: .topLeading) {
                    Button {
                        vm.player.pause()
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
                .onAppear {
                    vm.playCurrent()
                }
            
            HStack(spacing: 15) {
                Picker("Lesson Type", selection: $vm.selectedLesson) {
                    ForEach(vm.sortedLessons, id: \.self) { lesson in
                        Text(lesson.type == .graphicGuide ? "Graphic Guide" : lesson.type.rawValue.capitalized)
                            .tag(lesson as Lesson?)
                    }
                }
                .pickerStyle(.segmented)
                
                // Loop Toggle Button
                Button {
                    vm.toggleLoopMode()
                } label: {
                    Image(systemName: vm.loopMode.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(vm.loopMode == .off ? .primary : .blue)
                        .frame(width: 44, height: 44)
                        .background(.ultraThickMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .onChange(of: vm.selectedLesson) { oldValue, newValue in
                if oldValue != newValue {
                    vm.playCurrent()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.container, edges: .bottom)
        .onDisappear {
            vm.player.pause()
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

