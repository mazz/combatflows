//
//  MainSidebarView.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI

struct MainSidebarView: View {
    // 1. Initialize the data store
    @State private var store = CurriculumStore()
    
    // 2. Track the ID (String) of the selected group
    @State private var selectedGroupID: String?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedGroupID) {
                // 3. Dynamically generate the list from the JSON data
                Section("Library") {
                    ForEach(store.flowGroups) { group in
                        NavigationLink(value: group.id) {
                            Label(group.name, systemImage: "figure.martial.arts")
                        }
                    }
                }
                
                Section("Filters") {
                    Label("Favorites", systemImage: "star").tag("Favorites")
                    Label("Recent", systemImage: "clock").tag("Recent")
                }
            }
            .navigationTitle("CombatFlows")
            
        } content: {
            // 4. Look up the actual FlowGroup object using the ID
            if let groupID = selectedGroupID,
               let group = store.flowGroups.first(where: { $0.id == groupID }) {
                FlowGridView(group: group)
            } else {
                ContentUnavailableView("Select a Flow", systemImage: "figure.martial.arts")
            }
            
        } detail: {
            Text("Select a flow to begin training")
                .foregroundStyle(.secondary)
        }
    }
}
