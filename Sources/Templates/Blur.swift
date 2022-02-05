//
//  Blur.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension Templates {
    /// Use UIKit blurs in SwiftUI.
    struct VisualEffectView: UIViewRepresentable {
        /// The blur's style.
        public var style: UIBlurEffect.Style

        /// Use UIKit blurs in SwiftUI.
        public init(_ style: UIBlurEffect.Style) {
            self.style = style
        }

        public func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
            UIVisualEffectView()
        }

        public func updateUIView(_ uiView: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) {
            uiView.effect = UIBlurEffect(style: style)
        }
    }
}
