//
//  Container.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension Templates {
    /**
     A standard container for popovers, complete with arrow.
     */
    struct Container<Content: View>: View {
        /// Which side to place the arrow on.
        public var arrowSide: ArrowSide?

        /// The container's corner radius.
        public var cornerRadius = CGFloat(12)

        /// The container's background/fill color.
        public var backgroundColor = Color(.systemBackground)

        /// The padding around the content view.
        public var padding = CGFloat(16)

        /// The content view.
        @ViewBuilder public var view: Content

        /**
         A standard container for popovers, complete with arrow.
         - parameter arrowSide: Which side to place the arrow on.
         - parameter cornerRadius: The container's corner radius.
         - parameter backgroundColor: The container's background/fill color.
         - parameter padding: The padding around the content view.
         - parameter view: The content view.
         */
        public init(
            arrowSide: Templates.ArrowSide? = nil,
            cornerRadius: CGFloat = CGFloat(12),
            backgroundColor: Color = Color(.systemBackground),
            padding: CGFloat = CGFloat(16),
            @ViewBuilder view: () -> Content
        ) {
            self.arrowSide = arrowSide
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.padding = padding
            self.view = view()
        }

        public var body: some View {
            PopoverReader { context in
                view
                    .padding(padding)
                    .background(
                        BackgroundWithArrow(
                            arrowSide: arrowSide ?? context.attributes.position.getArrowPosition(),
                            cornerRadius: cornerRadius
                        )
                        .fill(backgroundColor)
                        .shadow(
                            color: Color(.label.withAlphaComponent(0.25)),
                            radius: 40,
                            x: 0,
                            y: 4
                        )
                    )
            }
        }
    }

    /// The side of the popover that the arrow should be placed on.
    /**

                          top
            X──────────────X──────────────X
            |                             |
            |                             |
      left  X                             X  right
            |                             |
            |                             |
            X──────────────X──────────────X
                         bottom
     */
    enum ArrowSide {
        case top(ArrowAlignment)
        case right(ArrowAlignment)
        case bottom(ArrowAlignment)
        case left(ArrowAlignment)

        /// Place the arrow on the left, middle, or right on a side.
        /**

            mostCounterClockwise    centered          mostClockwise
            ────X──────────────────────X──────────────────────X────
            |                                                     |
                        * diagram is for `ArrowSide.top`
         */
        public enum ArrowAlignment {
            case mostCounterClockwise
            case centered
            case mostClockwise
        }
    }
}
