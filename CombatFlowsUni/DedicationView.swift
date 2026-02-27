//
//  DisclaimerView.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//

import SwiftUI

struct DedicationView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 30) {
                    
                    // First Section: Primary Dedication
                    VStack(alignment: .center, spacing: 12) {
                        Text("This App is dedicated to Makoto Kabayama, my inspiration in Jeet Kune Do and martial arts philosophy. It is also dedicated to the memory of Bruce Lee and Larry Hartsell.")
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundColor(Color.combatFlowsConfetti)
                            .lineSpacing(3)
                            .multilineTextAlignment(.center)
                    }
                    
                    Image("dedication_pic")
                        .scaledToFit()
                    VStack(alignment: .center, spacing: 12) {
                        
                        Text("I would also like to thank the following for their involvement in the recording of the App.\n\nIlya Strashun\nBoris Zaytsev\nRicardo Vasquez\nRay Bennett\nTom Roniotis\nPatrick Roberts\n\nCheers and thanks for helping me continue to 'find my way.'\n\nPeter Chassikos")
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
        .navigationTitle("Dedication")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DedicationView()
    }
    .preferredColorScheme(.dark)
}


extension Color {
    static let combatFlowsConfetti = Color(red: 233/255, green: 212/255, blue: 96/255)
    
    // Alternative using Hex if you prefer:
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
