//
//  GetTrainedGridView.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//

import SwiftUI

struct GetTrainedGridView: View {
    @Bindable var vm: ContentViewModel
    @Binding var selectedFlow: Flow?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !vm.storeManager.purchasedProductIDs.contains(vm.storeManager.bundleID) {
                    BundleFeatureTile()
                        .padding(.horizontal)
                }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(vm.store.flowGroups) { group in
                        let locked = !vm.isUnlocked(group)
                        
                        ForEach(group.combatFlows) { flow in
                            let isCinemaMode = selectedFlow != nil
                            let isThisFlowSelected = selectedFlow?.id == flow.id
                            let shouldDim = isCinemaMode && !isThisFlowSelected

                            Button {
                                vm.handleTap(group: group, flow: flow) { tappedFlow in
                                    selectedFlow = tappedFlow
                                }
                            } label: {
                                FlowGridItem(
                                    group: group,
                                    flow: flow,
                                    isLocked: locked,
                                    isFavorite: vm.isFavorite(group),
                                    downloadProgress: vm.downloadProgress(for: group),
                                    price: vm.localizedPrice(for: group),
                                    onToggleFavorite: { vm.toggleFavorite(for: group) },
                                    isDimmed: shouldDim,
                                    isSelected: isThisFlowSelected
                                )
                                .equatable()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}
