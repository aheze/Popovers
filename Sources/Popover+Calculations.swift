//
//  Popover+Calculations.swift
//
//
//  Created by A. Zheng (github.com/aheze) on 3/19/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

#if os(iOS)
import SwiftUI

public extension Popover {
    /// Updates the popover's frame using its size.
    func updateFrame(with size: CGSize?) {
        let frame = calculateFrame(from: size)
        context.size = size
        context.staticFrame = frame
        context.frame = frame
    }

    /// Calculate the popover's frame based on its size and position.
    func calculateFrame(from size: CGSize?) -> CGRect {
        guard let window = context.presentedPopoverViewController?.view.window else { return .zero }

        switch attributes.position {
        case let .absolute(originAnchor, popoverAnchor):
            var popoverFrame = attributes.position.absoluteFrame(
                originAnchor: originAnchor,
                popoverAnchor: popoverAnchor,
                originFrame: attributes.sourceFrame().inset(by: attributes.sourceFrameInset()),
                popoverSize: size ?? .zero
            )

            let screenEdgePadding = attributes.screenEdgePadding()

//            context.presentedPopoverViewController?.view.safeAreaInsets
            let safeWindowFrame = window.safeAreaLayoutGuide.layoutFrame
            let maxX = safeWindowFrame.maxX - screenEdgePadding.right
            let maxY = safeWindowFrame.maxY - screenEdgePadding.bottom

            /// Popover overflows on left/top side.
            if popoverFrame.origin.x < screenEdgePadding.left {
                popoverFrame.origin.x = screenEdgePadding.left
            }
            if popoverFrame.origin.y < screenEdgePadding.top {
                popoverFrame.origin.y = screenEdgePadding.top
            }

            /// Popover overflows on the right/bottom side.
            if popoverFrame.maxX > maxX {
                let difference = popoverFrame.maxX - maxX
                popoverFrame.origin.x -= difference
            }
            if popoverFrame.maxY > maxY {
                let difference = popoverFrame.maxY - maxY
                popoverFrame.origin.y -= difference
            }

            return popoverFrame
        case let .relative(popoverAnchors):

            /// Set the selected anchor to the first one.
            if context.selectedAnchor == nil {
                context.selectedAnchor = popoverAnchors.first
            }

            let popoverFrame = attributes.position.relativeFrame(
                selectedAnchor: context.selectedAnchor ?? popoverAnchors.first ?? .bottom,
                containerFrame: attributes.sourceFrame().inset(by: attributes.sourceFrameInset()),
                popoverSize: size ?? .zero
            )

            return popoverFrame
        }
    }

    /// Calculate if the popover should be dismissed via drag **or** animated to another position (if using `.relative` positioning with multiple anchors). Called when the user stops dragging the popover.
    func positionChanged(to point: CGPoint) {
        let windowBounds = context.windowBounds

        if
            attributes.dismissal.mode.contains(.dragDown),
            point.y >= windowBounds.height - windowBounds.height * attributes.dismissal.dragDismissalProximity
        {
            if attributes.dismissal.dragMovesPopoverOffScreen {
                var newFrame = context.staticFrame
                newFrame.origin.y = windowBounds.height
                context.staticFrame = newFrame
                context.frame = newFrame
            }
            dismiss()
            return
        }
        if
            attributes.dismissal.mode.contains(.dragUp),
            point.y <= windowBounds.height * attributes.dismissal.dragDismissalProximity
        {
            if attributes.dismissal.dragMovesPopoverOffScreen {
                var newFrame = context.staticFrame
                newFrame.origin.y = -newFrame.height
                context.staticFrame = newFrame
                context.frame = newFrame
            }
            dismiss()
            return
        }
        if
            attributes.changeLocationOnDismiss
        {
            context.staticFrame = context.frame
            return
        }

        if case let .relative(popoverAnchors) = attributes.position {
            let frame = attributes.sourceFrame().inset(by: attributes.sourceFrameInset())
            let size = context.size ?? .zero

            let closestAnchor = attributes.position.relativeClosestAnchor(
                popoverAnchors: popoverAnchors,
                containerFrame: frame,
                popoverSize: size,
                targetPoint: point
            )
            let popoverFrame = attributes.position.relativeFrame(
                selectedAnchor: closestAnchor,
                containerFrame: frame,
                popoverSize: size
            )

            context.selectedAnchor = closestAnchor
            context.staticFrame = popoverFrame
            context.frame = popoverFrame
        }
    }
}
#endif
