//
//  RelativePositioningView.swift
//  PopoversPlaygroundApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI
import Popovers

struct RelativePositioningView: View {
    @State var present = false
    
    var body: some View {
        ExampleRow(
            image: "rectangle.inset.topleft.fill",
            title: "Relative Positioning",
            color: 0xEB4DA0
        ) {
            present.toggle()
        }
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset = UIEdgeInsets(16)
                $0.position = .relative(
                    popoverAnchors: [
                        .topLeft,
                        .topRight,
                        .bottomRight,
                        .bottomLeft,
                        .center
                    ]
                )
            }
        ) {
            VStack(alignment: .leading) {
                Text("Relative positioning means the popover is positioned within a container view.")
                
                HStack {
                    ExampleImage("arrow.up.left.and.down.right.and.arrow.up.right.and.down.left", color: 0xEB4DA0)
                    Text("You can provide multiple anchors in an array!")
                }
                
                HStack {
                    ExampleImage("hand.draw", color: 0xEB4DA0)
                    Text("Try dragging.")
                }
                
                HStack {
                    ExampleImage.tip
                    Text("By default, the entire screen is used as the container view.")
                }
                
            }
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(radius: 1)
            .frame(maxWidth: 500)
        }
    }
}
