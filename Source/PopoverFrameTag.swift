//
//  PopoverFrameTag.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

/// Store a view's frame for later use.
struct FrameTagModifier: ViewModifier {
    let tag: String
    
    func body(content: Content) -> some View {
        content
            .frameReader { rect in
                Popovers.model.frameTags[tag] = rect
            }
    }
}

public extension View {
    
    /**
     Tag a view and store its frame. Access using `Popovers.frameTagged(_:)`.
     
     You can use this for supplying source frames or excluded frames. **Do not** use it anywhere else, due to State re-rendering issues.
     */
    func frameTag(_ tag: String) -> some View {
        return self.modifier(FrameTagModifier(tag: tag))
    }
}

public extension Popovers {
    
    /**
     Get the saved frame of a frame-tagged view. You must first set the frame using `.frameTag(_:)`.
     
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    static func frameTagged(_ tag: String) -> CGRect {
        let frame = model.frameTags[tag]
        return frame ?? .zero
    }
}
