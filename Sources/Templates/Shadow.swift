//
//  Shadow.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

public extension Templates {
    /// A convenient way to apply shadows. Access using the `.popoverShadow()` modifier.
    struct Shadow {
        /// The shadow color.
        public var color = Color(.label.withAlphaComponent(0.3))
    
        /// The shadow radius.
        public var radius = CGFloat(0)
    
        /// The shadow's x offset.
        public var x = CGFloat(0)
    
        /// The shadow's y offset.
        public var y = CGFloat(0)
    
        public static let system = Self(
            color: Color(.label.withAlphaComponent(0.25)),
            radius: 40,
            x: 0,
            y: 4
        )
    }
}
