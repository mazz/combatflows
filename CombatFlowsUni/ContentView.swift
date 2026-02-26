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


struct ContentView: View {
    @State private var store = CurriculumStore()
    
    // Track which main tab is selected
    @State private var selectedCategory: NavCategory? = .getTrained
    
    // Track which specific flow group is selected (for the middle column)
    @State private var selectedGroupID: String?

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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 20) {
                        ForEach(store.flowGroups) { group in
                            // Using NavigationLink instead of Button for iPhone compatibility
                            NavigationLink {
                                // This is the view that will push on iPhone
                                if let firstFlow = group.combatFlows.first {
                                    FlowPlayerView(flow: firstFlow)
                                }
                            } label: {
                                VStack {
                                    LoopingThumbnailView(fileName: group.previewVideoName)
                                        .frame(width: 150, height: 150)
                                        .cornerRadius(12)
                                        .clipped()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedGroupID == group.id ? Color.accentColor : Color.clear, lineWidth: 3)
                                        )
                                    
                                    Text(group.name)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(selectedGroupID == group.id ? .accentColor : .primary)
                                }
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                // Update state so iPad/Mac detail view also reacts
                                selectedGroupID = group.id
                            })
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Get Trained")
            case .favorites:
                Text("Favorites Grid Coming Soon")
                    .navigationTitle("Favorites")
                
            case .more:
                List {
                    NavigationLink("About CombatFlows") { Text("About View") }
                    NavigationLink("Settings") { Text("Settings View") }
                    NavigationLink("Restore Purchases") { Text("IAP Logic") }
                }
                .navigationTitle("More")
                
            case .none:
                Text("Select a Category")
            }
            
        } detail: {
            // --- DETAIL COLUMN (Tertiary) ---
            if let groupID = selectedGroupID,
               let group = store.flowGroups.first(where: { $0.id == groupID }) {
                
                // OPTION A: Show the Player for the first flow in that group
                if let firstFlow = group.combatFlows.first {
                    FlowPlayerView(flow: firstFlow)
                } else {
                    ContentUnavailableView("No Videos Available", systemImage: "video.slash")
                }
                
                /* // OPTION B: If you'd rather see the Grid first, keep it as:
                 // FlowGridView(group: group)
                 */
                
            } else {
                ContentUnavailableView("Select a Flow Group", systemImage: "play.circle")
            }
        }
    }
}

#Preview {
    ContentView()
}


struct FlowGridView: View {
    let group: FlowGroup
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 10)]
    
    var body: some View {
        ScrollView {
            // Ensure we are passing the array directly, not as a binding
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(group.combatFlows) { flow in
                    NavigationLink(destination: FlowPlayerView(flow: flow)) {
                        VStack {
                            // The Square Looping Video Preview
                            LoopingThumbnailView(fileName: flow.thumbnailName)
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .clipped()
                            
                            Text("Flow \(flow.nominal)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(group.name)
    }
}

struct LoopingThumbnailView: View {
    let fileName: String
    
    var body: some View {
        // Clean the filename for the library
        let cleanName = fileName.replacingOccurrences(of: "@2x", with: "")
                                .replacingOccurrences(of: ".m4v", with: "")
        ExtVideoPlayer {
            VideoSettings {
                SourceName(cleanName)
                Ext("m4v")
                Gravity(.resizeAspectFill)
                Loop()
                Mute()
            }
        }
        .aspectRatio(contentMode: .fill)
    }
}

enum NavCategory: String, CaseIterable, Identifiable {
    case getTrained = "Get Trained"
    case favorites = "Favorites"
    case more = "More"
    
    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .getTrained: return "figure.martial-arts"
        case .favorites: return "star.fill"
        case .more: return "ellipsis.circle"
        }
    }
}

