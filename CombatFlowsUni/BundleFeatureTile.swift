//
//  BundleFeatureTile.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI
import StoreKit

struct BundleFeatureTile: View {
    @Environment(StoreManager.self) var storeManager
    
    var body: some View {
        let bundleID = storeManager.bundleID
        let bundleProduct = storeManager.fetchedProducts.first(where: { $0.productIdentifier == bundleID })
        
        // Check for active bundle download
        let activeProgress = storeManager.downloadProgress[bundleID]
        let isDownloading = activeProgress != nil
        
        // Check if already purchased
        let isPurchased = storeManager.purchasedProductIDs.contains(bundleID)
        
        // If purchased AND not downloading, we can hide the tile or show a "Full Access" state
        if isPurchased && !isDownloading {
            EmptyView() // Or a "Full Access Unlocked" tile
        } else {
            Button {
                if let product = bundleProduct {
                    storeManager.buy(product: product)
                }
            } label: {
                ZStack {
                    Color.black
                    
                    // Green 1pt Square Border
                    Rectangle()
                        .stroke(Color.green, lineWidth: 1)
                    
                    // Normal Content
                    VStack(spacing: 12) {
                        Text("UNLEASH THE FULL CURRICULUM")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                            .tracking(2)
                        
                        Text("Unlock every flow, lesson, and future update.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(0.8)
                        
                        Text(bundleProduct?.localizedPrice ?? "GET EVERYTHING")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().stroke(Color.green, lineWidth: 2)
                            )
                    }
                    .padding()
                    .blur(radius: isDownloading ? 5 : 0) // Blur content while downloading
                    
                    // Progress Overlay
                    if let progress = activeProgress {
                        ZStack {
                            Color.black.opacity(0.6) // Darken the tile
                            DownloadProgressOverlay(progress: progress)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isDownloading) // Prevent double-taps while downloading
            .frame(height: 140)
            .frame(maxWidth: .infinity)
        }
    }
}
