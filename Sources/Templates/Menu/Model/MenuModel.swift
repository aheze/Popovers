//
//  MenuModel.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

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

// [DDAE256D-B7C0-486B-B6B7-C8B083DCE325: (174.0, 479.66666666666663, 240.0, 52.33333333333337),
// 42C6EC1B-FAA0-444E-9491-E30853EFC902: (174.0, 322.0, 240.0, 52.333333333333314),
// E4CE4864-23A4-4D47-AEC2-8D400EF20574: (174.0, 374.3333333333333, 240.0, 52.333333333333314),
// 67B83DAF-A1D4-4D33-8F36-3DB03A2F7A49: (174.0, 427.0, 240.0, 52.333333333333314),
// 8676FA7A-60C1-47D3-9EC6-291AC049EC9B: (174.0, 374.66666666666663, 240.0, 52.33333333333337),
// CC392B97-3AE5-430B-8AC8-B2981DC1E39C: (174.0, 532.6666666666666, 240.0, 52.33333333333337),
// 7E8D84EE-F96F-4A81-8F58-2D32DCBFCB78: (174.0, 480.0, 240.0, 52.33333333333326),
// DD31FEF8-B515-4C46-AAC2-FEAD88170062: (174.0, 427.3333333333333, 240.0, 52.333333333333314),
// 15E07B27-489B-49E0-9C2F-9577DD63312F: (174.0, 269.3333333333333, 240.0, 52.333333333333314)]

// [
//    15E07B27-489B-49E0-9C2F-9577DD63312F: (174.0, 269.3333333333333, 240.0, 52.333333333333314)
//    42C6EC1B-FAA0-444E-9491-E30853EFC902: (174.0, 322.0, 240.0, 52.333333333333314),
//    E4CE4864-23A4-4D47-AEC2-8D400EF20574: (174.0, 374.3333333333333, 240.0, 52.333333333333314),
//    8676FA7A-60C1-47D3-9EC6-291AC049EC9B: (174.0, 374.66666666666663, 240.0, 52.33333333333337),
//
// 67B83DAF-A1D4-4D33-8F36-3DB03A2F7A49: (174.0, 427.0, 240.0, 52.333333333333314),
//    DD31FEF8-B515-4C46-AAC2-FEAD88170062: (174.0, 427.3333333333333, 240.0, 52.333333333333314),
//    DDAE256D-B7C0-486B-B6B7-C8B083DCE325: (174.0, 479.66666666666663, 240.0, 52.33333333333337),
//
//    7E8D84EE-F96F-4A81-8F58-2D32DCBFCB78: (174.0, 480.0, 240.0, 52.33333333333326),
// CC392B97-3AE5-430B-8AC8-B2981DC1E39C: (174.0, 532.6666666666666, 240.0, 52.33333333333337),
//
//
//
// ]
