//
//  Popovers.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 1/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 A collection of constants.
 */
public enum Popovers {
    /// The minimum distance a popover needs to be dragged before it starts getting offset.
    public static var minimumDragDistance = CGFloat(2)

    /// The delay after a bounds change before recalculating popover frames.
    public static var frameUpdateDelayAfterBoundsChange = CGFloat(0.6)
}
