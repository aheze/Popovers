//
//  Alert.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension Templates {
    /// A button style to resemble that of a system alert.
    struct AlertButtonStyle: ButtonStyle {
        /// A button style to resemble that of a system alert.
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .padding()
                .background(
                    configuration.isPressed ? Templates.buttonHighlightColor : Color.clear
                )
        }
    }
}
