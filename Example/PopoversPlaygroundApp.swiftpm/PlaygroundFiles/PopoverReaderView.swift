//
//  PopoverReaderView.swift
//  PopoversPlaygroundApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI
import Popovers

struct PopoverReaderView: View {
    @State var present = false
    
    var body: some View {
        ExampleRow(
            image: "viewfinder",
            title: "Popover Reader",
            color: 0x00CBD9
        ) {
            present.toggle()
        }
        .popover(
            present: $present,
            attributes: { 
                $0.sourceFrameInset = UIEdgeInsets(16)
                $0.position = .relative(
                    popoverAnchors: [
                        .bottom,
                        .right,
                        .top,
                        .left,
                    ]
                )
            }
        ) {
            PopoverReader { context in
                VStack(alignment: .leading) {
                    Text("You can read the context of the popover via `PopoverReader`, then do all sorts of cool stuff.")
                    
                    HStack {
                        ExampleImage("rectangle.on.rectangle", color: 0x00CBD9)
                        Text("You can put `PopoverReader` in the view or its background.")
                    }
                    
                    HStack {
                        ExampleImage("point.topleft.down.curvedto.point.bottomright.up", color: 0x00CBD9)
                        Text("This curve connects to the Frame-Tagged View.")
                    }
                }
                .padding()
                .background(.background)
                .cornerRadius(12)
                .shadow(radius: 1)
            }
        } background: {
            PopoverReader { context in
                Color.blue.opacity(0.1)
                
                Circle()
                    .fill(Color.blue, strokeBorder: Color.white, lineWidth: 3)
                    .frame(width: 16, height: 16)
                    .position(context.frame.point(at: .top))
                    .zIndex(1)
                
                PopoverTemplates.CurveConnector(
                    start: context.frame.point(at: .top),
                    end: Popovers.frameTagged("Frame-Tagged View").point(at: .bottom)
                )
                    .stroke(
                        Color.blue,
                        style: .init(
                            lineWidth: 4,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .zIndex(2)
                
                
                Circle()     
                    .fill(Color.blue, strokeBorder: Color.white, lineWidth: 3)        
                    .frame(width: 16, height: 16)
                    .position(
                        Popovers.frameTagged("Frame-Tagged View").point(at: .bottom)
                    )
                    .zIndex(1)
            }
        }
    }
}
