//
//  LockedUpsellView.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI
import StoreKit

//struct LockedUpsellView: View {
//    let group: FlowGroup
//    @EnvironmentObject var storeManager: StoreManager
//    
//    // Find the specific SKProduct for this group from the fetched list
//    var groupProduct: SKProduct? {
//        storeManager.fetchedProducts.first { $0.productIdentifier == group.productIdentifier }
//    }
//    
//    // Find the "Everything Bundle" product
//    var bundleProduct: SKProduct? {
//        storeManager.fetchedProducts.first { $0.productIdentifier == storeManager.bundleID }
//    }
//
//    var body: some View {
//        VStack(spacing: 30) {
//            // 1. Icon & Header
//            Image(systemName: "lock.fill")
//                .font(.system(size: 60))
//                .foregroundColor(.secondary)
//                .padding(.top, 40)
//            
//            VStack(spacing: 8) {
//                Text(group.name)
//                    .font(.title2.bold())
//                Text(group.text ?? "Unlock this combat flow to view all lessons.")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//            }
//
//            // 2. Purchase Options
//            VStack(spacing: 16) {
//                // Buy Individual Flow
//                if let product = groupProduct {
//                    PurchaseButton(
//                        title: "Unlock This Flow",
//                        price: product.localizedPrice, // See helper below
//                        action: { storeManager.buy(product: product) }
//                    )
//                }
//
//                // Buy Everything Bundle (The "Combat Flow Bundle" logic)
//                if let bundle = bundleProduct {
//                    PurchaseButton(
//                        title: "Unlock All Flows (Bundle)",
//                        price: bundle.localizedPrice,
//                        color: .accentColor,
//                        action: { storeManager.buy(product: bundle) }
//                    )
//                }
//            }
//            .padding(.horizontal, 40)
//
//            // 3. Restore Button
//            Button("Restore Purchases") {
//                storeManager.restorePurchases()
//            }
//            .font(.footnote)
//            
//            Spacer()
//        }
//    }
//}

struct LockedUpsellView: View {
    let group: FlowGroup
    @EnvironmentObject var storeManager: StoreManager
    
    var groupProduct: SKProduct? {
        storeManager.fetchedProducts.first { $0.productIdentifier == group.productIdentifier }
    }
    
    var bundleProduct: SKProduct? {
        storeManager.fetchedProducts.first { $0.productIdentifier == storeManager.bundleID }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Unlock \(group.name)")
                .font(.headline)
            
            if let product = groupProduct {
                Button("Buy This Group — \(product.localizedPrice)") {
                    storeManager.buy(product: product)
                }
                .buttonStyle(.borderedProminent)
            }
            
            if let bundle = bundleProduct {
                Button("Unlock Everything — \(bundle.localizedPrice)") {
                    storeManager.buy(product: bundle)
                }
                .buttonStyle(.bordered)
            }
            
            Button("Restore Purchases") {
                storeManager.restorePurchases()
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "$0.00"
    }
}

// Subview for consistent button styling
struct PurchaseButton: View {
    let title: String
    let price: String
    var color: Color = .secondary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Text(price)
                    .fontWeight(.bold)
            }
            .padding()
            .background(color.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 2))
            .foregroundColor(color == .accentColor ? .accentColor : .primary)
        }
        .cornerRadius(10)
    }
}
