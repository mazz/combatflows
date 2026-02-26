//
//  ContentView.swift
//  CombatFlowsUni
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI

//struct ContentView: View {
//    // 1. State to track the user's selection in the sidebar
//    @State private var selectedCategory: String? = "All Flows"
//    
//    var body: some View {
//        NavigationSplitView {
//            // --- SIDEBAR COLUMN ---
//            List(selection: $selectedCategory) {
//                Section("Library") {
//                    Label("All Flows", systemImage: "figure.martial-arts")
//                        .tag("All Flows")
//                    Label("Favorites", systemImage: "star")
//                        .tag("Favorites")
//                    Label("Recent", systemImage: "clock")
//                        .tag("Recent")
//                }
//                
//                Section("Settings") {
//                    Label("Profile", systemImage: "person.circle")
//                        .tag("Profile")
//                }
//            }
//            .navigationTitle("CombatFlows")
//            #if targetEnvironment(macCatalyst)
//            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
//            #endif
//            
//        } content: {
//            // --- CONTENT COLUMN (The Grid) ---
//            // When we port your grid logic, it will live here.
//            FlowGridView(category: selectedCategory ?? "All Flows")
//            
//        } detail: {
//            // --- DETAIL COLUMN (The Video Player) ---
//            // This stays empty or shows a placeholder until a flow is clicked.
//            VStack(spacing: 20) {
//                Image(systemName: "play.rectangle.on.rectangle")
//                    .font(.system(size: 50))
//                    .foregroundStyle(.secondary)
//                Text("Select a flow from the list to view details.")
//                    .font(.headline)
//                    .foregroundStyle(.secondary)
//            }
//        }
//    }
//}

import SwiftUI

struct ContentView: View {
    // 1. Initialize the store (this replaces sharedCurriculum)
    @State private var store = CurriculumStore()
    
    // 2. Track selection
    @State private var selectedGroupID: String?
    
    var body: some View {
        NavigationSplitView {
            // --- SIDEBAR COLUMN ---
            List(selection: $selectedGroupID) {
                Section("Combat Flows") {
                    ForEach(store.flowGroups) { group in
                        NavigationLink(value: group.id) {
                            Label(group.name, systemImage: "figure.martial.arts")
                        }
                    }
                }
            }
            .navigationTitle("Curriculum")
            #if targetEnvironment(macCatalyst)
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            #endif
            
        } content: {
            // --- CONTENT COLUMN (The Grid) ---
            if let groupID = selectedGroupID,
               let group = store.flowGroups.first(where: { $0.id == groupID }) {
                FlowGridView(group: group)
            } else {
                ContentUnavailableView("Select a Flow Group", systemImage: "list.bullet")
            }
            
        } detail: {
            // --- DETAIL COLUMN (The Video Player) ---
            Text("Select a specific flow to watch video")
                .foregroundStyle(.secondary)
        }
    }
}

struct FlowGridView: View {
    let group: FlowGroup
    let columns = [GridItem(.adaptive(minimum: 180), spacing: 20)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(group.combatFlows) { flow in
                    // Wrap the card in a NavigationLink
                    NavigationLink(destination: FlowPlayerView(flow: flow)) {
                        VStack(alignment: .leading) {
                            // Thumbnail Logic (Assuming tns are in Assets)
//                            Image(String(format: "tn_cf_listview_%02d@2x", flow.nominal)) // Matching your legacy naming
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(height: 120)
//                                .clipped()
//                                .cornerRadius(8)
                            
                            // Create the filename string exactly as it appears on disk
                            let filename = String(format: "tn_cf_listview_%02d@2x", flow.nominal)

                            // Use UIImage to find the loose file in the bundle, then wrap in Image
                            if let uiImage = UIImage(named: filename) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                // Fallback if the file is truly missing
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 120)
                            }
                            
                            Text("Flow \(flow.nominal)")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain) // Keeps the text from turning blue/link colored
                }
            }
            .padding()
        }
        .navigationTitle(group.name)
    }
}

#Preview {
    ContentView()
}
