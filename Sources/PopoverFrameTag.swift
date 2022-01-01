//
//  PopoverFrameTag.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

/// The key used for the tag-to-frame dictionary.
struct FrameTag: Hashable {
    
    /// The name of the frame.
    var tag: String
    
}

/// Store a view's frame for later use.
struct FrameTagModifier: ViewModifier {
    
    /// The name of the frame.
    let tag: String
    
    func body(content: Content) -> some View {
        FrameTagReader { (proxy) in
            content
                .frameReader { frame in
                    proxy.save(frame, for: tag)
                }
        }
    }
    
}

/// A wrapper class for a window scene.
public class WindowSceneModel: ObservableObject {
    @Published public var windowScene: UIWindowScene?
}

/// Get the parent window from a view. Help needed! From https://stackoverflow.com/a/63276688/14351818
struct WindowSceneReader: UIViewRepresentable {
    
    /// A closure that's called when the window is found.
    var found: ((UIWindowScene?) -> Void)
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        /**
         The 0.5 second delay is needed to wait until the window is first initialized.
         However, it's hardcoded. Does anyone know how to work around this?
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak view] in
            if let windowScene = view?.window?.windowScene {
                found(windowScene)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}

/**
 Read the window scene from a view and inject it as an environment object. iOS 14+ due to `@StateObject`.
 */
@available(iOS 14, *)
public struct WindowSceneInjectorModifier: ViewModifier {
    
    /// This is only iOS 14+. Looking for help in making this available for iOS 13.
    @StateObject var windowSceneModel = WindowSceneModel()
    
    public func body(content: Content) -> some View {
        content
        
        /// Inject the window into the subview.
            .environmentObject(windowSceneModel)
        
        /// Read the window.
            .background(
                WindowSceneReader { scene in
                    windowSceneModel.windowScene = scene
                }
            )
    }
}

public extension View {
    
    /**
     Tag a view and store its frame. Access using `Popovers.frameTagged(_:)`.
     
     You can use this for supplying source frames or excluded frames. **Do not** use it anywhere else, due to State re-rendering issues.
     
     - parameter tag: The tag for the frame
     */
    func frameTag(_ tag: String) -> some View {
        return self.modifier(FrameTagModifier(tag: tag))
    }
    
    /**
     Get a view's window and make it accessible to all subviews. iOS 14+ due to `@StateObject` - looking for help in making it available for iOS 13.
     
     Only necessary if your app supports multiple windows.
     */
    @available(iOS 14, *)
    func injectWindowScene() -> some View {
        return self.modifier(WindowSceneInjectorModifier())
    }
    
}


public extension Popovers {
    
    /**
     Get the saved frame of a frame-tagged view. You must first set the frame using `.frameTag(_:in:)`.
     - parameter tag: The tag that you used for the frame.
     
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    static func frameTagged(_ tag: String) -> CGRect {
        let frameTag = FrameTag(tag: tag)
        let frame = model.frameTags[frameTag]
        return frame ?? .zero
    }
    
}
