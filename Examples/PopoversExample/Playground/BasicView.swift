//
//  BasicView.swift
//  PopoversExample
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct BasicView: View {
    @State var present = false

    var body: some View {
        ExampleRow(
            image: "square",
            title: "Basic",
            color: 0x00AEEF
        ) {
            present.toggle()
        }
        .popover(present: $present) {
            Text("Hello! I'm a popover. You can dismiss me by tapping outside. Also, try dragging me to get a nice bounce.")
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 1)
                .frame(maxWidth: 300)
        }
    }
}
