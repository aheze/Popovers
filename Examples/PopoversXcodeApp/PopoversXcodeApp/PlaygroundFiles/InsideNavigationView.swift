//
//  InsideNavigationView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 2/3/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct InsideNavigationView: View {
    var body: some View {
        NavigationLink(destination: NavigationDestinationView()) {
            ExampleRow(
                image: "square.stack.3d.down.right.fill",
                title: "Inside Navigation View",
                color: 0x00AEEF
            ) {}
            .disabled(true) /// `NavigationLink` is a button already, so disable`ExampleRow`'s inner button
        }
    }
}

struct NavigationDestinationView: View {
    @State var present = false

    var body: some View {
        NavigationView {
            VStack {
                Button("Present Popover") {
                    present.toggle()
                }

                NavigationLink("Next View", destination: Text("Hi"))
            }
        }
        .popover(present: $present) {
            Text("Hello! I'm a popover. You can dismiss me by tapping outside. Also, try dragging me to get a nice bounce.")
                .padding()
                .background(.background)
                .cornerRadius(12)
                .shadow(radius: 1)
                .frame(maxWidth: 300)
        }
    }
}
