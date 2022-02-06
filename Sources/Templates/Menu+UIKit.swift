//
//  Menu+UIKit.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension Templates {
    class UIKitMenu<Views> {
        
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
        public let label: UIView

        /// Fade the origin label.
        var fadeLabel = false
        
        // MARK: - UIKit properties
        var panGestureRecognizer: UIPanGestureRecognizer!

        init(
            label: UIView,
            configuration: MenuConfiguration = .init(),
            @ViewBuilder content: @escaping () -> TupleView<Views>
        ) {
            self.label = label
            self.configuration = configuration
            self.content = content()
            addGestureRecognizer()
        }

        func addGestureRecognizer() {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
            self.panGestureRecognizer = panGestureRecognizer
            label.addGestureRecognizer(panGestureRecognizer)
        }
        
        @objc func panned(_ gestureRecognizer: UIPanGestureRecognizer) {
            print("Panned!")
        }
    }
}

extension UIView {
    func addMenu() {}
}
