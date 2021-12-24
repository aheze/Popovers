//
//  DismissalView1.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI
import Popovers

struct DismissalView1: View {
    @State var present = false
    @State var expanding = false
    
    var body: some View {
        ExampleRow(
            image: "xmark",
            title: "Advanced Dismissal 1",
            color: 0xCB9400
        ) {
            present = true
        }
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset = UIEdgeInsets(16)
                $0.position = .relative(
                    popoverAnchors: [
                        .center
                    ]
                )
                $0.dismissal.mode = .dragDown
                $0.blocksBackgroundTouches = true
                $0.onTapOutside = {
                    withAnimation(.easeIn(duration: 0.15)) {
                        expanding = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {              
                        withAnimation(.easeOut(duration: 0.4)) { 
                            expanding = false
                        }
                    }
                }
                $0.tag = "Advanced Dismissal 1"
            }
        ) {
            DismissalPopover1(present: $present, expanding: $expanding)
        }
    }
}

struct DismissalPopover1: View {
    @Binding var present: Bool
    @Binding var expanding: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Drag down or tap \(Image(systemName: "xmark.circle.fill")) to dismiss.")
                
                Spacer()
                
                Button {
                    present = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                }
            }
            
            HStack {
                ExampleImage("hand.tap.fill", color: 0xCB9400)
                Text("By default, tapping outside a popover dismisses it.")
            }
            
            HStack {
                ExampleImage("circle.slash", color: 0xCB9400)
                Text("This popover's dismiss mode is `.dragDown` and bounces when `onTapOutside` is called.")
            }
            
            HStack {
                ExampleImage("curlybraces", color: 0xCB9400)
                Text("You can always dismiss popovers by setting `$presented` to false.")
            }
        }
        .frame(maxWidth: 300)
        .padding()
        .background(.background)
        .cornerRadius(12)
        .shadow(radius: 1)
        .scaleEffect(expanding ? 1.05 : 1)
    }
}
