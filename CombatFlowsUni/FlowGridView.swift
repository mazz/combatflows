//
//  FlowGridView.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI
import StoreKit

struct FlowGridView: View {
    let group: FlowGroup
    @EnvironmentObject var storeManager: StoreManager
    @Binding var selectedFlow: Flow?
    
    // This helper determines if the content should be playable or buyable
    var isUnlocked: Bool {
        // Free product check
        if group.productIdentifier == "ca.ilearningsolutions.combatflows.combatflow04" { return true }
        // Bundle check
        if storeManager.purchasedProductIDs.contains(storeManager.bundleID) { return true }
        // Specific product check
        return storeManager.purchasedProductIDs.contains(group.productIdentifier)
    }

    var body: some View {
        ScrollView {
            // We removed the 'if isUnlocked' branch here because you want
            // the grid to show even when locked, just with "GET" capsules.
            gridContent
        }
    }
    
    private var gridContent: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 25) {
            ForEach(group.combatFlows) { flow in
                Button {
                    if isUnlocked {
                        selectedFlow = flow
                    } else {
                        // Trigger the legacy buy logic
                        if let product = storeManager.fetchedProducts.first(where: { $0.productIdentifier == group.productIdentifier }) {
                            storeManager.buy(product: product)
                        }
                    }
                } label: {
                    // FIX: Pass the 'isLocked' status here
                    FlowGridItem(group: group, flow: flow, isLocked: !isUnlocked)
                        .environmentObject(storeManager)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}
