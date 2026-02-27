//
//  FavoritesGridView.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//

import SwiftUI

struct FavoritesGridView: View {
    @Bindable var vm: ContentViewModel
    @Binding var selectedFlow: Flow?
    
    let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 2)
    ]
    
    var body: some View {
        ScrollView {
            if vm.favoriteFlows.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "star",
                    description: Text("Tap the star icon on a drill to add it here.")
                )
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(vm.favoriteFlows, id: \.flow.id) { item in
                        FlowGridItem(
                            group: item.group,
                            flow: item.flow,
                            isLocked: !vm.isUnlocked(item.group),
                            isFavorite: true,
                            downloadProgress: vm.downloadProgress(for: item.group),
                            price: vm.localizedPrice(for: item.group),
                            onToggleFavorite: {
                                vm.toggleFavorite(for: item.group)
                            },
                            isDimmed: selectedFlow != nil && selectedFlow?.id != item.flow.id,
                            isSelected: selectedFlow?.id == item.flow.id
                        )
                        .onTapGesture {
                            vm.handleTap(group: item.group, flow: item.flow) { flow in
                                selectedFlow = flow
                            }
                        }
                    }
                }
                .padding(2)
            }
        }
    }
}
