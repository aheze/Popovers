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
        var content: Content

        public init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        public var body: some View {
            _VariadicView.Tree(DividedVStackLayout()) {
                content
            }
        }
    }

    struct DividedVStackLayout: _VariadicView_UnaryViewRoot {
        @ViewBuilder
        public func body(children: _VariadicView.Children) -> some View {
            let last = children.last?.id

            VStack(spacing: 0) {
                ForEach(children) { child in
                    child

                    if child.id != last {
                        Divider()
                    }
                }
            }
        }
    }
}
