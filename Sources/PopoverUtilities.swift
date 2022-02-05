//
//  PopoverUtilities.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension UIView {
    /// Convert a view's frame to global coordinates, which are needed for `sourceFrame` and `excludedFrames.`
    func windowFrame() -> CGRect {
        return convert(bounds, to: nil)
    }
}

public extension Optional where Wrapped: UIView {
    /// Convert a view's frame to global coordinates, which are needed for `sourceFrame` and `excludedFrames.` This is a convenience overload for optional `UIView`s.
    func windowFrame() -> CGRect {
        if let view = self {
            return view.windowFrame()
        }
        return .zero
    }
}

public extension View {
    /// Read a view's frame. From https://stackoverflow.com/a/66822461/14351818
    func frameReader(in coordinateSpace: CoordinateSpace = .global, rect: @escaping (CGRect) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentFrameReaderPreferenceKey.self, value: geometry.frame(in: coordinateSpace))
                    .onPreferenceChange(ContentFrameReaderPreferenceKey.self) { newValue in
                        DispatchQueue.main.async {
                            rect(newValue)
                        }
                    }
            }
            .hidden()
        )
    }

    /**
     Read a view's size. The closure is called whenever the size itself changes, or the transaction changes (in the event of a screen rotation.)

     From https://stackoverflow.com/a/66822461/14351818
     */
    func sizeReader(transaction: Transaction? = nil, size: @escaping (CGSize) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentSizeReaderPreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newValue in
                        DispatchQueue.main.async {
                            size(newValue)
                        }
                    }
                    .onValueChange(of: transaction) { _, _ in
                        DispatchQueue.main.async {
                            size(geometry.size)
                        }
                    }
            }
            .hidden()
        )
    }
}

extension Transaction: Equatable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.animation == rhs.animation
    }
}

struct ContentFrameReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect { return CGRect() }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

struct ContentSizeReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize { return CGSize() }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

public extension UIColor {
    /**
     Create a UIColor from a hex code.

     Example:

         let color = UIColor(hex: 0x00aeef)
     */
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

/// Position a view using a rectangular frame. Access using `.frame(rect:)`.
struct FrameRectModifier: ViewModifier {
    let rect: CGRect
    func body(content: Content) -> some View {
        content
            .frame(width: rect.width, height: rect.height, alignment: .topLeading)
            .position(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
    }
}

public extension View {
    /// Position a view using a rectangular frame.
    func frame(rect: CGRect) -> some View {
        return modifier(FrameRectModifier(rect: rect))
    }
}

/// For easier CGPoint math
public extension CGPoint {
    /// Add 2 CGPoints.
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    /// Subtract 2 CGPoints.
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
}

/// Get the distance between 2 CGPoints. From https://www.hackingwithswift.com/example-code/core-graphics/how-to-calculate-the-distance-between-two-cgpoints
public func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

public extension Shape {
    /// Fill and stroke a shape at the same time. https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        stroke(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}

public extension InsettableShape {
    /// Fill and stroke a shape at the same time. https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}

public extension UIEdgeInsets {
    /// The left + right insets.
    var horizontal: CGFloat {
        get {
            left + right
        } set {
            left = newValue
            right = newValue
        }
    }

    /// The top + bottom insets.
    var vertical: CGFloat {
        get {
            top + bottom
        } set {
            top = newValue
            bottom = newValue
        }
    }

    /// Create equal insets on all 4 sides.
    init(_ inset: CGFloat) {
        self = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}

/// Detect changes in bindings (fallback of `.onChange` for iOS 13+). From https://stackoverflow.com/a/64402663/14351818
struct ChangeObserver<Content: View, Value: Equatable>: View {
    let content: Content
    let value: Value
    let action: (Value, Value) -> Void

    init(value: Value, action: @escaping (Value, Value) -> Void, content: @escaping () -> Content) {
        self.value = value
        self.action = action
        self.content = content()
        _oldValue = State(initialValue: value)
    }

    @State private var oldValue: Value

    var body: some View {
        DispatchQueue.main.async {
            if oldValue != value {
                action(oldValue, value)
                oldValue = value
            }
        }
        return content
    }
}

public extension View {
    /// Detect changes in bindings (fallback of `.onChange` for iOS 13+).
    func onValueChange<Value: Equatable>(
        of value: Value,
        perform action: @escaping (_ oldValue: Value, _ newValue: Value) -> Void
    ) -> some View {
        ChangeObserver(value: value, action: action) {
            self
        }
    }
}
