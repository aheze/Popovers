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
    
}
