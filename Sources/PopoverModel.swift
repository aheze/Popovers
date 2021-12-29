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
 The view model for all presented popovers. Access it via `Popovers.model`.
 */
public class PopoverModel: ObservableObject {
    
    /// The currently-presented popovers. The oldest are in front, the newest at the end. Access this via `Popovers.current`.
    @Published var popovers = [Popover]()
    
    /// The current active window.
    @Published var activeWindowScene: UIWindowScene?
    
    /// Determines is the popovers can be dragged. Access this via `Popovers.draggingEnabled`.
    @Published var popoversDraggable = true
    
    /// Store the frames of views (for excluding popover dismissal or source frames). Access this via `Popovers.popover(tagged:)`.
    @Published var frameTags: [FrameTag: CGRect] = [:]
    
    /**
     Store frames of popover source views when presented using `.popover(selection:tag:attributes:view:)`. These frames are then used as excluded frames for dismissal.
     
     To opt out of this behavior, set `attributes.dismissal.excludedFrames` manually. To clear this array (usually when you present another view where the frames don't apply), call `Popovers.clearSavedFrames()`.
     */
    @Published var selectionFrameTags: [FrameTag: CGRect] = [:]
    
    /// Force the container view to update.
    func refresh() {
        objectWillChange.send()
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
                
                /// Must be on the main queue to get a different SwiftUI render loop
                DispatchQueue.main.async {
                    popover.setSize(popover.context.size)
                }
            }
        }
        
        refresh()
    }
    
}
