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

/// Get an array of views from `@ViewBuilder`. From https://github.com/GeorgeElsham/ViewExtractor
/// Used for the Menu template.
/// Extract SwiftUI views from ViewBuilder content.
public struct ViewExtractor {
    /// Represents a `View`. Can be used to get `AnyView` from `Any`.
    public struct GenericView {
        let body: Any

        /// Get `AnyView` from a generic view.
        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }

    /// If the content is a `ForEach`, this gives the range. If it fails, it returns `nil`.
    public var forEachRange: Range<Int>? {
        struct FakeCollection {
            let indices: Range<Int>
        }

        // Reflect `ForEach` to get the `data`.
        guard let forEach = forEach else { return nil }
        let mirror = Mirror(reflecting: forEach)
        guard let data = mirror.descendant("data") else { return nil }

        // Bind the collection to `FakeCollection`, to get the `indices`.
        return withUnsafeBytes(of: data) { ptr -> Range<Int>? in
            let binded = ptr.bindMemory(to: FakeCollection.self)
            return binded.first?.indices
        }
    }

    private let forEach: DynamicViewContentProvider?

    public init<Content: View & DynamicViewContentProvider>(content: ForEachContent<Content>) {
        forEach = content()
    }

    /// Get the view at this exact index, ignoring types of views
    /// checks. For example, `EmptyView` won't be ignored.
    ///
    /// - Parameter index: Index within `ForEach` to get.
    /// - Returns: View at this index, or `nil` if none.
    public func uncheckedView(at index: Int) -> AnyView? {
        forEach?.extractContent(at: index)
    }

    /// Gets views from a `TupleView`.
    /// - Parameter content: Content to extract the views from.
    /// - Returns: Extracted views.
    public static func getViews<Views>(@ViewBuilder from content: TupleContent<Views>) -> [AnyView] {
        content().views
    }

    /// Get views from a normal view closure.
    /// - Parameter content: Content to extract the views from.
    /// - Returns: Extracted views.
    public static func getViews<Content: View>(@ViewBuilder from content: NormalContent<Content>) -> [AnyView] {
        ViewExtractor.views(from: content())
    }

    /// Gets views from `Any`. Also splits up `DynamicViewContent` into separate views.
    /// - Parameter view: View of `Any` type.
    /// - Returns: Views contained by this `view`.
    public static func views(from view: Any) -> [AnyView] {
        checkingViewContent(view) {
            // Just a normal view. Convert it from type `Any` to `AnyView`.
            withUnsafeBytes(of: view) { ptr -> [AnyView] in
                // Cast from type `Any` to `GenericView`,
                // which mimics the structure of a `View`.
                let binded = ptr.bindMemory(to: GenericView.self)

                // Get `AnyView` from the 'fake' view body.
                return binded.first?.anyView.map { [$0] } ?? []
            }
        }
    }

    /// Return the view content. This removes views like `EmptyView`,
    /// and gets content from within `ForEach`.
    ///
    /// - Parameters:
    ///   - view: View to test.
    ///   - actual: If this is a normal view, this content is used.
    /// - Returns: Array of content views.
    fileprivate static func checkingViewContent(_ view: Any, actual: () -> [AnyView]) -> [AnyView] {
        // Check this is not an empty view with no content.
        if view is EmptyView {
            return []
        }

        // Check this is not a `nil` view. Can occur due to conditionals.
        if case Optional<Any>.none = view {
            return []
        }

        // If this view is a `ForEach`, extract all contained views.
        if let forEach = view as? DynamicViewContentProvider {
            return forEach.extractContent()
        }

        // Actual view.
        return actual()
    }
}

// MARK: - Content types

public typealias TupleContent<Views> = () -> TupleView<Views>
public typealias NormalContent<Content: View> = () -> Content
public typealias ForEachContent<Content: View & DynamicViewContentProvider> = () -> Content

// MARK: - TupleView views

public extension TupleView {
    /// Convert tuple of views to array of `AnyView`s.
    var views: [AnyView] {
        let children = Mirror(reflecting: value).children
        return children.flatMap { ViewExtractor.views(from: $0.value) }
    }
}

// MARK: - Dynamic view content

public protocol DynamicViewContentProvider {
    func extractContent() -> [AnyView]
    func extractContent(at index: Int) -> AnyView?
}

extension ForEach: DynamicViewContentProvider where Content: View {
    public func extractContent() -> [AnyView] {
        // Dynamically mirrors the current instance.
        let mirror = Mirror(reflecting: self)

        // Retrieving hidden properties containing the data and content.
        if let data = mirror.descendant("data") as? Data,
           let content = mirror.descendant("content") as? (Data.Element) -> Content
        {
            return data.flatMap { element -> [AnyView] in
                // Create content given the data for this `ForEach` element.
                let newContent = content(element)

                // Gets content for element.
                return ViewExtractor.checkingViewContent(newContent) {
                    [AnyView(newContent)]
                }
            }
        } else {
            // Return no content if failure.
            return []
        }
    }

    public func extractContent(at index: Int) -> AnyView? {
        // Dynamically mirrors the current instance.
        let mirror = Mirror(reflecting: self)

        // Check view is valid.
        guard let data = mirror.descendant("data") as? Data,
              0 ..< data.count ~= index,
              let content = mirror.descendant("content") as? (Data.Element) -> Content
        else { return nil }

        // Return view for specific index.
        let dataIndex = data.index(data.startIndex, offsetBy: index)
        return AnyView(content(data[dataIndex]))
    }
}
