//
//  PopoverModel.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import SwiftUI

/**
 The view model for all presented popovers. Access it via `Popovers.model`.
 */
public class PopoverModel: ObservableObject {
    
    /// The currently-presented popovers. The oldest are in front, the newest at the end. Access this via `Popovers.current`.
    @Published var popovers = [Popover]()
    
    /// Determines is the popovers can be dragged. Access this via `Popovers.draggingEnabled`.
    @Published var popoversDraggable = true
    
    /// Store the frames of views (for excluding popover dismissal or source frames). Access this via `Popovers.popover(tagged:)`.
    @Published var frameTags: [String: CGRect] = [:]
    
    /// Store frames of popover source views when presented using `selection`. These frames are then used as excluded frames for dismissal. To opt out of this behavior, set `attributes.dismissal.excludedFrames` manually.
    @Published var selectionFrameTags: [String: CGRect] = [:]
    
    /// Force the container view to update.
    func refresh() {
        objectWillChange.send()
    }
}
