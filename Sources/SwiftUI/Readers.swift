//
//  Readers.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Read the popover's context from within its `view` or `background`.
 Use this just like `GeometryReader`.

  **Warning:** This must be placed inside a popover's `view` or `background`.
 */
public struct PopoverReader<Content: View>: View {
    /// Read the popover's context from within its `view` or `background`.
    public init(@ViewBuilder view: @escaping (Popover.Context) -> Content) {
        self.view = view
    }

    /// The parent view.
    @ViewBuilder var view: (Popover.Context) -> Content

    /// The popover's context (passed down from `Popover.swift`).
    @EnvironmentObject var context: Popover.Context

    public var body: some View {
        /// Pass the context down.
        view(context)
    }
}

/**
 Read the current `UIWindow` that hosts the view.
 Use this just like `GeometryReader`.

  **Warning:** Do *not* place this inside a popover's `view` or its `background`.
  Instead, use the `window` property of the popover's context.
 */
public struct WindowReader<Content: View>: View {
    /// Your SwiftUI view.
    public let view: (UIWindow?) -> Content

    /// The read window.
    @State var window: UIWindow?

    /// An environment value to pass down into your SwiftUI view.
    @Environment(\.window) var environmentWindow

    /// Reads the `UIWindow` that hosts some SwiftUI content.
    public init(@ViewBuilder view: @escaping (UIWindow?) -> Content) {
        self.view = view
    }

    public var body: some View {
        view(window)
            .environment(\.window, window)
            .background(
                WindowHandlerRepresentable(binding: $window)
            )
    }

    /// A wrapper view to read the parent window.
    private struct WindowHandlerRepresentable: UIViewRepresentable {
        var binding: Binding<UIWindow?>

        func makeUIView(context _: Context) -> WindowHandler {
            WindowHandler(binding: binding)
        }

        func updateUIView(_: WindowHandler, context _: Context) {}
    }

    private class WindowHandler: UIView {
        @Binding var binding: UIWindow?

        init(binding: Binding<UIWindow?>) {
            _binding = binding
            super.init(frame: .zero)
            backgroundColor = .clear
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("[Popovers] - Create this view programmatically.")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()

            /// Set the window.
            binding = window
        }
    }
}
