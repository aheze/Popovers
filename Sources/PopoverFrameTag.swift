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
