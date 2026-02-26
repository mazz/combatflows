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


struct FlowGridItem: View {
    let group: FlowGroup
    let flow: Flow
    let isLocked: Bool
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        let activeProgress = storeManager.downloadProgress[group.productIdentifier]
        let isDownloading = activeProgress != nil
        
        ZStack {
            // 1. The Video Base
            LoopingThumbnailView(fileName: group.previewVideoName)
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .clipped()
                .blur(radius: (isLocked || isDownloading) ? 3 : 0)
            
            // 2. Upper-Right Corner: Lock or Favorite
            VStack {
                HStack {
                    Spacer()
                    if isLocked {
                        // LOCK ICON IN TOP RIGHT
                        Image("icn_lock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
//                            .padding(8)
                    } else {
                        // FAVORITE BUTTON IN TOP RIGHT
                        Button {
                            storeManager.toggleFavorite(for: group.productIdentifier)
                        } label: {
                            let isFav = storeManager.favoriteProductIDs.contains(group.productIdentifier)
                            Image(isFav ? "icn_unlocked_fav_on" : "icn_unlocked_fav_off")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
//                        .padding(4)
                    }
                }
                Spacer()
            }
            
            // 3. Central UI (Price Button or Progress)
            if let progress = activeProgress {
                DownloadProgressOverlay(progress: progress)
            } else if isLocked {
                // GET BUTTON IN CENTER
                let product = storeManager.fetchedProducts.first(where: { $0.productIdentifier == group.productIdentifier })
                Text(product?.localizedPrice ?? "GET")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.green, lineWidth: 2)
                            .background(Color.black.opacity(0.4).clipShape(Capsule()))
                    )
            }
            
            // 4. Info Overlay (Bottom)
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name.uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                    Text(group.text ?? "")
                        .font(.system(size: 9, weight: .medium))
                        .lineLimit(2)
                }
                .foregroundColor(.white)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.4))
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .overlay(
            Rectangle()
                .stroke(isLocked ? Color.green.opacity(0.5) : Color.blue.opacity(0.5), lineWidth: 2)
        )
    }
}

struct DownloadProgressOverlay: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
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

