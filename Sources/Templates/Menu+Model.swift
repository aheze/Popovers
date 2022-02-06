//
//  Menu+Model.swift
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
        @Published var hoveringIndex: Int?

        /// The selected menu button if it exists.
        @Published var selectedIndex: Int?

        /// The frames of the menu buttons, relative to the window.
        @Published var sizes: [MenuItemSize] = []

        /**
         The indices of tappable menu buttons.
         `getIndex` will only return indices that are contained in here.
         */
        @Published var itemIndices = [Int]()

        /// The frame of the menu in global coordinates.
        @Published var menuFrame = CGRect.zero

        /// Get the menu button index that intersects the drag gesture's touch location.
        func getIndex(from location: CGPoint) -> Int? {
            /// Create frames from the sizes.
            var frames = [Int: CGRect]()
            for item in sizes {
                let previousSizes = sizes.filter { $0.index < item.index }
                let previousHeight = previousSizes.map { $0.size.height }.reduce(0, +)
                let frame = CGRect(x: 0, y: previousHeight, width: item.size.width, height: item.size.height)
                frames[item.index] = frame
            }

            let zeroedLocation = CGPoint(x: location.x - menuFrame.minX, y: location.y - menuFrame.minY)

            for (index, frame) in frames {
                if
                    frame.contains(zeroedLocation),
                    itemIndices.contains(index) /// Make sure that the index is a tappable button.
                {
                    return index
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

        /// Process the drag gesture, updating the menu to match.
        static func onDragChanged(
            location: CGPoint,
            model: MenuModel,
            id: UUID,
            labelPressUUID: inout UUID?,
            labelFrame: CGRect,
            configuration: MenuConfiguration,
            window: UIWindow?,
            labelPressedWhenAlreadyPresented: inout Bool,
            getCurrentLabelPressUUID: @escaping (() -> UUID?),
            getDragLocation: @escaping (() -> CGPoint?),
            present: @escaping ((Bool) -> Void),
            fadeLabel: @escaping ((Bool) -> Void)
        ) {
            if model.present == false {
                /// The menu is not yet presented.
                if labelPressUUID == nil {
                    labelPressUUID = UUID()
                    let currentUUID = labelPressUUID
                    DispatchQueue.main.asyncAfter(deadline: .now() + configuration.holdDelay) {
                        if
                            currentUUID == getCurrentLabelPressUUID(),
                            let dragLocation = getDragLocation()
                        {
                            if labelFrame.contains(dragLocation) {
                                present(true)
                            }
                        }
                    }
                }

                withAnimation(configuration.labelFadeAnimation) {
                    let shouldFade = labelFrame.contains(location)
                    fadeLabel(shouldFade)
                }
            } else if labelPressUUID == nil {
                /// The menu was already presented.
                labelPressUUID = UUID()
                labelPressedWhenAlreadyPresented = true
            } else {
                /// Highlight the button that the user's finger is over.
                model.hoveringIndex = model.getIndex(from: location)

                /// Rubber-band the menu.
                withAnimation {
                    if let distance = model.getDistanceFromMenu(from: location) {
                        if configuration.scaleRange.contains(distance) {
                            let percentage = (distance - configuration.scaleRange.lowerBound) / (configuration.scaleRange.upperBound - configuration.scaleRange.lowerBound)
                            let scale = 1 - (1 - configuration.minimumScale) * percentage
                            model.scale = scale
                        } else if distance < configuration.scaleRange.lowerBound {
                            model.scale = 1
                        } else {
                            model.scale = configuration.minimumScale
                        }
                    }
                }
            }
        }

        /// Process the drag gesture ending, updating the menu to match.
        static func onDragEnded(
            location: CGPoint,
            model: MenuModel,
            id: UUID,
            labelPressUUID: inout UUID?,
            labelFrame: CGRect,
            configuration: MenuConfiguration,
            window: UIWindow?,
            labelPressedWhenAlreadyPresented: inout Bool,
            present: @escaping ((Bool) -> Void),
            fadeLabel: @escaping ((Bool) -> Void)
        ) {
            withAnimation {
                model.scale = 1
            }

            labelPressUUID = nil

            /// The user started long pressing when the menu was **already** presented.
            if labelPressedWhenAlreadyPresented {
                labelPressedWhenAlreadyPresented = false

                let selectedIndex = model.getIndex(from: location)
                model.selectedIndex = selectedIndex
                model.hoveringIndex = nil

                /// The user lifted their finger on the label **and** it did not hit a menu item.
                if
                    selectedIndex == nil,
                    labelFrame.contains(location)
                {
                    present(false)
                }
            } else {
                if !model.present {
                    if labelFrame.contains(location) {
                        present(true)
                    } else {
                        withAnimation(configuration.labelFadeAnimation) {
                            fadeLabel(false)
                        }
                    }
                } else {
                    let selectedIndex = model.getIndex(from: location)
                    model.selectedIndex = selectedIndex
                    model.hoveringIndex = nil

                    /// The user lifted their finger on a button.
                    if selectedIndex != nil {
                        present(false)
                    }
                }
            }
        }
    }
}
