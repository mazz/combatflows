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
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        let bundleProduct = storeManager.fetchedProducts.first(where: { $0.productIdentifier == storeManager.bundleID })
        
        Button {
            if let product = bundleProduct {
                storeManager.buy(product: product)
            }
        } label: {
            ZStack {
                Color.black
                
                // Blue 1pt Square Border
                Rectangle()
                    .stroke(Color.green, lineWidth: 1)
                
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
                    
                    // Transparent Outline Capsule
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
            }
        }
        .buttonStyle(.plain)
        .frame(height: 140)
        .frame(maxWidth: .infinity)
    }
}
