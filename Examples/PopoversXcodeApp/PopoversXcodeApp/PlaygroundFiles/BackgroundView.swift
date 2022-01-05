//
//  BackgroundView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct BackgroundView: View {
    @State var present = false

    var body: some View {
        ExampleRow(
            image: "checkerboard.rectangle",
            title: "Background",
            color: 0x5DCB72
        ) {
            present = true
        }
        .popover(present: $present) {
            VStack(alignment: .leading) {
                Text("You can put anything you want in the background.")

                HStack {
                    ExampleImage("circle", color: 0x5DCB72)
                    Text("This popover has a `Color.green` background.")
                }
            }
            .padding()
            .background(.background)
            .cornerRadius(12)
            .shadow(radius: 1)
        } background: {
            Color.green.opacity(0.4)
        }
    }
}
