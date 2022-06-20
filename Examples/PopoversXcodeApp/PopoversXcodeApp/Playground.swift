//
//  Playground.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct Playground: View {
    var body: some View {
        Section(
            header:
            Text("Playground")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        ) {
            Group {
                UIKitMenuView()
                BasicView()
                CustomizedView()
                AbsolutePositioningView()
                RelativePositioningView()
                LifecycleView()
            }
            Group {
                DismissalView1()
                DismissalView2()
                FrameTaggedView()
                BackgroundView()
                PopoverReaderView()
            }

            Group {
                NestedView()
                SelectionView()
            }

            Group {
                AccessibilityView()
            }
        }
    }
}
