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
//            case .getTrained:
////                ScrollView {
////                    LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150))], spacing: 20) {
////                        ForEach(store.flowGroups) { group in
////                            ForEach(group.combatFlows) { flow in
////                                Button {
////                                    selectedFlow = flow
////                                } label: {
////                                    // Use the GROUP'S video name if the FLOW'S name is blank
////                                    FlowGridItem(
////                                        flow: flow,
////                                        videoToUse: flow.thumbnailName.isEmpty ? group.previewVideoName : flow.thumbnailName
////                                    )
////                                }
////                                .buttonStyle(.plain)
////                            }
////                        }
////                    }
////                    .padding()
////                }
//                
//                ScrollView {
//                    LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150))], spacing: 20) {
//                        ForEach(store.flowGroups) { group in
//                            ForEach(group.combatFlows) { flow in
//                                Button {
//                                    selectedFlow = flow
//                                } label: {
//                                    FlowGridItem(group: group, flow: flow)
//                                }
//                                .buttonStyle(.plain)
//                            }
//                        }
//                    }
//                    .padding()
//                }
//                .navigationTitle("Get Trained")
//                .navigationDestination(item: $selectedFlow) { flow in
//                            FlowPlayerView(flow: flow)
//                }
//                // This locks the width so it's always exactly two columns wide
//                .navigationSplitViewColumnWidth(min: 360, ideal: 375, max: 380)

            case .getTrained:
                ScrollView {
                    // Using adaptive here handles the iPhone rotation "weirdness"
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(store.flowGroups) { group in
                            ForEach(group.combatFlows) { flow in
                                Button {
                                    selectedFlow = flow
                                } label: {
                                    FlowGridItem(group: group, flow: flow)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
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
//        } content: {
//            // --- MIDDLE COLUMN (Secondary) ---
//            switch selectedCategory {
//            case .getTrained:
//                ScrollView {
//                    LazyVGrid(columns: columns, spacing: 20) {
//                        ForEach(store.flowGroups) { group in
//                            // Using NavigationLink instead of Button for iPhone compatibility
//                            NavigationLink {
//                                if let firstFlow = group.combatFlows.first {
//                                    FlowPlayerView(flow: firstFlow)
//                                }
//                            } label: {
//                                VStack(alignment: .leading, spacing: 8) {
//                                    ZStack(alignment: .bottomLeading) {
//                                        LoopingThumbnailView(fileName: group.previewVideoName)
//                                            .frame(width: 150, height: 150)
////                                            .cornerRadius(12)
////                                            .clipped()
////                                            .overlay(
////                                                RoundedRectangle(cornerRadius: 12)
////                                                    .stroke(selectedGroupID == group.id ? Color.accentColor : Color.clear, lineWidth: 3)
////                                            )
//                                        
//                                        // INFO OVERLAY: Pulling from FlowGroup properties
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text(group.name.uppercased())
//                                                .font(.system(size: 10, weight: .black, design: .rounded))
//                                                .lineLimit(1)
//                                            
//                                            // This maps to the group.text or group.description field from your JSON
//                                            Text(group.text ?? "")
//                                                .font(.system(size: 9, weight: .medium))
//                                                .lineLimit(4)
//                                                .opacity(0.9)
//                                        }
//                                        .foregroundColor(.white)
//                                        .padding(8)
//                                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure the background covers the width
////                                        .background(.ultraThinMaterial)
////                                        .cornerRadius(8)
////                                        .padding(6) // Slight inset from the video edge
//                                    }                                }
//                            }
//                            .simultaneousGesture(TapGesture().onEnded {
//                                // Update state so iPad/Mac detail view also reacts
//                                selectedGroupID = group.id
//                            })
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding()
//                }
//                .navigationTitle("Get Trained")
//                .navigationSplitViewColumnWidth(min: 360, ideal: 375, max: 380)
//            case .favorites:
//                Text("Favorites Grid Coming Soon")
//                    .navigationTitle("Favorites")
//                    .navigationSplitViewColumnWidth(min: 360, ideal: 375, max: 380)
//            case .more:
//                List {
//                    NavigationLink("About CombatFlows") { Text("About View") }
//                    NavigationLink("Settings") { Text("Settings View") }
//                    NavigationLink("Restore Purchases") { Text("IAP Logic") }
//                }
//                .navigationTitle("More")
//                
//            case .none:
//                Text("Select a Category")
//            }
//            
//        }
        detail: {
            // --- DETAIL COLUMN (Tertiary) ---
            if let flow = selectedFlow {
                // This shows the actual video player when a flow is picked
                FlowPlayerView(flow: flow)
            } else {
                ContentUnavailableView("Select a Flow to Watch", systemImage: "play.rectangle.on.rectangle")
            }
        }
    }
}

#Preview {
    ContentView()
}

struct FlowGridView: View {
    let group: FlowGroup
    @Binding var selectedFlow: Flow?
    
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(group.combatFlows) { flow in
                    Button {
                        selectedFlow = flow
                    } label: {
                        FlowGridItem(group: group, flow: flow)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(group.name)
    }
}

//struct FlowGridItem: View {
//    let flow: Flow
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            ZStack(alignment: .bottomLeading) {
//                // 1. The Video Base
//                LoopingThumbnailView(fileName: flow.thumbnailName)
//                    .frame(width: 160, height: 160)
//                    .cornerRadius(12)
//                    .clipped()
//                
//                // 2. The Overlay Information (Replaces Row 2 & 4 of your old code)
//                VStack(alignment: .leading, spacing: 2) {
////                    Text("Flow \(flow.nominal)")
//                    Text("Flow \(flow.nominal)")
//                        .font(.system(size: 10, weight: .black))
//                        .foregroundColor(.white)
//                    
//                    Text("Graphic Guide")
//                        .font(.system(size: 9, weight: .bold))
//                        .foregroundColor(.white.opacity(0.8))
//                }
//                .padding(6)
//                .background(.ultraThinMaterial) // Modern frosted glass effect
//                .cornerRadius(6)
//                .padding(8)
//            }
//            
//            // 3. Overview Label (Replaces Row 0 of your old code)
//            Text("\(flow.name) Overview")
//                .font(.caption)
//                .fontWeight(.bold)
//                .lineLimit(1)
//        }
//    }
//}

struct FlowGridItem: View {
    let group: FlowGroup
    let flow: Flow
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. The Video (from the Group's thumbs)
            LoopingThumbnailView(fileName: group.previewVideoName)
                .frame(width: 150, height: 150)
                .background(Color.black)
            
            // 2. The Info Overlay
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .lineLimit(1)
                
                // This maps to the group.text or group.description field from your JSON
                Text(group.text ?? "")
                    .font(.system(size: 9, weight: .medium))
                    .lineLimit(4)
                    .opacity(0.9)
            }
            .foregroundColor(.white)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure the background covers the width
        }
//        .frame(width: 150, height: 150)
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
}

struct LoopingThumbnailView: View {
    let fileName: String
    
    var body: some View {
        // Remove ONLY the extension, do NOT change casing
        let cleanName = fileName.replacingOccurrences(of: ".m4v", with: "")
                                .replacingOccurrences(of: ".mp4", with: "")
        
        ExtVideoPlayer {
            VideoSettings {
                SourceName(cleanName)
                Ext("m4v")
                Gravity(.resizeAspectFill)
                Loop()
                Mute()
            }
        }
        .onAppear {
            // Check your Xcode Console (Cmd + Shift + C)
            // If this prints the wrong name, that's why it's black.
            print("🎬 Attempting to play: \(cleanName)")
        }
    }
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

