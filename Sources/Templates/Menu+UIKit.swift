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
    class UIKitMenu: NSObject {
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
        var dragLocation: CGPoint?

        /// View model for the menu buttons.
        var model = MenuModel()

        /// Attributes that determine what the menu looks like.
        public let configuration: MenuConfiguration

        /// The menu buttons.
        public let content: [AnyView]

        /// The origin label.
        public let sourceView: UIView

        /// Fade the origin label.
        var fadeLabel: ((Bool) -> Void)?

        // MARK: - UIKit properties

        var popover: Popover?
        var longPressGestureRecognizer: UILongPressGestureRecognizer!

        /**
         A built-from-scratch version of the system menu, for UIKit.
         This initializer lets you pass in a multiple menu items.
         */
        public init<Contents>(
            sourceView: UIView,
            configuration buildConfiguration: @escaping ((inout MenuConfiguration) -> Void) = { _ in },
            @ViewBuilder content: @escaping () -> TupleView<Contents>,
            fadeLabel: ((Bool) -> Void)? = nil
        ) {
            self.sourceView = sourceView

            var configuration = MenuConfiguration()
            buildConfiguration(&configuration)
            self.configuration = configuration

            self.content = ViewExtractor.getViews(from: content)
            self.fadeLabel = fadeLabel
            super.init()

            addGestureRecognizer()
        }

        /**
         A built-from-scratch version of the system menu, for UIKit.
         This initializer lets you pass in a single menu item.
         */
        public init<Content: View>(
            sourceView: UIView,
            configuration buildConfiguration: @escaping ((inout MenuConfiguration) -> Void) = { _ in },
            @ViewBuilder content: @escaping () -> Content,
            fadeLabel: ((Bool) -> Void)? = nil
        ) {
            self.sourceView = sourceView

            var configuration = MenuConfiguration()
            buildConfiguration(&configuration)
            self.configuration = configuration

            self.content = [AnyView(content())]
            self.fadeLabel = fadeLabel
            super.init()

            addGestureRecognizer()
        }

        /// Set up the drag gesture recognizer (enable "pull-down" behavior).
        func addGestureRecognizer() {
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dragged))
            longPressGestureRecognizer.minimumPressDuration = 0
            sourceView.addGestureRecognizer(longPressGestureRecognizer)
            sourceView.isUserInteractionEnabled = true
        }

        @objc func dragged(_ gestureRecognizer: UILongPressGestureRecognizer) {
            let location = gestureRecognizer.location(in: sourceView.window)
            dragLocation = location

            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                MenuModel.onDragChanged(
                    location: location,
                    model: model,
                    id: id,
                    labelPressUUID: &labelPressUUID,
                    labelFrame: sourceView.windowFrame(),
                    configuration: configuration,
                    window: sourceView.window,
                    labelPressedWhenAlreadyPresented: &labelPressedWhenAlreadyPresented
                ) { [weak self] in
                    self?.labelPressUUID
                } getDragLocation: { [weak self] in
                    self?.dragLocation
                } present: { [weak self] present in
                    self?.updatePresent(present)
                } fadeLabel: { [weak self] fade in
                    self?.fadeLabel?(fade)
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
                    labelPressedWhenAlreadyPresented: &labelPressedWhenAlreadyPresented
                ) { [weak self] present in
                    self?.updatePresent(present)
                } fadeLabel: { [weak self] fade in
                    self?.fadeLabel?(fade)
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
        func updatePresent(_ present: Bool) {
            model.present = present
            if
                present,
                let window = sourceView.window
            {
                presentPopover()
                popover?.present(in: window)
                fadeLabel?(true)
            } else {
                popover?.dismiss()
                popover = nil
                fadeLabel?(false)
            }
        }

        /// Present the menu popover.
        func presentPopover() {
            var popover = Popover { [weak self] in
                if let self = self {
                    MenuView(
                        model: self.model,
                        present: { [weak self] present in
                            self?.updatePresent(present)
                        },
                        configuration: self.configuration,
                        content: self.content
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
                return [
                    self.sourceView.windowFrame()
                ]
                    + self.configuration.excludedFrames()
            }
            popover.attributes.sourceFrameInset = configuration.sourceFrameInset

            /**
             Make sure to set `model.present` back to false when the menu is dismissed.
             Don't call `updatePresent`, since the popover has already been automatically dismissed.
             */
            popover.context.onAutoDismiss = { [weak self] in
                self?.model.present = false
                self?.fadeLabel?(false)
            }

            self.popover = popover
        }
    }
}

/// Control menu state externally.
public extension Templates.UIKitMenu {
    /// Whether the menu is currently presented or not.
    var isPresented: Bool {
        model.present
    }

    /// Present the menu.
    func present() {
        updatePresent(true)
    }

    /// Dismiss the menu.
    func dismiss() {
        updatePresent(false)
    }
}
