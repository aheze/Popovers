//
//  PopoverReader.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Read the popover's context from within its `view` or `background`.
 
 Use this just like `GeometryReader`.
 
 **Warning:** This **must** be placed inside a popover's `view` or `background`.
 */
public struct PopoverReader<Content: View>: View {
    
    /// Read the popover's context from within its `view` or `background`.
    public init(@ViewBuilder view: @escaping (Popover.Context) -> Content) {
        self.view = view
    }
    
    /// The parent view.
    @ViewBuilder var view: (Popover.Context) -> Content
    
    /// The popover's context (passed down from `Popover.swift`).
    @EnvironmentObject var context: Popover.Context

    public var body: some View {
        
        /// Pass the context down.
        view(context)
    }
}
