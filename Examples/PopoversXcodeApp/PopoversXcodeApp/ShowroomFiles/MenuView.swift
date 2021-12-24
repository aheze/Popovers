//
//  MenuView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI
import Popovers

struct MenuView: View {
    @State var present = false
    @State var iconName = "list.bullet"
    
    var body: some View {
        Button {
            present = true
        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0xFF00AB)) {
                HStack {
                    ExampleImage(iconName, color: UIColor(hex: 0xFF00AB))
                    
                    Text("Context Menu")
                        .fontWeight(.medium)
                }
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5, maximumDistance: 60)
                .onEnded { value in
                    present = true
                }
        )
        .popover(
            present: $present,
            attributes: {
                $0.rubberBandingMode = .none
                $0.sourceFrameInset.bottom = -8
                $0.position = .absolute(
                    originAnchor: .bottomRight,
                    popoverAnchor: .topRight
                )
            }
        ) {
            MenuViewPopover(present: $present, iconName: $iconName)
        }
    }
}

struct MenuViewPopover: View {
    @Binding var present: Bool
    @Binding var iconName: String
    
    var body: some View {
        PopoverTemplates.Menu {
            PopoverTemplates.MenuButton(title: "Change Icon To List", image: "list.bullet") {
                iconName = "list.bullet"
                present = false
            }
            PopoverTemplates.MenuButton(title: "Change Icon To Keyboard", image: "keyboard") {
                iconName = "keyboard"
                present = false
            }
            PopoverTemplates.MenuButton(title: "Change Icon To Bag", image: "bag") {
                iconName = "bag"
                present = false
            }
        }
    }
}
