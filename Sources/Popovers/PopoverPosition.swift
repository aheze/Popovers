import SwiftUI

public extension CGRect {
    func point(at anchor: Popover.Attributes.Position.Anchor) -> CGPoint {
        switch anchor {
        case .topLeft:
            return self.origin
        case .top:
            return CGPoint(
                x: self.origin.x + self.width / 2,
                y: self.origin.y
            )
        case .topRight:
            return CGPoint(
                x: self.origin.x + self.width,
                y: self.origin.y
            )
        case .right:
            return CGPoint(
                x: self.origin.x + self.width,
                y: self.origin.y + self.height / 2
            )
        case .bottomRight:
            return CGPoint(
                x: self.origin.x + self.width,
                y: self.origin.y + self.height
            )
        case .bottom:
            return CGPoint(
                x: self.origin.x + self.width / 2,
                y: self.origin.y + self.height
            )
        case .bottomLeft:
            return CGPoint(
                x: self.origin.x,
                y: self.origin.y + self.height
            )
        case .left:
            return CGPoint(
                x: self.origin.x,
                y: self.origin.y + self.height / 2
            )
        case .center:
            return CGPoint(
                x: self.origin.x + self.width / 2,
                y: self.origin.y + self.height / 2
            )
        }
    }
}

public extension Popover.Attributes.Position {
    func absoluteFrame(
        originAnchor: Anchor,
        popoverAnchor: Anchor,
        originFrame: CGRect,
        popoverSize: CGSize
    ) -> CGRect {
        let popoverOrigin = originFrame.point(at: originAnchor)
        
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
    
    /// get the origin of the popover *within* a rectangle
    /// origin = top left of popover
    func relativeOrigin(
        containerFrame: CGRect,
        popoverSize: CGSize,
        anchor: Anchor
    ) -> CGPoint {
        switch anchor {
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
    
    func relativeClosestAnchor(
        popoverAnchors: [Anchor],
        containerFrame: CGRect,
        popoverSize: CGSize,
        targetPoint: CGPoint
    ) -> Popover.Attributes.Position.Anchor {
        var (closestAnchor, closestDistance): (Popover.Attributes.Position.Anchor, CGFloat) = (.bottom, .infinity)
        for popoverAnchor in popoverAnchors {
            let origin = relativeOrigin(
                containerFrame: containerFrame,
                popoverSize: popoverSize,
                anchor: popoverAnchor
            )    
            let distance = CGPointDistanceSquared(from: targetPoint, to: origin)
            if distance < closestDistance {
                closestAnchor = popoverAnchor
                closestDistance = distance
            }
        }
        return closestAnchor
    }
    
    func relativeFrame(
        containerFrame: CGRect,
        popoverSize: CGSize,
        selectedAnchor: Popover.Attributes.Position.Anchor
    ) -> CGRect {
        let origin = relativeOrigin(
            containerFrame: containerFrame,
            popoverSize: popoverSize,
            anchor: selectedAnchor
        )
        
        let frame = CGRect(origin: origin, size: popoverSize)
        return frame
    }
}

public extension Popover.Attributes.Position.Anchor {
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
