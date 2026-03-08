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
    @State private var hasFinishedAnimation = false
    
    var body: some View {
        let bundleID = storeManager.bundleID
        let bundleProduct = storeManager.fetchedProducts.first(where: { $0.productIdentifier == bundleID })
        let activeProgress = storeManager.downloadProgress[bundleID]
        let isDownloading = activeProgress != nil
        let isPurchased = storeManager.purchasedProductIDs.contains(bundleID)
        
        Group {
            if isDownloading {
                ZStack {
                    Color.black
                    Rectangle().stroke(Color.green, lineWidth: 1)
                    
                    VStack(spacing: 15) {
                        ProgressView(value: activeProgress ?? 0)
                            .progressViewStyle(.linear)
                            .tint(.green)
                            .padding(.horizontal, 40)
                        
                        Text("INSTALLING FULL CURRICULUM \(Int((activeProgress ?? 0) * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
                .frame(height: 140)
            }
            // If purchased but NOT downloading, we can show the brief success message
            else if isPurchased {
                if !hasFinishedAnimation {
                    ZStack {
                        Color.black
                        Rectangle().stroke(Color.green, lineWidth: 1)
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 40))
                            Text("FULL ACCESS UNLOCKED")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                    .frame(height: 140)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { hasFinishedAnimation = true }
                        }
                    }
                }
            } else {
                // PURCHASE / DOWNLOADING STATE
                Button {
                    if let product = bundleProduct {
                        storeManager.buy(product: product)
                    }
                } label: {
                    ZStack {
                        Color.black
                        Rectangle().stroke(Color.green, lineWidth: 1)
                        
                        // Main Content (Blurs when downloading)
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
                        .blur(radius: isDownloading ? 5 : 0)
                        
                        // Progress Overlay (Appears when isDownloading is true)
                        if let progress = activeProgress {
                            ZStack {
                                Color.black.opacity(0.6)
                                VStack(spacing: 15) {
                                    ProgressView(value: progress)
                                        .progressViewStyle(.linear)
                                        .tint(.green)
                                        .padding(.horizontal, 40)
                                    
                                    Text("DOWNLOADING CURRICULUM \(Int(progress * 100))%")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(isDownloading)
                .frame(height: 140)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: isDownloading)
        .animation(.default, value: isPurchased)
    }
}
