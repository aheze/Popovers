//
//  Menu+UIKit.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

public extension Templates {
    /// A built-from-scratch version of the system menu, for UIKit.
    class UIKitMenu<Views>: NSObject {
        // MARK: - Menu properties

        /// A unique ID for the menu (to support multiple menus in the same screen).
        var id = UUID()

        /// If the user is pressing down on the label, this will be a unique `UUID`.
        var labelPressUUID: UUID?

        /**
         If the label was pressed/dragged when the menu was already presented.
         In this case, dismiss the menu if the user lifts their finger on the label.
         */
        var labelPressedWhenAlreadyPresented = false

        /// The current position of the user's finger.
        var dragPosition: CGPoint?

        /// View model for the menu buttons.
        var model = MenuModel()

        /// Attributes that determine what the menu looks like.
        public let configuration: MenuConfiguration

        /// The menu buttons.
        public let content: TupleView<Views>

        /// The origin label.
        public let sourceView: UIView

        /// Fade the origin label.
        var fadeLabel = false

        // MARK: - UIKit properties

        var popover: Popover?
        var longPressGestureRecognizer: UILongPressGestureRecognizer!

        /// A built-from-scratch version of the system menu, for UIKit.
        public init(
            sourceView: UIView,
            configuration: MenuConfiguration = .init(),
            @ViewBuilder content: @escaping () -> TupleView<Views>
        ) {
            self.sourceView = sourceView
            self.configuration = configuration
            self.content = content()
            super.init()

            addPopover()
            addGestureRecognizer()
        }

        /// Set up the popover.
        func addPopover() {
            var popover = Popover { [weak self] in
                if let self = self {
                    MenuView(
                        model: self.model,
                        present: { [weak self] present in
                            self?.setPresentManually(present: present)
                        },
                        configuration: self.configuration,
                        content: self.content.getViews
                    )
                }
            } background: { [weak self] in
                if let self = self {
                    self.configuration.backgroundColor
                }
            }

            popover.attributes.sourceFrame = { [weak sourceView] in sourceView.windowFrame() }
            popover.attributes.position = .absolute(originAnchor: configuration.originAnchor, popoverAnchor: configuration.popoverAnchor)
            popover.attributes.rubberBandingMode = .none
            popover.attributes.dismissal.excludedFrames = { [weak self] in
                guard let self = self else { return [] }
                return [self.sourceView.window.frameTagged(self.id)]
            }
            popover.attributes.sourceFrameInset = configuration.sourceFrameInset

            /// Make sure to set `model.present` back to false when the menu is dismissed.
            popover.context.onAutoDismiss = { [weak self] in
                self?.model.present = false
            }

            self.popover = popover
        }

        /// Set up the drag gesture recognizer (enable "pull-down" behavior).
        func addGestureRecognizer() {
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dragged))
            longPressGestureRecognizer.minimumPressDuration = 0
            sourceView.addGestureRecognizer(longPressGestureRecognizer)
            sourceView.isUserInteractionEnabled = true
        }

        @objc func dragged(_ gestureRecognizer: UILongPressGestureRecognizer) {
            let location = gestureRecognizer.location(in: nil)
            dragPosition = location

            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                MenuModel.onDragChanged(
                    location: location,
                    model: model,
                    id: id,
                    labelPressUUID: &labelPressUUID,
                    labelFrame: sourceView.windowFrame(),
                    configuration: configuration,
                    window: sourceView.window,
                    fadeLabel: &fadeLabel,
                    labelPressedWhenAlreadyPresented: &labelPressedWhenAlreadyPresented
                ) { [weak self] in
                    self?.labelPressUUID
                } getDragPosition: { [weak self] in
                    self?.dragPosition
                } present: { [weak self] present in
                    self?.setPresentManually(present: present)
                }
            } else {
                MenuModel.onDragEnded(
                    location: location,
                    model: model,
                    id: id,
                    labelPressUUID: &labelPressUUID,
                    labelFrame: sourceView.windowFrame(),
                    configuration: configuration,
                    window: sourceView.window,
                    fadeLabel: &fadeLabel,
                    labelPressedWhenAlreadyPresented: &labelPressedWhenAlreadyPresented
                ) { [weak self] present in
                    self?.setPresentManually(present: present)
                }
            }
        }

        /**
         Set `model.present` and show/hide the popover.

         This is called when a menu button is pressed,
         or some other action happened that should hide the menu.
         This is **not** called when the user taps outside the menu,
         since the menu would already be automatically dismissed.
         */
        func setPresentManually(present: Bool) {
            model.present = present
            if
                present,
                let window = sourceView.window
            {
                popover?.present(in: window)
            } else {
                popover?.dismiss()
            }
        }
    }
}

public extension UIView {
    func addMenu<Views>(menu: Templates.UIKitMenu<Views>) {}
}
