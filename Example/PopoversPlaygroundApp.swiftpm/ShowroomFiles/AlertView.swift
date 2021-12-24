//
//  AlertView.swift
//  PopoversPlaygroundApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI
import Popovers

struct AlertView: View {
    @State var present = false
    @State var expanding = false
    
    var body: some View {
        Button {
            present = true
        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0xFF4700)) {
                HStack {
                    ExampleImage("exclamationmark.triangle.fill", color: UIColor(hex: 0xFF4700))
                    
                    Text("Alert")
                        .fontWeight(.medium)
                }
            }
        }
        .popover(
            present: $present,
            attributes: {
                $0.blocksBackgroundTouches = true
                $0.rubberBandingMode = .none
                $0.position = .relative(
                    popoverAnchors: [
                        .center
                    ]
                )
                $0.presentation.animation = .easeOut(duration: 0.15)
                $0.dismissal.mode = .none
                $0.onTapOutside = {
                    withAnimation(.easeIn(duration: 0.15)) {
                        expanding = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {              
                        withAnimation(.easeOut(duration: 0.4)) { 
                            expanding = false
                        }
                    }
                }
            }
        ) {
            AlertViewPopover(present: $present, expanding: $expanding)
        } background: {
            Color.black.opacity(0.1)
        }
    }
}

struct AlertViewPopover: View {
    @Binding var present: Bool
    @Binding var expanding: Bool
    
    /// the initial animation
    @State var scaled = true
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Alert!")
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text("Popovers has used your location 2000 times in the past 7 days.")
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Divider()
            
            Button {
                present = false
            } label: {
                Text("Ok")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PopoverTemplates.AlertButtonStyle())
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .popoverContainerShadow()
        .frame(width: 260)
        .scaleEffect(expanding ? 1.05 : 1)
        .scaleEffect(scaled ? 2 : 1)
        .opacity(scaled ? 0 : 1)
        .onAppear { 
            withAnimation(.spring(
                response: 0.4,
                dampingFraction: 0.9,
                blendDuration: 1
            )) {
                scaled = false
            }
        }
    }
}
