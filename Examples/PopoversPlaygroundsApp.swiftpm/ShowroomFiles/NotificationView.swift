//
//  NotificationView.swift
//  PopoversPlaygroundsApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct NotificationView: View {
    @State var present = false
    @State var presentingUUID = UUID()

    var body: some View {
        Button {
            present = true
        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0x8228FF)) {
                HStack {
                    ExampleImage("bell.fill", color: UIColor(hex: 0x8228FF))

                    Text("Notification")
                        .fontWeight(.medium)
                }
            }
        }
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset = UIEdgeInsets(16)
                $0.position = .relative(
                    popoverAnchors: [
                        .top,
                    ]
                )
                $0.presentation.animation = .spring()
                $0.presentation.transition = .move(edge: .top)
                $0.dismissal.animation = .spring(response: 3, dampingFraction: 0.8, blendDuration: 1)
                $0.dismissal.transition = .move(edge: .top)
                $0.dismissal.mode = [.dragUp]
                $0.dismissal.dragDismissalProximity = 0.1
            }
        ) {
            NotificationViewPopover()
                .onAppear {
                    presentingUUID = UUID()
                    let currentID = presentingUUID
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if currentID == presentingUUID {
                            present = false
                        }
                    }
                }
        }
    }
}

struct NotificationViewPopover: View {
    var body: some View {
        HStack {
            ExampleImage("bell.fill", color: UIColor(hex: 0x8228FF))
            Text("This is a notification.")
            Spacer()
        }
        .frame(maxWidth: 600)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(uiColor: UIColor.label.withAlphaComponent(0.25)), lineWidth: 1)
        )
    }
}
