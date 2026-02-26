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
                    // This grid shows the 16 Flow Groups as looping square previews
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 20) {
                        ForEach(store.flowGroups) { group in
                            Button {
                                selectedGroupID = group.id
                            } label: {
                                VStack {
                                    // Using the group's thumbnail (usually from 'thumbs' or 'listImage')
                                    // Assuming the group has a preview video matching its listImage name
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


// A simple wrapper to play the square preview videos looping/muted
//struct LoopingThumbnailView: UIViewRepresentable {
//    let fileName: String
//    
//    // The Coordinator holds the looper so it doesn't get garbage collected
//    class Coordinator {
//        var looper: AVPlayerLooper?
//        var player: AVQueuePlayer?
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator()
//    }
//    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//        
//        // 1. Clean up the filename (Remove @2x and handle extension)
//        let baseNameWithExt = fileName.replacingOccurrences(of: "@2x", with: "")
//        let nsString = baseNameWithExt as NSString
//        let resourceName = nsString.deletingPathExtension
//        let resourceExt = nsString.pathExtension.isEmpty ? "m4v" : nsString.pathExtension
//        
//        // 2. Locate the resource properly
//        guard let path = Bundle.main.path(forResource: resourceName, ofType: resourceExt) else {
//            print("❌ Looping video not found: \(resourceName).\(resourceExt)")
//            return view
//        }
//        
//        let url = URL(fileURLWithPath: path)
//        let playerItem = AVPlayerItem(url: url)
//        
//        let player = AVQueuePlayer(playerItem: playerItem)
//        let playerLayer = AVPlayerLayer(player: player)
//        
//        context.coordinator.player = player
//        context.coordinator.looper = AVPlayerLooper(player: player, templateItem: playerItem)
//        
//        playerLayer.videoGravity = .resizeAspectFill
//        player.isMuted = true
//        player.play()
//        
//        view.layer.addSublayer(playerLayer)
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        uiView.layer.sublayers?.first?.frame = uiView.bounds
//    }
//}

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

