//
//  Popovers.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 The main access point for the Popovers library.
 */
public struct Popovers {
    
    /// The view model for the popovers.
    public static var model: PopoverModel = {
        let model = PopoverModel()
        return model
    }()
    
    /**
     Enable or disable popover dragging globally.
     
     This is useful if you have nested sliders or other gestures that interfere with the popover's rubber banding. Set this to `true` to enable dragging, `false` to disable dragging.
     */
    public static var draggingEnabled: Bool {
        get {
            Popovers.model.popoversDraggable
        } set {
            Popovers.model.popoversDraggable = newValue
        }
    }
    
}
