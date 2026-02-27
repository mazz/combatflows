//
//  MoreMenuView.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//


import SwiftUI

struct MoreMenuView: View {
    @Environment(StoreManager.self) var storeManager
    @State private var showRestoreAlert = false
    
    var body: some View {
        List {
            // About Us
            NavigationLink {
                AboutUsView() // Placeholder for your custom view
            } label: {
                MoreRow(title: "About Us", 
                        subtitle: "Find out who we are and what drives us to build the best training apps for you.", 
                        icon: "info.circle")
            }
            
            // Dedication
            NavigationLink {
                DedicationView() // Placeholder
            } label: {
                MoreRow(title: "Dedication", 
                        subtitle: "We owe our success to those who helped us along in our journey.", 
                        icon: "heart.fill")
            }
            
//            // Social
//            NavigationLink {
//                SocialMainView() // Placeholder
//            } label: {
//                MoreRow(title: "Social", 
//                        subtitle: "Follow us and keep us with the latest deals and info on new and current apps.", 
//                        icon: "person.2.fill")
//            }
            
            // Disclaimer
//            NavigationLink {
//                DisclaimerView() // Placeholder
//            } label: {
//                MoreRow(title: "Disclaimer", 
//                        subtitle: "This is our comprehensive agreement between our users and our training apps.", 
//                        icon: "doc.text")
//            }
            
            // Restore Purchases
            Button {
                showRestoreAlert = true
            } label: {
                MoreRow(title: "Restore", 
                        subtitle: "Restore your in-app purchases.", 
                        icon: "arrow.clockwise.circle", 
                        isButton: true)
            }
        }
        .navigationTitle("More")
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore") {
                storeManager.restorePurchases()
            }
        } message: {
            Text("Restore all in-app purchases made with CombatFlows?")
        }
    }
}

// Custom Row to match the legacy SCRTitleBodyTableViewCell look
struct MoreRow: View {
    let title: String
    let subtitle: String
    let icon: String
    var isButton: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.combatFlowsConfetti) // Match your app's theme
                .frame(width: 30)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(.subheadline))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 8)
    }
}
