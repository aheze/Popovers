//
//  MenuView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct MenuView: View {
    @State var present = false
    @State var iconName = "list.bullet"

    var body: some View {
        PopoverMenu {
            PopoverMenuButton {
                iconName = "list.bullet"
            } label: {
                Label("Change Icon To List", systemImage: "list.bullet")
            }

            PopoverMenuButton {
                iconName = "keyboard"
            } label: {
                Label("Change Icon To Keyboard", systemImage: "keyboard")
            }

            PopoverMenuButton {
                iconName = "bag"
            } label: {
                Label("Change Icon To Bag", systemImage: "bag")
            }
        } label: { isPressed in
            ExampleShowroomRow(color: UIColor(hex: 0xFF00AB)) {
                HStack {
                    ExampleImage(iconName, color: UIColor(hex: 0xFF00AB))

                    Text("Context Menu")
                        .fontWeight(.medium)
                }
            }
            .opacity(isPressed ? 0.5 : 1)
        }

        Menu {
            Button {
                iconName = "list.bullet"
            } label: {
                Label("Change Icon To List", systemImage: "list.bullet")
            }

            Button {
                iconName = "keyboard"
            } label: {
                Label("Change Icon To Keyboard", systemImage: "keyboard")
            }

            Button {
                iconName = "bag"
            } label: {
                Label("Change Icon To Bag", systemImage: "bag")
            }

        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0xFF00AB)) {
                HStack {
                    ExampleImage(iconName, color: UIColor(hex: 0xFF00AB))

                    Text("Context Menu")
                        .fontWeight(.medium)
                }
            }
        }
    }
}

//struct MenuViewPopover: View {
//    @Binding var present: Bool
//    @Binding var iconName: String
//
//    var body: some View {
//        PopoverTemplates.Menu {
//            PopoverTemplates.MenuButton {
//                iconName = "list.bullet"
//            } label: {
//                Label("Change Icon To List", systemImage: "list.bullet")
//            }
//
//            PopoverTemplates.MenuButton {
//                iconName = "keyboard"
//            } label: {
//                Label("Change Icon To Keyboard", systemImage: "keyboard")
//            }
//
//            PopoverTemplates.MenuButton {
//                iconName = "bag"
//            } label: {
//                Label("Change Icon To Bag", systemImage: "bag")
//            }
//        } label: { isPressed in
//            ExampleShowroomRow(color: UIColor(hex: 0xFF00AB)) {
//                HStack {
//                    ExampleImage(iconName, color: UIColor(hex: 0xFF00AB))
//
//                    Text("Context Menu")
//                        .fontWeight(.medium)
//                }
//            }
//        }
//    }
//}
