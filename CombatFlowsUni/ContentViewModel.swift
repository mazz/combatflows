//
//  ContentViewModel.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//


import SwiftUI
import StoreKit

@Observable
class ContentViewModel {
    var store: CurriculumStore
    // We do NOT use @Published here; @Observable handles the tracking
    var storeManager: StoreManager
    
    init(store: CurriculumStore, storeManager: StoreManager) {
        self.store = store
        self.storeManager = storeManager
    }
    
    // Check if a group is unlocked without ContentView needing to watch StoreManager
    func isUnlocked(_ group: FlowGroup) -> Bool {
        if group.productIdentifier == "ca.ilearningsolutions.combatflows.combatflow04" { return true }
        if storeManager.purchasedProductIDs.contains(storeManager.bundleID) { return true }
        return storeManager.purchasedProductIDs.contains(group.productIdentifier)
    }
    
    var favoriteFlows: [(group: FlowGroup, flow: Flow)] {
        var favorites: [(group: FlowGroup, flow: Flow)] = []
        
        for group in store.flowGroups {
            // Use group.combatFlows as seen in StoreManager.getRequiredAssets
            for flow in group.combatFlows {
                // Favoriting is currently tracked by productIdentifier (Group level)
                // If you want to favorite individual flows, you'd need a Set<UUID>
                // but based on your current StoreManager, we check the group ID:
                if storeManager.favoriteProductIDs.contains(group.productIdentifier) {
                    favorites.append((group, flow))
                }
            }
        }
        return favorites
    }

    // 2. Fix the missing isFavorite method call
    func isFavorite(_ group: FlowGroup) -> Bool {
        return storeManager.favoriteProductIDs.contains(group.productIdentifier)
    }
    
    
    func downloadProgress(for group: FlowGroup) -> Double? {
        storeManager.downloadProgress[group.productIdentifier]
    }
    
    func localizedPrice(for group: FlowGroup) -> String {
        let product = storeManager.fetchedProducts.first(where: { $0.productIdentifier == group.productIdentifier })
        return product?.localizedPrice ?? "GET"
    }
    
    func toggleFavorite(for group: FlowGroup) {
        storeManager.toggleFavorite(for: group.productIdentifier)
    }
    
    func handleTap(group: FlowGroup, flow: Flow, onSelect: (Flow) -> Void) {
        if isUnlocked(group) {
            onSelect(flow)
        } else {
            if let product = storeManager.fetchedProducts.first(where: { $0.productIdentifier == group.productIdentifier }) {
                storeManager.buy(product: product)
            }
        }
    }
}
