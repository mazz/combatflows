//
//  DisclaimerView.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 30) {
                    
                    // First Section: Primary Dedication
                    VStack(alignment: .center, spacing: 12) {
                        Text("Combat MMA is dedicated to providing you with cutting-edge martial arts training through a medium that can be taken anywhere.")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundColor(Color.combatFlowsConfetti)
                            .lineSpacing(3)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(alignment: .center, spacing: 12) {
                        Text("Our apps are intended for martial artists of all styles and levels of ability. These apps focus on continuity of technique or flow, and are different from (some say superior to) any other martial arts training apps that are currently available in the App Store.")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundColor(Color.combatFlowsConfetti)
                            .lineSpacing(3)
                            .multilineTextAlignment(.center)
                    }
                    VStack(alignment: .center, spacing: 12) {
                        Text("We have a unique user interface that allows for easy navigation, that also features a thumbnail preview of all martial arts techniques featured on the app (they all play at the same time-just click on the one you want to see full screen). Our videos are shot in HD and take advantage of the iPhone's retina display. With Airplay® built into these apps, you release the full viewing potential of the HD footage on your high definition television using Apple TV® (sold separately)")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundColor(Color.combatFlowsConfetti)
                            .lineSpacing(3)
                            .multilineTextAlignment(.center)
                    }
                    VStack(alignment: .center, spacing: 12) {
                        Text("At CombatMMA, we are inspired by those that seek constant improvement and those that strive for self perfection.")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundColor(Color.combatFlowsConfetti)
                            .lineSpacing(3)
                            .multilineTextAlignment(.center)
                    }
                    VStack(alignment: .center, spacing: 12) {
                        Text("\"Use no way as way, and have no limitation as limitation\" - Bruce Lee")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundColor(Color.combatFlowsConfetti)
                            .lineSpacing(3)
                            .multilineTextAlignment(.center)
                        
                        Image("cmma_logo_white")
                            .scaledToFit()

                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}
