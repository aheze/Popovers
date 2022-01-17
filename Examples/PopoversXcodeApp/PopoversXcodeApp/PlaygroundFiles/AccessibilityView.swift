//
//  AccessibilityView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 1/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct AccessibilityView: View {
    @State var present = false

    var body: some View {
        ExampleRow(
            image: "hand.point.up.braille",
            title: "Accessibility",
            color: 0x0021FF
        ) {
            present.toggle()
        }
        .popover(
            present: $present,
            attributes: {
                $0.accessibility.shiftFocus = false
                $0.accessibility.dismissButtonLabel = AnyView(
                    Text("Tap me to dismiss!")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(16)
                )
            }
        ) {
            VStack {
                VStack(alignment: .leading) {
                    Text("Popovers has full VoiceOver support!")

                    HStack {
                        ExampleImage("speaker.wave.2", color: 0x0021FF)
                        
                        Text("By default, VoiceOver will read out the popover when it's presented. You can change this with `attributes.accessibility.shiftFocus`.")
                    }
                    
                    HStack {
                        ExampleImage("hand.thumbsup", color: 0x0021FF)
                        
                        Text("By default, a \(Image(systemName: "xmark.circle.fill")) button will appear next to popovers when VoiceOver is on. You can customize this with `attributes.accessibility.dismissButtonLabel`.")
                    }
                }
            }
                .padding()
                .background(.background)
                .cornerRadius(12)
                .shadow(radius: 1)
                .frame(maxWidth: 300)
        }
    }
}
