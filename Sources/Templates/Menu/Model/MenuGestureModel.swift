//
//  MenuGestureModel.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 6/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension Templates {
    class MenuGestureModel: ObservableObject {
        /// If the user is pressing down on the label, this will be a unique `UUID`.
        @Published var labelPressUUID: UUID?

        /**
         If the label was pressed/dragged when the menu was already presented.
         In this case, dismiss the menu if the user lifts their finger on the label.
         */
        @Published var labelPressedWhenAlreadyPresented = false

        /// The current position of the user's finger.
        @Published var dragLocation: CGPoint?

        /// Process the drag gesture, updating the menu to match.
        func onDragChanged(
            newDragLocation: CGPoint,
            model: MenuModel,
            labelFrame: CGRect,
            configuration: MenuConfiguration,
            window: UIWindow?,
            present: @escaping ((Bool) -> Void),
            fadeLabel: @escaping ((Bool) -> Void)
        ) {
            dragLocation = newDragLocation

            if model.present == false {
                /// The menu is not yet presented.
                if labelPressUUID == nil {
                    labelPressUUID = UUID()
                    let currentUUID = labelPressUUID
                    DispatchQueue.main.asyncAfter(deadline: .now() + configuration.holdDelay) {
                        if
                            currentUUID == self.labelPressUUID,
                            let dragLocation = self.dragLocation /// check the location once again
                        {
                            if labelFrame.contains(dragLocation) {
                                present(true)
                            }
                        }
                    }
                }

                withAnimation(configuration.labelFadeAnimation) {
                    let shouldFade = labelFrame.contains(newDragLocation)
                    fadeLabel(shouldFade)
                }
            } else if labelPressUUID == nil {
                /// The menu was already presented.
                labelPressUUID = UUID()
                labelPressedWhenAlreadyPresented = true
            } else {
                /// Highlight the button that the user's finger is over.
                model.hoveringItemID = model.getItemID(from: newDragLocation)

                /// Rubber-band the menu.
                withAnimation {
                    if let distance = model.getDistanceFromMenu(from: newDragLocation) {
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
        func onDragEnded(
            newDragLocation: CGPoint,
            model: MenuModel,
            labelFrame: CGRect,
            configuration: MenuConfiguration,
            window: UIWindow?,
            present: @escaping ((Bool) -> Void),
            fadeLabel: @escaping ((Bool) -> Void)
        ) {
            dragLocation = newDragLocation

            withAnimation {
                model.scale = 1
            }

            labelPressUUID = nil

            /// The user started long pressing when the menu was **already** presented.
            if labelPressedWhenAlreadyPresented {
                labelPressedWhenAlreadyPresented = false

                let selectedItemID = model.getItemID(from: newDragLocation)
                model.selectedItemID = selectedItemID
                model.hoveringItemID = nil

                /// The user lifted their finger on the label **and** it did not hit a menu item.
                if
                    selectedItemID == nil,
                    labelFrame.contains(newDragLocation)
                {
                    present(false)
                }
            } else {
                if !model.present {
                    if labelFrame.contains(newDragLocation) {
                        present(true)
                    } else {
                        withAnimation(configuration.labelFadeAnimation) {
                            fadeLabel(false)
                        }
                    }
                } else {
                    let selectedItemID = model.getItemID(from: newDragLocation)
                    model.selectedItemID = selectedItemID
                    model.hoveringItemID = nil

                    /// The user lifted their finger on a button.
                    if selectedItemID != nil {
                        present(false)
                    }
                }
            }
        }
    }
}
