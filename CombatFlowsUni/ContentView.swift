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
    // CRITICAL: We keep this here for initialization, but we do NOT
    // access it inside the 'body' for grid-item properties.
    @EnvironmentObject var storeManager: StoreManager
    
    @State private var selectedCategory: NavCategory? = .getTrained
    @State private var selectedFlow: Flow?
    @State private var viewModel: ContentViewModel?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
//        NavigationSplitView {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedCategory) {
                ForEach(NavCategory.allCases) { category in
                    NavigationLink(value: category) {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
            }
            .navigationTitle("CombatFlows")
            
        } content: {
            if let vm = viewModel {
                switch selectedCategory {
                case .getTrained:
                    GetTrainedGridView(vm: vm, selectedFlow: $selectedFlow)
                    .navigationTitle("Get Trained")
                    .navigationDestination(item: $selectedFlow) { flow in
//                        FlowPlayerView(flow: flow)

                        FlowPlayerView(flow: flow, columnVisibility: $columnVisibility)
                    }
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
            } else {
                ProgressView("Loading...")
            }
        } detail: {
            if let flow = selectedFlow {
                FlowPlayerView(flow: flow, columnVisibility: $columnVisibility)
            } else {
                ContentUnavailableView("Select a Flow to Watch", systemImage: "play.rectangle.on.rectangle")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ContentViewModel(store: store, storeManager: storeManager)
            }
            storeManager.initializePurchases(with: store)
            
            var allIDs = Set(store.flowGroups.map { $0.productIdentifier })
            allIDs.insert("ca.ilearningsolutions.combatflows.combatflowbundle")
            storeManager.fetchProducts(productIdentifiers: allIDs)
        }
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
