//
//  PopoverFrameTag.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

struct FrameTag: Hashable {
    var tag: String
    var windowScene: UIWindowScene
}
/// Store a view's frame for later use.
struct FrameTagModifier: ViewModifier {
    let tag: String
    var windowScene: UIWindowScene?
    @State var frame = CGRect.zero
    
    func body(content: Content) -> some View {
        content
            .frameReader { frame in
                self.frame = frame
                guard let windowScene = windowScene else { return }
                
                let frameTag = FrameTag(tag: tag, windowScene: windowScene)
                Popovers.model.frameTags[frameTag] = frame
            }
            .onDataChange(of: windowScene) { (_, newValue) in
                guard let windowScene = windowScene else { return }
                let frameTag = FrameTag(tag: tag, windowScene: windowScene)
                Popovers.model.frameTags[frameTag] = frame
            }
    }
}

public extension View {
    
    /**
     Tag a view and store its frame. Access using `Popovers.frameTagged(_:)`.
     
     You can use this for supplying source frames or excluded frames. **Do not** use it anywhere else, due to State re-rendering issues.
     */
    func frameTag(_ tag: String, in windowScene: UIWindowScene? = nil) -> some View {
        return self.modifier(FrameTagModifier(tag: tag, windowScene: windowScene))
    }
    
    func setWindowScene(_ windowScene: Binding<UIWindowScene?>) -> some View {
        return self.background(
            WindowSceneFinder { scene in
                windowScene.wrappedValue = scene
            }
        )
    }
}

public extension Popovers {
    
    /**
     Get the saved frame of a frame-tagged view. You must first set the frame using `.frameTag(_:)`.
     
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    static func frameTagged(_ tag: String, in windowScene: UIWindowScene? = UIApplication.shared.currentWindowScene) -> CGRect {
        guard let windowScene = windowScene else { return .zero }
        let frameTag = FrameTag(tag: tag, windowScene: windowScene)
        let frame = model.frameTags[frameTag]
        return frame ?? .zero
    }
}


/// From https://stackoverflow.com/a/63276688/14351818
/// Not working currently when the user scrolls and back - `makeUIView` is called multiple times.
struct WindowSceneFinder: UIViewRepresentable {
    var found: ((UIWindowScene?) -> Void)
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .green
        
        DispatchQueue.main.async { [weak view] in
            if let windowScene = view?.window?.windowScene {
                found(windowScene)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}
