//
//  FlowGridItem.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI
import AVKit
import swiftui_loop_videoplayer
import StoreKit


struct FlowGridItem: View, Equatable {
    let group: FlowGroup
    let flow: Flow
    let isLocked: Bool
    // ADD THESE to match the Grid call:
    let isFavorite: Bool
    let downloadProgress: Double?
    let price: String
    var onToggleFavorite: () -> Void
    let isDimmed: Bool      // New: Dim if another video is playing
    let isSelected: Bool    // New: Highlight if this is the active video
    
    static func == (lhs: FlowGridItem, rhs: FlowGridItem) -> Bool {
        return lhs.group.productIdentifier == rhs.group.productIdentifier &&
        lhs.flow.id == rhs.flow.id && // Add flow ID check
        lhs.isLocked == rhs.isLocked &&
        lhs.isFavorite == rhs.isFavorite &&
        lhs.downloadProgress == rhs.downloadProgress &&
        lhs.price == rhs.price &&
        lhs.isDimmed == rhs.isDimmed &&  // CRITICAL
        lhs.isSelected == rhs.isSelected // CRITICAL
    }

    var body: some View {
        let isDownloading = downloadProgress != nil
        
        ZStack {
            // 1. The Video Base - Wrap in Optimized player to prevent reloads
            OptimizedVideoPlayer(fileName: group.previewVideoName)
                .equatable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .grayscale(isDimmed ? 0.8 : 0) // Remove color distraction
                .opacity(isDimmed ? 0.4 : 1.0) // Dim the brightness
                .blur(radius: isDimmed ? 1 : 0)
            // 2. Corner UI
            VStack {
                HStack {
                    Spacer()
                    if isLocked {
                        Image("icn_lock").resizable().scaledToFit().frame(width: 32, height: 32)
                    } else {
                        Button { onToggleFavorite() } label: {
                            Image(isFavorite ? "icn_unlocked_fav_on" : "icn_unlocked_fav_off")
                                .resizable().scaledToFit().frame(width: 40, height: 40)
                        }
                    }
                }
                Spacer()
            }
            
            // 3. Center UI
            if let progress = downloadProgress {
                DownloadProgressOverlay(progress: progress)
            } else if isLocked {
                Text(price)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Capsule().stroke(Color.green, lineWidth: 2)
                        .background(Color.black.opacity(0.4).clipShape(Capsule())))
            }
            
            // 4. Bottom Info
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name.uppercased()).font(.system(size: 10, weight: .black))
                    Text(group.text ?? "").font(.system(size: 9)).lineLimit(2)
                }
                .foregroundColor(.white).padding(8).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.4))
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .overlay(
            Rectangle()
                .stroke(isSelected ? Color.yellow : (isLocked ? Color.green.opacity(0.5) : Color.blue.opacity(0.5)),
                        lineWidth: isSelected ? 4 : 2)
        )
        .animation(.easeInOut, value: isDimmed)
    }
}

// Helper struct for video stability
struct OptimizedVideoPlayer: View, Equatable {
    let fileName: String
    static func == (lhs: OptimizedVideoPlayer, rhs: OptimizedVideoPlayer) -> Bool {
        lhs.fileName == rhs.fileName
    }
    var body: some View {
        LoopingThumbnailView(fileName: fileName)
    }
}

struct DownloadProgressOverlay: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background Circle
//                Circle()
//                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
//                    .frame(width: 50, height: 50)
                
                // Progress Circle
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Text("DOWNLOADING")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.blue)
                .kerning(1)
        }
        .padding(20)
        .background(Circle().fill(Color.black.opacity(0.6)))
        .shadow(radius: 10)
    }
}

