//
//  StandardView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct StandardView: View {
    @State var present = false

    var body: some View {
        Button {
            present = true
        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0x474747)) {
                HStack {
                    ExampleImage("arrowtriangle.down.fill", color: UIColor(hex: 0x474747))

                    Text("Standard")
                        .fontWeight(.medium)
                }
            }
        }
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset.top = -8
                $0.position = .absolute(
                    originAnchor: .top,
                    popoverAnchor: .bottom
                )
            }
        ) {
            Templates.Container {
                Text("This is a pretty standard-looking popover with an arrow.")
            }
            .frame(maxWidth: 300)
        }
    }
}
