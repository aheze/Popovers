//
//  FrameTag.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Frame tags are used to store the frames
 */

/// Store a view's frame for later use.
struct FrameTagModifier: ViewModifier {
    
    /// The name of the frame.
    let tag: String
    
    func body(content: Content) -> some View {
        WindowReader { window in
            content
                .frameReader { frame in
                    window.save(frame, for: tag)
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
    func frameTag(_ tag: String) -> some View {
        return self.modifier(FrameTagModifier(tag: tag))
    }
    
}


extension UIResponder {
    
    /**
     Get the saved frame of a frame-tagged view. You must first set the frame using `.frameTag(_:)`.
     - parameter tag: The tag that you used for the frame.
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    public func frameTagged(_ tag: String) -> CGRect {
        return popoverModel.frameTagged(tag)
    }
    
    /**
     Remove all saved frames inside this window for `.popover(selection:tag:attributes:view:)`.
     Call this method when you present another view where the frames don't apply.
     */
    public func clearSavedFrames() {
        popoverModel.selectionFrameTags.removeAll()
    }
    
    /// Save a frame in this window's `frameTags`.
    func save(_ frame: CGRect, for tag: String) {
        popoverModel.frameTags[tag] = frame
    }
}
