//
//  ContentView.swift
//  CombatFlowsUni
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI
import AVKit
import swiftui_loop_videoplayer
import StoreKit


struct ContentView: View {
    @State private var store = CurriculumStore()
    @EnvironmentObject var storeManager: StoreManager // Access the app-wide manager
    
    // Track which main tab is selected
    @State private var selectedCategory: NavCategory? = .getTrained
    
    // Track which specific flow group is selected (for the middle column)
    @State private var selectedGroupID: String?
    @State private var selectedFlow: Flow?
    
//    let columns = [
//        GridItem(.fixed(150), spacing: 16),
//        GridItem(.fixed(150), spacing: 16)
//    ]
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 20)]

    var body: some View {
        NavigationSplitView {
            // --- SIDEBAR (Primary) ---
            List(selection: $selectedCategory) {
                ForEach(NavCategory.allCases) { category in
                    NavigationLink(value: category) {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
            }
            .navigationTitle("CombatFlows")
            
        } content: {
            // --- MIDDLE COLUMN (Secondary) ---
            switch selectedCategory {
            case .getTrained:
                ScrollView {
                    VStack(spacing: 20) { // Added spacing between tile and grid
                        
                        // --- THE BUNDLE TILE ---
                        if !storeManager.purchasedProductIDs.contains(storeManager.bundleID) {
                            BundleFeatureTile()
                                .padding(.horizontal)
                        }
                        
                        // --- THE REGULAR FLOW GRID ---
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(store.flowGroups) { group in
                                let locked = !isUnlocked(group)
                                
                                ForEach(group.combatFlows) { flow in
                                    Button {
                                        if locked {
                                            if let product = storeManager.fetchedProducts.first(where: { $0.productIdentifier == group.productIdentifier }) {
                                                storeManager.buy(product: product)
                                            }
                                        } else {
                                            selectedFlow = flow
                                        }
                                    } label: {
                                        FlowGridItem(group: group, flow: flow, isLocked: locked)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Get Trained")
                .navigationDestination(item: $selectedFlow) { flow in
                    FlowPlayerView(flow: flow)
                }
                // This is what prevents the 1-column collapse on Mac/iPad
                .navigationSplitViewColumnWidth(min: 360, ideal: 375, max: 380)
                
            case .favorites:
                ContentUnavailableView("Favorites Coming Soon", systemImage: "star")
                    .navigationSplitViewColumnWidth(min: 360, ideal: 375, max: 380)

            case .more:
                List {
                    NavigationLink("About CombatFlows") { Text("About View") }
                    NavigationLink("Settings") { Text("Settings View") }
                }
                .navigationTitle("More")
                .navigationSplitViewColumnWidth(min: 360, ideal: 375, max: 380)

            case .none:
                Text("Select a Category")
            }
        }
        detail: {
            // --- DETAIL COLUMN (Tertiary) ---
            if let flow = selectedFlow {
                // This shows the actual video player when a flow is picked
                FlowPlayerView(flow: flow)
            } else {
                ContentUnavailableView("Select a Flow to Watch", systemImage: "play.rectangle.on.rectangle")
            }
        }
        .onAppear {
            storeManager.initializePurchases(with: store)
            
            // Create a combined set of all group IDs PLUS the bundle ID
            var allIDs = Set(store.flowGroups.map { $0.productIdentifier })
            allIDs.insert("ca.ilearningsolutions.combatflows.combatflowbundle") // The ID from SCRProductService.m
            
            storeManager.fetchProducts(productIdentifiers: allIDs)
        }
    }
    
    // Add this inside struct ContentView
    func isUnlocked(_ group: FlowGroup) -> Bool {
        // 1. Free Product Check (ca.ilearningsolutions.combatflows.combatflow04)
        if group.productIdentifier == "ca.ilearningsolutions.combatflows.combatflow04" {
            return true
        }
        
        // 2. Everything Bundle Check
        if storeManager.purchasedProductIDs.contains(storeManager.bundleID) {
            return true
        }
        
        // 3. Individual Group Purchase Check
        return storeManager.purchasedProductIDs.contains(group.productIdentifier)
    }
}

#Preview {
    ContentView()
}

enum NavCategory: String, CaseIterable, Identifiable {
    case getTrained = "Get Trained"
    case favorites = "Favorites"
    case more = "More"
    
    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .getTrained: return "figure.martial.arts"
        case .favorites: return "star.fill"
        case .more: return "ellipsis.circle"
        }
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
