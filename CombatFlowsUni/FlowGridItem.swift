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
        ZStack {
            // 1. The Video Base
            LoopingThumbnailView(fileName: group.previewVideoName)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .blur(radius: isLocked ? 3 : 0)
            
            VStack {
                HStack {
                    Spacer()
                    if isLocked {
                        // Show Lock Icon if locked
                        Image("icn_lock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else {
                        // Show Favorite Button if unlocked
                        Button {
                            storeManager.toggleFavorite(for: group.productIdentifier)
                        } label: {
                            let isFav = storeManager.favoriteProductIDs.contains(group.productIdentifier)
                            Image(isFav ? "icn_unlocked_fav_on" : "icn_unlocked_fav_off")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.plain) // Prevents the whole grid item from highlighting
                    }
                }
                Spacer()
            }
            
            // 2. The Info Overlay (Bottom)
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name.uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .lineLimit(1)
                    
                    Text(group.text ?? "")
                        .font(.system(size: 9, weight: .medium))
                        .lineLimit(4)
                        .opacity(0.9)
                }
                .foregroundColor(.white)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.3))
            }
            
            // 3. The "Get" Capsule or Progress Bar
            if isLocked {
                // CHECK FOR ACTIVE DOWNLOAD
                if let progress = storeManager.downloadProgress[group.productIdentifier] {
                    DownloadProgressOverlay(progress: progress)
                } else {
                    // Standard Purchase Button
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
                        .shadow(radius: 4)
                }
            }
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .overlay(
            Rectangle()
                .stroke(isLocked ? Color.green : Color.blue, lineWidth: 1)
        )
    }
}

// Subview for the Progress Bar
struct DownloadProgressOverlay: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .frame(width: 100)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("DOWNLOADING \(Int(progress * 100))%")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.green)
        }
        .padding(10)
        .background(Color.black.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 8)))
    }
}


