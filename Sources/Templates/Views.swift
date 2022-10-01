//
//  Views.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 6/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension Templates {
    /// A vertical stack that adds separators
    /// From https://movingparts.io/variadic-views-in-swiftui
    struct DividedVStack<Content: View>: View {
        var leadingMargin: CGFloat
        var trailingMargin: CGFloat
        var color: UIColor?
        var content: Content

        public init(
            leadingMargin: CGFloat = 0,
            trailingMargin: CGFloat = 0,
            color: UIColor? = nil,
            @ViewBuilder content: () -> Content
        ) {
            self.leadingMargin = leadingMargin
            self.trailingMargin = trailingMargin
            self.color = color
            self.content = content()
        }

        public var body: some View {
            _VariadicView.Tree(
                DividedVStackLayout(
                    leadingMargin: leadingMargin,
                    trailingMargin: trailingMargin,
                    color: color
                )
            ) {
                content
            }
        }
    }

    struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
        var leadingMargin: CGFloat
        var trailingMargin: CGFloat
        var color: UIColor?

        @ViewBuilder
        public func body(children: _VariadicView.Children) -> some View {
            let last = children.last?.id

            VStack(spacing: 0) {
                ForEach(children) { child in
                    child

                    if child.id != last {
                        Divider()
                            .opacity(color == nil ? 1 : 0)
                            .overlay {
                                if let color = color {
                                    Color(uiColor: color)
                                }
                            }
                            .padding(.leading, leadingMargin)
                            .padding(.trailing, trailingMargin)
                    }
                }
            }
        }
    }

    /// A horizontal stack that adds separators
    struct DividedHStack<Content: View>: View {
        var topMargin: CGFloat
        var bottomMargin: CGFloat
        var content: Content

        public init(
            topMargin: CGFloat = 0,
            bottomMargin: CGFloat = 0,
            @ViewBuilder content: () -> Content
        ) {
            self.topMargin = topMargin
            self.bottomMargin = bottomMargin
            self.content = content()
        }

        public var body: some View {
            _VariadicView.Tree(
                DividedHStackLayout(
                    topMargin: topMargin,
                    bottomMargin: bottomMargin
                )
            ) {
                content
            }
        }
    }

    struct DividedHStackLayout: _VariadicView_UnaryViewRoot {
        var topMargin: CGFloat
        var bottomMargin: CGFloat
        @ViewBuilder
        public func body(children: _VariadicView.Children) -> some View {
            let last = children.last?.id

            HStack(spacing: 0) {
                ForEach(children) { child in
                    child

                    if child.id != last {
                        Divider()
                            .padding(.top, topMargin)
                            .padding(.bottom, bottomMargin)
                    }
                }
            }
        }
    }
}
