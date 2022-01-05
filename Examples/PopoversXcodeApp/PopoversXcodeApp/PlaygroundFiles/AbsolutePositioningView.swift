//
//  AbsolutePositioningView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct AbsolutePositioningView: View {
    @State var present = false

    var body: some View {
        ExampleRow(
            image: "squareshape.controlhandles.on.squareshape.controlhandles",
            title: "Absolute Positioning",
            color: 0x7E52F5
        ) {
            present.toggle()
        }
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset.top = -8
                $0.position = .absolute(
                    originAnchor: .bottomRight,
                    popoverAnchor: .topRight
                )
            }
        ) {
            VStack(alignment: .leading) {
                Text("Absolute positioning means that the popover is attached to a source view. This is the default.")

                HStack {
                    ExampleImage("arrow.down.right", color: 0x7E52F5)
                    Text("The bottom-right of the source view is used as the origin.")
                }

                HStack {
                    ExampleImage("arrow.up.right", color: 0x7E52F5)
                    Text("The top-right of the popover attaches to the origin.")
                }

                HStack {
                    ExampleImage.warning
                    Text("Positioning may be modified to prevent overflowing off the screen.")
                }
            }
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(radius: 1)
        }
    }
}
