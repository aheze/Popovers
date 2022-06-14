//
//  MenuModel.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension Templates {
    class MenuModel: ObservableObject {
        /// Whether to show the popover or not.
        @Published var present = false

        /// The popover's scale (for rubber banding).
        @Published var scale = CGFloat(1)

        /// The index of the menu button that the user's finger hovers on.
        @Published var hoveringItemID: UUID?

        /// The selected menu button if it exists.
        @Published var selectedItemID: UUID?

        /// The frames of the menu buttons, relative to the window.
        @Published var frames = [UUID: CGRect]()

        /// The frame of the menu in global coordinates.
        @Published var menuFrame = CGRect.zero

        /// Get the menu button ID that intersects the drag gesture's touch location.
        func getItemID(from location: CGPoint) -> UUID? {
            for (itemID, frame) in frames {
                if frame.contains(location) {
                    return itemID
                }
            }
            return nil
        }

        func getDistanceFromMenu(from location: CGPoint) -> CGFloat? {
            let menuCenter = CGPoint(x: menuFrame.midX, y: menuFrame.midY)

            /// The location relative to the popover menu's center (0, 0)
            let normalizedLocation = CGPoint(x: location.x - menuCenter.x, y: location.y - menuCenter.y)

            if abs(normalizedLocation.y) >= menuFrame.height / 2, abs(normalizedLocation.y) >= abs(normalizedLocation.x) {
                /// top and bottom
                let distance = abs(normalizedLocation.y) - menuFrame.height / 2
                return distance
            } else {
                /// left and right
                let distance = abs(normalizedLocation.x) - menuFrame.width / 2
                return distance
            }
        }

        /// Get the anchor point to scale from.
        func getScaleAnchor(from context: Popover.Context) -> UnitPoint {
            if case let .absolute(_, popoverAnchor) = context.attributes.position {
                return popoverAnchor.unitPoint
            }

            return .center
        }
    }
}
