//
//  PopoverUtilities.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//
//

import SwiftUI
import Combine

public extension View {
    func frameReader(rect: @escaping (CGRect) -> Void) -> some View {
        return self
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ContentSizeReaderPreferenceKey.self, value: geometry.frame(in: .global))
                        .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newValue in
                            DispatchQueue.main.async {
                                rect(newValue)
                            }
                        }
                }
                    .hidden()
            )
    }
}

struct ContentSizeReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect { get { return CGRect() } }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

public extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

struct FrameRectModifier: ViewModifier {
    let rect: CGRect
    func body(content: Content) -> some View {
        content
            .frame(width: rect.width, height: rect.height, alignment: .topLeading)
            .position(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        
    }
}

public extension View {
    func frame(rect: CGRect) -> some View {
        return self.modifier(FrameRectModifier(rect: rect))
    }
}

/// convert to popover coordinates
public extension UIView {
    /// frame in the global window
    func windowFrame() -> CGRect {
        return self.convert(bounds, to: nil)
    }
}

/// for easier multiplying in `ShutterShapeAttributes`
public extension CGPoint {
    static func * (left: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * scalar, y: left.y * scalar)
    }
    
    static func * (scalar: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: right.x * scalar, y: right.y * scalar)
    }
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    func distance(from p: CGPoint) -> CGFloat {
        return sqrt( ((x - p.x) * (x - p.x)) + ((y - p.y) * (y - p.y)) )
    }
}

public func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
public extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

public extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

public extension UIEdgeInsets {
    var horizontal: CGFloat {
        get {
            left
        } set {
            left = newValue
            right = newValue
        }
    }
    var vertical: CGFloat {
        get {
            top
        } set {
            top = newValue
            bottom = newValue
        }
    }
    
    init(_ inset: CGFloat) {
        self = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}

/// from https://stackoverflow.com/a/29179878
public extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

public extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

/// from https://stackoverflow.com/a/67243688/14351818
/// used for the Menu template
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
