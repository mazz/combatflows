//
//  MainSidebarView.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI

struct MainSidebarView: View {
    @State private var store = CurriculumStore()
    @State private var selectedGroupID: String?
    
    // 1. Track the specific flow selected for the video player
    @State private var selectedFlow: Flow?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedGroupID) {
                Section("Library") {
                    ForEach(store.flowGroups) { group in
                        NavigationLink(value: group.id) {
                            Label(group.name, systemImage: "figure.martial.arts")
                        }
                    }
                }
                // ... Filters Section
            }
            .navigationTitle("CombatFlows")
            
        } content: {
            if let groupID = selectedGroupID,
               let group = store.flowGroups.first(where: { $0.id == groupID }) {
                // 2. Pass the binding here with $
                FlowGridView(group: group, selectedFlow: $selectedFlow)
            } else {
                ContentUnavailableView("Select a Group", systemImage: "figure.martial.arts")
            }
            
        } detail: {
            // 3. Show the player if a flow is selected
            if let flow = selectedFlow {
                FlowPlayerView(flow: flow)
            } else {
                Text("Select a flow to begin training")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
