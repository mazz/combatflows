//
//  DisclaimerModalView.swift
//  combatflows
//
//  Created by Michael on 2026-02-26.
//  Copyright © 2026 Sidha Inc. All rights reserved.
//


import SwiftUI

struct DisclaimerModalView: View {
    @AppStorage("hasAcceptedDisclaimer") var hasAcceptedDisclaimer: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Medical Disclaimer")
                            .font(.system(.title, design: .rounded, weight: .black))
                            .padding(.top)

                        Text("""
                        The following is a legally binding agreement between you and the developer of this application (Michael Hanna). Please read it carefully.
                        
                        - By using and/or accessing this application, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions and agree to comply with all applicable laws and regulations, including Federal, Provincial and/or State laws.
                        
                        - The techniques shown in the videos, clips and/or other recordings contained herein are for educational and entertainment purposes only.
                        
                        - By accepting below, you understand and acknowledge that you or your training partner may be injured, incur damages or even die if you apply or practise the techniques in this application.
                        
                        - Always consult a doctor first before attempting any physical activity as well as a qualified instructor that understands the physical demand and risks involved with training in the martial arts.
                        
                        - When applying any techniques, do so slowly, carefully and with control.  Release the hold immediately when your partner 'taps out' or tells you it is uncomfortable. Your training partner's safety is your responsibility.  Train only with people who will look out for your safety.
                        
                        - Attempt the techniques in this application at your own risk. The developer of this application and all other persons featured on this application, do not endorse and make no representation, warranty, guarantee, or claim regarding the accuracy, safety, effectiveness or legality of any technique illustrated, described, or demonstrated in this application.
                        
                        - Furthermore, the developer is not responsible in any manner whatsoever for any personal injury, damage or death that may occur from using the techniques or instructions contained in this application.  You therefore agree to hold harmless the developer, including but not limited to its agents, licensees, and officers for any action, suit, claim, loss, injury, or damage, arising from your negligence, recklessness, improper execution of the techniques, or for any damage, injury, or death that occurs pursuant to any information received, or misuse of the information contained in this application. In no event shall the developer be liable for any special, incidental, indirect or consequential damages of any kind, or any damages whatsoever, including without limitation, those resulting from reliance on the materials presented and any theory of liability, arising out of or in connection with the use of this application.
                        
                        - The developer may at any time revise these terms and conditions by updating this notice and/or the content in the application.  By using this application, you agree to be bound by any such revisions and should therefore periodically read this disclaimer, as amended, to determine the current terms and conditions of use for which you are bound.
                        
                        If you do not agree to the terms and conditions of use as stated above, then please close and uninstall the application from your device. If you have read and accepted the terms and conditions above, then please press the button below to enter the application.
                        
                        I am at or above the legal age of majority and/or I have permission from a legal guardian to use this App. I have read and accept these terms and conditions of use.
                        """)
                        .font(.system(.body, design: .serif))
                        .lineSpacing(4)
                    }
                    .padding()
                }
                
                // Bottom Actions
                VStack(spacing: 12) {
                    Button(action: {
                        hasAcceptedDisclaimer = true
                    }) {
                        Text("AGREE & CONTINUE")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(role: .destructive, action: {
                        // Cleanly exit the app
                        exit(0)
                    }) {
                        Text("QUIT")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.bottom, 10)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled() // Prevents swiping down to dismiss
    }
}
