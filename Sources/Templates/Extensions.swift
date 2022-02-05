//
//  Extensions.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

// MARK: - Shadows

public extension View {
    /// A convenient way to apply a shadow.
    func popoverShadow(shadow: Templates.Shadow = .system) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Arrow Positioning

public extension Popover.Attributes.Position {
    /// Determine which side an arrow is best placed.
    func getArrowPosition() -> Templates.ArrowSide {
        /// This only applied when the position is `.absolute`.
        if case let .absolute(originAnchor, popoverAnchor) = self {
            /// X = popover
            switch originAnchor {
            case .topLeft:
                // X ------------
                // | source frame
                // |
                switch popoverAnchor {
                case .topRight:
                    return .right(.mostCounterClockwise)
                case .right:
                    return .right(.centered)
                case .bottomLeft:
                    return .bottom(.mostClockwise)
                case .bottom:
                    return .bottom(.centered)
                default:
                    break
                }
            case .top:
                //  -------X-------
                // | source frame  |
                // |               |
                switch popoverAnchor {
                case .bottomRight:
                    return .bottom(.mostCounterClockwise)
                case .bottom:
                    return .bottom(.centered)
                case .bottomLeft:
                    return .bottom(.mostClockwise)
                default:
                    break
                }
            case .topRight:
                //  ------------- X
                //   source frame |
                //                |
                switch popoverAnchor {
                case .bottomRight:
                    return .bottom(.mostCounterClockwise)
                case .bottom:
                    return .bottom(.centered)
                case .left:
                    return .left(.centered)
                case .topLeft:
                    return .left(.mostClockwise)
                default:
                    break
                }
            case .right:
                //  ------------- |
                //  source frame  X
                //  ______________|
                switch popoverAnchor {
                case .bottomLeft:
                    return .left(.mostCounterClockwise)
                case .left:
                    return .left(.centered)
                case .topLeft:
                    return .left(.mostClockwise)
                default:
                    break
                }
            case .bottomRight:
                //                 |
                //  source frame   |
                //  ______________ X
                switch popoverAnchor {
                case .bottomLeft:
                    return .left(.mostCounterClockwise)
                case .left:
                    return .left(.centered)
                case .top:
                    return .top(.centered)
                case .topRight:
                    return .top(.mostClockwise)
                default:
                    break
                }
            case .bottom:
                //  |                |
                //  |  source frame  |
                //  |_______X________|
                switch popoverAnchor {
                case .topRight:
                    return .top(.mostCounterClockwise)
                case .top:
                    return .top(.centered)
                case .topLeft:
                    return .top(.mostClockwise)
                default:
                    break
                }
            case .bottomLeft:
                //  |
                //  | source frame
                //  X ______________
                switch popoverAnchor {
                case .topLeft:
                    return .top(.mostCounterClockwise)
                case .top:
                    return .top(.centered)
                case .right:
                    return .right(.centered)
                case .bottomRight:
                    return .top(.mostClockwise)
                default:
                    break
                }
            case .left:
                //  |--------------
                //  X  source frame
                //  |______________
                switch popoverAnchor {
                case .topRight:
                    return .right(.mostCounterClockwise)
                case .right:
                    return .right(.centered)
                case .bottomRight:
                    return .right(.mostClockwise)
                default:
                    break
                }
            case .center:
                break
            }
        }

        /// No preferred arrow. Just go with a top-centered one.
        return .top(.centered)
    }
}

// MARK: - Utilities

/// Convert degrees to radians and back. From https://stackoverflow.com/a/29179878
public extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

public extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

/// Get an array of views from `@ViewBuilder`. From https://stackoverflow.com/a/67243688/14351818
/// Used for the Menu template.
public extension TupleView {
    var getViews: [AnyView] {
        makeArray(from: value)
    }

    private struct GenericView {
        let body: Any

        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }

    private func makeArray<Tuple>(from tuple: Tuple) -> [AnyView] {
        func convert(child: Mirror.Child) -> AnyView? {
            withUnsafeBytes(of: child.value) { ptr -> AnyView? in
                let binded = ptr.bindMemory(to: GenericView.self)
                return binded.first?.anyView
            }
        }

        let tupleMirror = Mirror(reflecting: tuple)
        return tupleMirror.children.compactMap(convert)
    }
}
