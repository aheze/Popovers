//
//  Utilities.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct ColorPickerView: View {
    @State var color = UIColor.systemBlue.cgColor
    var body: some View {
        ColorPicker("Pick a color", selection: $color)
    }
}

struct ExampleRow: View {
    let image: String
    let title: String
    let color: UInt
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 19, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(
                        Templates.VisualEffectView(.dark)
                    )
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.white, lineWidth: 1.5)
                            .opacity(0.8)
                    }

                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                Color(uiColor: .systemBackground)
                    .overlay(alignment: .bottomTrailing) {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(
                                    color: Color(uiColor: UIColor(hex: color).offset(by: 0.2)),
                                    location: 0
                                ),
                                Gradient.Stop(
                                    color: Color(uiColor: UIColor(hex: color)),
                                    location: 1
                                ),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .aspectRatio(contentMode: .fill)
                    }
            )

            .cornerRadius(16)
            .foregroundColor(.primary)
        }
    }
}

struct ExampleImage: View {
    let imageName: String
    let color: UIColor

    init(_ imageName: String, color: UInt = 0x00AEEF) {
        self.imageName = imageName
        self.color = UIColor(hex: color)
    }

    init(_ imageName: String, color: UIColor) {
        self.imageName = imageName
        self.color = color
    }

    var body: some View {
        Image(systemName: imageName)
            .foregroundColor(.white)
            .font(.system(size: 19, weight: .medium))
            .frame(width: 36, height: 36)
            .background(
                LinearGradient(
                    colors: [
                        Color(uiColor: color),
                        Color(uiColor: color.offset(by: 0.06)),
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .cornerRadius(10)
    }

    static var tip: ExampleImage {
        ExampleImage("lightbulb", color: 0x00C300)
    }

    static var warning: ExampleImage {
        ExampleImage("exclamationmark.triangle.fill", color: 0xEBD43D)
    }
}

extension UIColor {
    var color: Color {
        return Color(uiColor: self)
    }

    static func == (l: UIColor, r: UIColor) -> Bool {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        l.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        r.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
    }
}

func == (l: UIColor?, r: UIColor?) -> Bool {
    let l = l ?? .clear
    let r = r ?? .clear
    return l == r
}

/// get a gradient color
extension UIColor {
    func offset(by offset: CGFloat) -> UIColor {
        let (h, s, b, a) = hsba
        var newHue = h - offset

        /// make it go back to positive
        while newHue <= 0 {
            newHue += 1
        }
        let normalizedHue = newHue.truncatingRemainder(dividingBy: 1)
        return UIColor(hue: normalizedHue, saturation: s, brightness: b, alpha: a)
    }

    var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h: h, s: s, b: b, a: a)
    }
}
