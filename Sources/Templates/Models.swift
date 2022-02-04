//
//  File.swift
//  
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

public struct PopoverShadow {
    public var color = Color(.label.withAlphaComponent(0.3))
    public var radius = CGFloat(0)
    public var x = CGFloat(0)
    public var y = CGFloat(0)
    
    public static let system = Self.init(
        color: Color(.label.withAlphaComponent(0.1)),
        radius: 40,
        x: 0,
        y: 4
    )
}


