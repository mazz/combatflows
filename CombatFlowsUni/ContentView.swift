//
//  ContentView.swift
//  CombatFlowsUni
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//

import SwiftUI
import AVKit

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

//import SwiftUI

//struct ContentView: View {
//    // 1. Initialize the store (this replaces sharedCurriculum)
//    @State private var store = CurriculumStore()
//    
//    // 2. Track selection
//    @State private var selectedGroupID: String?
//    
//    var body: some View {
//        NavigationSplitView {
//            // --- SIDEBAR COLUMN ---
//            List(selection: $selectedGroupID) {
//                Section("Combat Flows") {
//                    ForEach(store.flowGroups) { group in
//                        NavigationLink(value: group.id) {
//                            Label(group.name, systemImage: "figure.martial.arts")
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Curriculum")
//            #if targetEnvironment(macCatalyst)
//            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
//            #endif
//            
//        } content: {
//            // --- CONTENT COLUMN (The Grid) ---
//            if let groupID = selectedGroupID,
//               let group = store.flowGroups.first(where: { $0.id == groupID }) {
//                FlowGridView(group: group)
//            } else {
//                ContentUnavailableView("Select a Flow Group", systemImage: "list.bullet")
//            }
//            
//        } detail: {
//            // --- DETAIL COLUMN (The Video Player) ---
//            Text("Select a specific flow to watch video")
//                .foregroundStyle(.secondary)
//        }
//    }
//}

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
                List(selection: $selectedGroupID) {
                    ForEach(store.flowGroups) { group in
                        NavigationLink(value: group.id) {
                            Text(group.name)
                        }
                    }
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
                // This is where your square looping video grid goes!
                FlowGridView(group: group)
            } else {
                ContentUnavailableView("Select a Flow", systemImage: "play.circle")
            }
        }
    }
}

#Preview {
    ContentView()
}


//struct FlowGridView: View {
//    let group: FlowGroup
//    let columns = [GridItem(.adaptive(minimum: 180), spacing: 20)]
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: columns, spacing: 20) {
//                ForEach(group.combatFlows) { flow in
//                    // Wrap the card in a NavigationLink
//                    NavigationLink(destination: FlowPlayerView(flow: flow)) {
//                        VStack(alignment: .leading) {
//                            // Thumbnail Logic (Assuming tns are in Assets)
////                            Image(String(format: "tn_cf_listview_%02d@2x", flow.nominal)) // Matching your legacy naming
////                                .resizable()
////                                .aspectRatio(contentMode: .fill)
////                                .frame(height: 120)
////                                .clipped()
////                                .cornerRadius(8)
//                            
//                            // Create the filename string exactly as it appears on disk
//                            let filename = String(format: "tn_cf_listview_%02d@2x", flow.nominal)
//
//                            // Use UIImage to find the loose file in the bundle, then wrap in Image
//                            if let uiImage = UIImage(named: filename) {
//                                Image(uiImage: uiImage)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(height: 120)
//                                    .clipped()
//                                    .cornerRadius(8)
//                            } else {
//                                // Fallback if the file is truly missing
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(Color.gray.opacity(0.3))
//                                    .frame(height: 120)
//                            }
//                            
//                            Text("Flow \(flow.nominal)")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                        }
//                    }
//                    .buttonStyle(.plain) // Keeps the text from turning blue/link colored
//                }
//            }
//            .padding()
//        }
//        .navigationTitle(group.name)
//    }
//}



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

// A simple wrapper to play the square preview videos looping/muted
struct LoopingThumbnailView: UIViewRepresentable {
    let fileName: String
    
    // The Coordinator holds the looper so it doesn't get garbage collected
    class Coordinator {
        var looper: AVPlayerLooper?
        var player: AVQueuePlayer?
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let cleanName = fileName.replacingOccurrences(of: "@2x", with: "")
        
        guard let path = Bundle.main.path(forResource: cleanName, ofType: "m4v") else {
            print("Looping video not found: \(cleanName)")
            return view
        }
        
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        
        let player = AVQueuePlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        
        // Assign to coordinator to keep alive
        context.coordinator.player = player
        context.coordinator.looper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        playerLayer.videoGravity = .resizeAspectFill
        player.isMuted = true
        player.play()
        
        view.layer.addSublayer(playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.sublayers?.first?.frame = uiView.bounds
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

