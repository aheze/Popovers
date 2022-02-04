//
//  File.swift
//  
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI


public extension View {
    
    func popoverShadow(shadow: PopoverShadow = .system) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}
