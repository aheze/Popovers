//
//  Popover+Positioning.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Extensions for popover positioning.
 */
public extension CGRect {
    /// The point at an anchor.
    /**

         topLeft              top              topRight
                X──────────────X──────────────X
                |                             |
                |                             |
         left   X            center           X   right
                |                             |
                |                             |
                X──────────────X──────────────X
         bottomLeft          bottom         bottomRight

     */
    func point(at anchor: Popover.Attributes.Position.Anchor) -> CGPoint {
        switch anchor {
        case .topLeft:
            return origin
        case .top:
            return CGPoint(
                x: origin.x + width / 2,
                y: origin.y
            )
        case .topRight:
            return CGPoint(
                x: origin.x + width,
                y: origin.y
            )
        case .right:
            return CGPoint(
                x: origin.x + width,
                y: origin.y + height / 2
            )
        case .bottomRight:
            return CGPoint(
                x: origin.x + width,
                y: origin.y + height
            )
        case .bottom:
            return CGPoint(
                x: origin.x + width / 2,
                y: origin.y + height
            )
        case .bottomLeft:
            return CGPoint(
                x: origin.x,
                y: origin.y + height
            )
        case .left:
            return CGPoint(
                x: origin.x,
                y: origin.y + height / 2
            )
        case .center:
            return CGPoint(
                x: origin.x + width / 2,
                y: origin.y + height / 2
            )
        }
    }
}

public extension Popover.Attributes.Position {
    /**
     Get the frame of a popover if it's position is `.absolute`.
     - parameter originAnchor: The popover's origin anchor.
     - parameter popoverAnchor: The anchor of the popover that attaches to `originAnchor`.
     - parameter originFrame: The source frame.
     - parameter popoverSize: The size of the popover.
     */
    func absoluteFrame(
        originAnchor: Anchor,
        popoverAnchor: Anchor,
        originFrame: CGRect,
        popoverSize: CGSize
    ) -> CGRect {
        /// Get the origin point from the origin frame.
        let popoverOrigin = originFrame.point(at: originAnchor)

        /// Adjust `popoverOrigin` to account for `popoverAnchor.`
        switch popoverAnchor {
        case .topLeft:
            return CGRect(
                origin: popoverOrigin,
                size: popoverSize
            )
        case .top:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: popoverSize.width / 2, y: 0),
                size: popoverSize
            )
        case .topRight:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: popoverSize.width, y: 0),
                size: popoverSize
            )
        case .right:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: popoverSize.width, y: popoverSize.height / 2),
                size: popoverSize
            )
        case .bottomRight:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: popoverSize.width, y: popoverSize.height),
                size: popoverSize
            )
        case .bottom:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: popoverSize.width / 2, y: popoverSize.height),
                size: popoverSize
            )
        case .bottomLeft:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: 0, y: popoverSize.height),
                size: popoverSize
            )
        case .left:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: 0, y: popoverSize.height / 2),
                size: popoverSize
            )
        case .center:
            return CGRect(
                origin: popoverOrigin - CGPoint(x: popoverSize.width / 2, y: popoverSize.height / 2),
                size: popoverSize
            )
        }
    }

    /**
     Get the origin of a popover if it's position is `.relative`. The origin is the top-left of the popover within a container frame.
     - parameter popoverAnchor: The popover's position within the container frame.
     - parameter containerFrame: The reference frame.
     - parameter popoverSize: The size of the popover.
     */
    func relativeOrigin(
        popoverAnchor: Anchor,
        containerFrame: CGRect,
        popoverSize: CGSize
    ) -> CGPoint {
        switch popoverAnchor {
        case .topLeft:
            return CGPoint(
                x: containerFrame.origin.x,
                y: containerFrame.origin.y
            )
        case .top:
            return CGPoint(
                x: containerFrame.origin.x + containerFrame.width / 2 - popoverSize.width / 2,
                y: containerFrame.origin.y
            )
        case .topRight:
            return CGPoint(
                x: containerFrame.origin.x + containerFrame.width - popoverSize.width,
                y: containerFrame.origin.y
            )
        case .right:
            return CGPoint(
                x: containerFrame.origin.x + containerFrame.width - popoverSize.width,
                y: containerFrame.origin.y + containerFrame.height / 2 - popoverSize.height / 2
            )
        case .bottomRight:
            return CGPoint(
                x: containerFrame.origin.x + containerFrame.width - popoverSize.width,
                y: containerFrame.origin.y + containerFrame.height - popoverSize.height
            )
        case .bottom:
            return CGPoint(
                x: containerFrame.origin.x + containerFrame.width / 2 - popoverSize.width / 2,
                y: containerFrame.origin.y + containerFrame.height - popoverSize.height
            )
        case .bottomLeft:
            return CGPoint(
                x: containerFrame.origin.x,
                y: containerFrame.origin.y + containerFrame.height - popoverSize.height
            )
        case .left:
            return CGPoint(
                x: containerFrame.origin.x,
                y: containerFrame.origin.y + containerFrame.height / 2 - popoverSize.height / 2
            )
        case .center:
            return CGPoint(
                x: containerFrame.origin.x + containerFrame.width / 2 - popoverSize.width / 2,
                y: containerFrame.origin.y + containerFrame.height / 2 - popoverSize.height / 2
            )
        }
    }

    /**
     Get the closest anchor to a point, if the popover's anchor is `.relative`.
     - parameter popoverAnchors: The popover's possible positions within the container frame.
     - parameter containerFrame: The reference frame.
     - parameter popoverSize: The size of the popover.
     - parameter targetPoint: The point to check for the closest anchor.
     */
    func relativeClosestAnchor(
        popoverAnchors: [Anchor],
        containerFrame: CGRect,
        popoverSize: CGSize,
        targetPoint: CGPoint
    ) -> Popover.Attributes.Position.Anchor {
        var (closestAnchor, closestDistance): (Popover.Attributes.Position.Anchor, CGFloat) = (.bottom, .infinity)
        for popoverAnchor in popoverAnchors {
            let origin = relativeOrigin(
                popoverAnchor: popoverAnchor,
                containerFrame: containerFrame,
                popoverSize: popoverSize
            )

            /// Comparing distances, so no need to square the distance (saves processing power).
            let distance = CGPointDistanceSquared(from: targetPoint, to: origin)
            if distance < closestDistance {
                closestAnchor = popoverAnchor
                closestDistance = distance
            }
        }

        return closestAnchor
    }

    /**
     Get the frame of a popover if it's position is `.relative`.
     - parameter selectedAnchor: The popover's position within the container frame.
     - parameter containerFrame: The reference frame.
     - parameter popoverSize: The size of the popover.
     */
    func relativeFrame(
        selectedAnchor: Popover.Attributes.Position.Anchor,
        containerFrame: CGRect,
        popoverSize: CGSize
    ) -> CGRect {
        let origin = relativeOrigin(
            popoverAnchor: selectedAnchor,
            containerFrame: containerFrame,
            popoverSize: popoverSize
        )

        let frame = CGRect(origin: origin, size: popoverSize)
        return frame
    }
}

public extension Popover.Attributes.Position.Anchor {
    /// Convert an `Anchor` to UIKit's `UnitPoint`.
    /**

         topLeft              top              topRight
                X──────────────X──────────────X
                |                             |
                |                             |
         left   X            center           X   right
                |                             |
                |                             |
                X──────────────X──────────────X
         bottomLeft          bottom         bottomRight

     */
    var unitPoint: UnitPoint {
        switch self {
        case .topLeft:
            return .topLeading
        case .top:
            return .top
        case .topRight:
            return .topTrailing
        case .right:
            return .trailing
        case .bottomRight:
            return .bottomTrailing
        case .bottom:
            return .bottom
        case .bottomLeft:
            return .bottomLeading
        case .left:
            return .leading
        case .center:
            return .center
        }
    }
}
