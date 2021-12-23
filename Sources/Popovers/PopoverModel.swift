//
//  PopoverModel.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import SwiftUI

public class PopoverModel: ObservableObject {
    
    /// The currently-presented popovers. The oldest are in front, the newest at the end..
    @Published var popovers = [Popover]()
    
    /// must be published so that the `PopoverContainerView` re-renders
    @Published var popoversDraggable = true
    
    /// store the frames of views (for excluding popover dismissal)
    @Published var frameTags: [String: CGRect] = [:]
    
    /// store frames of popover source views when presented using `selection`
    @Published var selectionFrameTags: [String: CGRect] = [:]
    
    /// force container view to update
    func refresh() {
        objectWillChange.send()
    }
}
