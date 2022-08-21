//
//  PopoverUtilities.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
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
                let frame = geometry.frame(in: coordinateSpace)

                Color.clear
                    .onValueChange(of: frame) { _, newValue in
                        rect(newValue)
                    }
                    .onAppear {
                        rect(frame)
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
                    .onValueChange(of: transaction?.animation) { _, _ in
                        DispatchQueue.main.async {
                            size(geometry.size)
                        }
                    }
            }
            .hidden()
        )
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

/**
 From https://github.com/boraseoksoon/Throttler
 Used to prevent too many frame updates (when scrolling or presenting a `NavigationLink` with animations).

 MIT License

 Copyright (c) 2021 Jang Seoksoon

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
public enum Throttler {
    typealias WorkIdentifier = String

    typealias Work = () -> Void
    typealias Subject = PassthroughSubject<Work, Never>?
    typealias Bag = Set<AnyCancellable>

    private static var subjects: [WorkIdentifier: Subject] = [:]
    private static var bags: [WorkIdentifier: Bag] = [:]

    /// Throttle a work
    ///
    ///     var sec = 0
    ///     for i in 0...1000000000 {
    ///         Throttler.throttle {
    ///             sec += 1
    ///             Debug.log("your work done : \(i)")
    ///         }
    ///     }
    ///
    ///     Debug.log("done!")
    ///
    ///
    ///     "your work done : 1"
    ///     (after a delay)
    ///     "your work done : x"
    ///     (after a delay)
    ///     "your work done : y"
    ///     (after a delay)
    ///     "your work done : z"
    ///     ....
    ///     ...
    ///     ..
    ///     .
    ///     "your work done : 1000000000"
    ///
    ///     "done!"
    ///
    /// - Note: Pay special attention to the identifier parameter. the default identifier is \("Thread.callStackSymbols") to make api trailing closure for one liner for the sake of brevity. However, it is highly recommend that a developer should provide explicit identifier for their work to debounce. Also, please note that the default queue is global queue, it may cause thread explosion issue if not explicitly specified , so use at your own risk.
    ///
    /// - Parameters:
    ///   - identifier: the identifier to group works to throttle. Throttler must have equivalent identifier to each work in a group to throttle.
    ///   - queue: a queue to run a work on. dispatch global queue will be chosen by default if not specified.
    ///   - delay: delay for throttle. time unit is second. given default is 1.0 sec.
    ///   - shouldRunImmediately: a boolean type where true will run the first work immediately regardless.
    ///   - shouldRunLatest: A Boolean value that indicates whether to publish the most recent element. If `false`, the publisher emits the first element received during the interval.
    ///   - work: a work to run
    /// - Returns: Void
    public static func throttle(
        identifier: String = "\(Thread.callStackSymbols)",
        queue: DispatchQueue? = nil,
        delay: DispatchQueue.SchedulerTimeType.Stride = .seconds(1),
        shouldRunImmediately: Bool = true,
        shouldRunLatest: Bool = true,
        work: @escaping () -> Void
    ) {
        let isFirstRun = subjects[identifier] == nil ? true : false

        if shouldRunImmediately, isFirstRun {
            work()
        }

        if let _ = subjects[identifier] {
            subjects[identifier]?!.send(work)
        } else {
            subjects[identifier] = PassthroughSubject<Work, Never>()
            bags[identifier] = Bag()

            let q = queue ?? .global()

            subjects[identifier]?!
                .throttle(for: delay, scheduler: q, latest: shouldRunLatest)
                .sink(receiveValue: { $0() })
                .store(in: &bags[identifier]!)
        }
    }
}
