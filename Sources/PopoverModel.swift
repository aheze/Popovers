//
//  PopoverModel.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

/**
 The view model for presented popovers within a window.
 
 Each view model is scoped to a window, which retains the view model.
 Presenting or otherwise managing a popover automatically scopes interactions to the window of the current view hierarchy.
 */
class PopoverModel: ObservableObject {
    
    /// The currently-presented popovers. The oldest are in front, the newest at the end.
    @Published var popovers = [Popover]()
    
    /// Determines if the popovers can be dragged.
    @Published var popoversDraggable = true
    
    /// Store the frames of views (for excluding popover dismissal or source frames).
    @Published var frameTags: [FrameTag: CGRect] = [:]
    
    /**
     Store frames of popover source views when presented using `.popover(selection:tag:attributes:view:)`. These frames are then used as excluded frames for dismissal.
     
     To opt out of this behavior, set `attributes.dismissal.excludedFrames` manually. To clear this array (usually when you present another view where the frames don't apply), use a `FrameTagReader` to call `FrameTagProxy.clearSavedFrames()`.
     */
    @Published var selectionFrameTags: [FrameTag: CGRect] = [:]
    
    /// Force the container view to update.
    func refresh() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    /**
     Refresh the popovers with a new transaction.
     
     This is called when a popover's frame is being calculated.
     */
    func refresh(with transaction: Transaction?) {
        /// Set each popovers's transaction to the new transaction to keep the smooth animation.
        for popover in popovers {
            popover.context.transaction = transaction
        }
        
        /// Update all popovers.
        refresh()
    }
    
    /// Removes a `Popover` from this model.
    func remove(_ popoverToRemove: Popover) {
        popovers.removeAll { (candidate) in
            candidate == popoverToRemove
        }
    }
    
    /// Get the index in the for a popover. Returns `nil` if the popover is not in the array.
    func index(of popover: Popover) -> Int? {
        return popovers.firstIndex(of: popover)
    }
    
    /**
     Get a currently-presented popover with a tag. Returns `nil` if no popover with the tag was found.
     - parameter tag: The tag of the popover to look for.
     */
    func popover(tagged tag: String) -> Popover? {
        return popovers.first(where: { $0.attributes.tag == tag })
    }
    
    /**
     Update all popover frames.
     
     This is called when the device rotates or has a bounds change.
     */
    func updateFrames() {
        for popover in popovers {
            if
                case .relative(let popoverAnchors) = popover.attributes.position,
                popoverAnchors == [.center]
            {
                /// For some reason, relative positioning + `.center` doesn't need to be on the main queue to have a size change.
                popover.setSize(popover.context.size)
            } else {
                
                /// Must be on the main queue to get a different SwiftUI render loop.
                DispatchQueue.main.async {
                    popover.setSize(popover.context.size)
                }
            }
        }
        
        refresh()
    }
    
    func frameTagged(_ tag: String) -> CGRect {
        let frameTag = FrameTag(tag: tag)
        let frame = frameTags[frameTag]
        return frame ?? .zero
    }
    
    func replace(_ oldPopover: Popover, with newPopover: Popover) {
        oldPopover.replace(with: newPopover)
    }
    
}
