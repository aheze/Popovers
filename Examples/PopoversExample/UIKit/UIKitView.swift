//
//  UIKitView.swift
//  PopoversExample
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct UIKitView: View {
    var body: some View {
        Section(
            header:
            Text("UIKit")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
        ) {
            Group {
                PresentView()
                ReplaceView()
                DismissView()
            }
        }
    }
}

struct ExampleUIKitRow<Content: View>: View {
    let color: UIColor
    @ViewBuilder var view: Content

    var body: some View {
        view
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(10)
            .shadow(
                color: Color(uiColor: .label.withAlphaComponent(0.25)),
                radius: 10,
                x: 0,
                y: 3
            )
            .padding()
            .background(
                Color(uiColor: .systemBackground)
                    .overlay(alignment: .bottomTrailing) {
                        LinearGradient(
                            colors: [
                                Color(uiColor: color),
                                Color(uiColor: .black),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .aspectRatio(contentMode: .fill)
                    }
            )
            .cornerRadius(16)
            .foregroundColor(.primary)
    }
}
