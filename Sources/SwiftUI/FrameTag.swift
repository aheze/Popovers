//
//  FrameTag.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Frame tags are used to store the frames
 */

/// Store a view's frame for later use.
struct FrameTagModifier: ViewModifier {
    /// The name of the frame.
    let tag: AnyHashable
    @State var frame = CGRect.zero

    func body(content: Content) -> some View {
        WindowReader { window in
            content
                .frameReader { frame in
                    self.frame = frame
                    if let window = window {
                        window.save(frame, for: tag)
                    }
                }
                .onValueChange(of: window) { _, newValue in
                    if let window = window {
                        window.save(frame, for: tag)
                    }
                }
        }
    }
}

public extension View {
    /**
     Tag a view and store its frame. Access using `Popovers.frameTagged(_:)`.

     You can use this for supplying source frames or excluded frames. **Do not** use it anywhere else, due to State re-rendering issues.

     - parameter tag: The tag for the frame
     */
    func frameTag(_ tag: AnyHashable) -> some View {
        return modifier(FrameTagModifier(tag: tag))
    }
}

public extension UIResponder {
    /**
     Get the saved frame of a frame-tagged view inside this window. You must first set the frame using `.frameTag(_:)`.
     - parameter tag: The tag that you used for the frame.
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    func frameTagged(_ tag: AnyHashable) -> CGRect {
        return popoverModel.frame(tagged: tag)
    }

    /**
     Remove all saved frames inside this window for `.popover(selection:tag:attributes:view:)`.
     Call this method when you present another view where the frames don't apply.
     */
    func clearSavedFrames() {
        popoverModel.selectionFrameTags.removeAll()
    }

    /// Save a frame in this window's `frameTags`.
    internal func save(_ frame: CGRect, for tag: AnyHashable) {
        popoverModel.frameTags[tag] = frame
    }
}

public extension Optional where Wrapped: UIResponder {
    /**
     Get the saved frame of a frame-tagged view inside this window. You must first set the frame using `.frameTag(_:)`. This is a convenience overload for optional `UIResponder`s.
     - parameter tag: The tag that you used for the frame.
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    func frameTagged(_ tag: AnyHashable) -> CGRect {
        if let responder = self {
            return responder.frameTagged(tag)
        }
        return .zero
    }
}
