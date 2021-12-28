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
    
    /// The window scene that the view is located in.
    var windowScene: UIWindowScene
}

/// Store a view's frame for later use.
struct FrameTagModifier: ViewModifier {
    
    /// The name of the frame.
    let tag: String
    
    /// The window scene that the view is located in.
    var windowScene: UIWindowScene?
    
    /// Keep a reference to the frame, in case the window scene changes and `frameTags` needs to be updated.
    @State var frame = CGRect.zero
    
    func body(content: Content) -> some View {
        content
            .frameReader { frame in
                
                /// Keep a reference to the frame first, since the window scene could be nil.
                self.frame = frame
                saveFrame()
            }
        
        /// Sometimes the window is provided after `frameReader`.
            .onDataChange(of: windowScene) { (_, _) in
                saveFrame()
            }
    }
    
    /// Save the frame to the popover model.
    func saveFrame() {
        
        /// Make sure the view's parent window scene exists.
        guard let windowScene = windowScene else { return }
        
        /// Create a new tag key.
        let frameTag = FrameTag(tag: tag, windowScene: windowScene)
        
        /// Save the frame.
        Popovers.model.frameTags[frameTag] = frame
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
     - parameter windowScene: The window scene that the view is located in. Only needed if your app supports multiple windows.
     */
    func frameTag(_ tag: String, in windowScene: UIWindowScene? = UIApplication.shared.currentWindowScene) -> some View {
        return self.modifier(FrameTagModifier(tag: tag, windowScene: windowScene))
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
     - parameter windowScene: The window scene of the saved frame. Only needed if your app supports multiple windows.
     
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    static func frameTagged(_ tag: String, in windowScene: UIWindowScene? = UIApplication.shared.currentWindowScene) -> CGRect {
        guard let windowScene = windowScene else { return .zero }
        let frameTag = FrameTag(tag: tag, windowScene: windowScene)
        let frame = model.frameTags[frameTag]
        return frame ?? .zero
    }
}


