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
    
    var isUnlocked: Bool {
        if group.productIdentifier == "ca.ilearningsolutions.combatflows.combatflow04" { return true }
        if storeManager.purchasedProductIDs.contains(storeManager.bundleID) { return true }
        return storeManager.purchasedProductIDs.contains(group.productIdentifier)
    }

//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // --- THE FEATURE BUNDLE ITEM ---
////                if !storeManager.purchasedProductIDs.contains(storeManager.bundleID) {
//                
//                Color.red.frame(height: 50)
//                    BundleFeatureTile()
//                        .padding(.horizontal)
//                        .environmentObject(storeManager)
////                }
//
//                // --- THE REGULAR FLOW GRID ---
//                gridContent
//            }
//            .padding(.vertical)
//        }
//    }
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Test block
//                Color.red
//                    .frame(height: 50)
//                    .frame(maxWidth: .infinity) // Force it to stretch
//                
//                BundleFeatureTile()
//                    .padding(.horizontal)
//                
//                gridContent
//            }
//            .frame(maxWidth: .infinity) // Force the VStack to fill the ScrollView
//        }
//    }
    
    var body: some View {
        List {
            // --- SECTION 1: THE BUNDLE ---
            // Placing this in its own section forces the List to give it a row
            Section {
                BundleFeatureTile()
                    .listRowInsets(EdgeInsets()) // Removes default list padding
                    .listRowSeparator(.hidden)
            }
            
            // --- SECTION 2: THE GRID ---
            Section {
                Text("hello")
                gridContent
                    .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain) // Keeps it looking like your clean background
        .navigationTitle(group.name)
    }
    
    private var gridContent: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 25) {
            ForEach(group.combatFlows) { flow in
                Button {
                    if isUnlocked {
                        selectedFlow = flow
                    } else {
                        if let product = storeManager.fetchedProducts.first(where: { $0.productIdentifier == group.productIdentifier }) {
                            storeManager.buy(product: product)
                        }
                    }
                } label: {
                    FlowGridItem(group: group, flow: flow, isLocked: !isUnlocked)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
