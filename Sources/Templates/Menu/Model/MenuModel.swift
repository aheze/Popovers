//
//  MenuModel.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

#if os(iOS)
import SwiftUI

extension Templates {
    typealias MenuItemID = UUID
    class MenuModel: ObservableObject {
        var buildConfiguration: ((inout MenuConfiguration) -> Void) = { _ in }

        var configuration: MenuConfiguration {
            var configuration = MenuConfiguration()
            buildConfiguration(&configuration)
            return configuration
        }

        /// A unique ID for the menu (to support multiple menus in the same screen).
        @Published var id = UUID()

        /// Whether to show the popover or not.
        @Published var present = false

        /// The popover's scale (for rubber banding).
        @Published var scale = CGFloat(1)

        /// The index of the menu button that the user's finger hovers on.
        @Published var hoveringItemID: MenuItemID?

        /// The selected menu button if it exists.
        @Published var selectedItemID: MenuItemID?

        /// The frames of the menu buttons, relative to the window.
        @Published var frames = [MenuItemID: CGRect]()

        /// The frame of the menu in global coordinates.
        @Published var menuFrame = CGRect.zero

        init(buildConfiguration: @escaping ((inout MenuConfiguration) -> Void) = { _ in }) {
            self.buildConfiguration = buildConfiguration
        }

        /// Get the menu button ID that intersects the drag gesture's touch location.
        func getItemID(from location: CGPoint) -> MenuItemID? {
            let matchingFrames = frames.filter { $0.value.contains(location) }

            if matchingFrames.count > 1 {
                print("[Popovers] Multiple menu items have the same frame. Make sure items don't overlay. If you can't resolve this, please file a bug report (https://github.com/aheze/Popovers/issues).")
            }

            if let frame = matchingFrames.first {
                return frame.key
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

#endif
