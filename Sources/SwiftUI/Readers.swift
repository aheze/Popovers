//
//  Readers.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
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
 
  **Warning:** Do **not** place this inside a popover's `view` or its `background`.
 */
public struct WindowReader<Content: View>: View {
    
    /// Your SwiftUI view.
    public let view: ((UIWindow) -> Content)
    
    /// The read window.
    @State var window: UIWindow?
    
    /// An environment value to pass down into your SwiftUI view.
    @Environment(\.window) var environmentWindow
    
    /// Reads the `UIWindow` that hosts some SwiftUI content.
    public init(@ViewBuilder view: @escaping (UIWindow) -> Content) {
        self.view = view
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let window = window ?? environmentWindow {
                view(window)
                    .environment(\.window, window)
            }
            
            WindowHandlerRepresentable(binding: $window)
                .allowsHitTesting(false)
                .frame(width: 0, height: 0)
        }
    }
    
    /// A wrapper view to read the parent window.
    private struct WindowHandlerRepresentable: UIViewRepresentable {
        
        var binding: Binding<UIWindow?>
        
        func makeUIView(context: Context) -> WindowHandler {
            WindowHandler(binding: binding)
        }
        
        func updateUIView(_ uiView: WindowHandler, context: Context) {
            
        }
    }
    
    private class WindowHandler: UIView {
        
        @Binding var binding: UIWindow?
        
        init(binding: Binding<UIWindow?>) {
            self._binding = binding
            super.init(frame: .zero)
            self.backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            /// Set the window.
            binding = window
        }
    }
}

