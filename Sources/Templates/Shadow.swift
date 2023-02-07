//
//  Shadow.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
#if os(iOS)
import SwiftUI

public extension Templates {
    /// A convenient way to apply shadows. Access using the `.popoverShadow()` modifier.
    struct Shadow {
        /// The shadow color.
        public var color = Color.black.opacity(0.25)
    
        /// The shadow radius.
        public var radius = CGFloat(0)
    
        /// The shadow's x offset.
        public var x = CGFloat(0)
    
        /// The shadow's y offset.
        public var y = CGFloat(0)
    
        public static var system = Self(
            color: Color.black.opacity(0.25),
            radius: 40,
            x: 0,
            y: 4
        )

        public init(
            color: Color = Color.black.opacity(0.25),
            radius: CGFloat = CGFloat(0),
            x: CGFloat = CGFloat(0),
            y: CGFloat = CGFloat(0)
        ) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }
}
#endif
