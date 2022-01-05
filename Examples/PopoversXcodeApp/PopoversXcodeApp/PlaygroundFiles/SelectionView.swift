//
//  SelectionView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct SelectionView: View {
    @State var present = false
    @State var selection: String?

    var body: some View {
        ExampleRow(
            image: "checkmark.circle.fill",
            title: "Selection",
            color: 0x413FFF
        ) {
            present.toggle()
        }
        .popover(
            present: $present,
            attributes: {
                $0.position = .relative(
                    popoverAnchors: [
                        .center,
                    ]
                )
            }
        ) {
            VStack {
                Text("Up until now, all the popovers were presented using `$present`. If you have multiple related popovers, use `$selection` + `tag` instead for a smooth animation.")

                HStack {
                    SelectionViewButton(selection: $selection, tag: "0")
                    SelectionViewButton(selection: $selection, tag: "1")
                    SelectionViewButton(selection: $selection, tag: "2")
                    SelectionViewButton(selection: $selection, tag: "3")
                    SelectionViewButton(selection: $selection, tag: "4")
                    SelectionViewButton(selection: $selection, tag: "5")
                }
                .padding()
                .background(Color(uiColor: UIColor(hex: 0x413FFF)).opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(radius: 1)
            .frame(maxWidth: 300)
        }
    }
}

struct SelectionViewButton: View {
    @Binding var selection: String?
    let tag: String

    var body: some View {
        Button {
            selection = tag
        } label: {
            ExampleImage("\(tag).circle.fill", color: 0x413FFF)
        }
        .popover(
            selection: $selection,
            tag: tag
        ) {
            HStack {
                ForEach(0 ..< (1 + (Int(tag) ?? 0)), id: \.self) { index in
                    Color.blue
                        .frame(width: 30, height: 30)
                        .cornerRadius(8)
                        .overlay {
                            Text("\(index)")
                                .foregroundColor(.white)
                        }
                }
            }
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(radius: 1)
            .zIndex(1)
        }
    }
}
