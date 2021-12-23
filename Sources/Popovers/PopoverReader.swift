//
//  PopoverReader.swift
//  Popover
//
//  Created by Zheng on 12/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

public struct PopoverReader<Content: View>: View {
    public init(@ViewBuilder view: @escaping (Popover.Context) -> Content) {
        self.view = view
    }
    
    @ViewBuilder var view: (Popover.Context) -> Content
    @EnvironmentObject var context: Popover.Context

    public var body: some View {
        view(context)
    }
}
