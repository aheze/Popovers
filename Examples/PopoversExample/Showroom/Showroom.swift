//
//  Showroom.swift
//  PopoversExample
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct Showroom: View {
    var body: some View {
        Section(
            header:
            Text("Showroom")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
        ) {
            VStack {
                MenuView()
                AlertView()
                VideoView()
                TipView()
                TutorialView()
                ColorView()
                NotificationView()
                FormView()
                StandardView()
            }
        }
    }
}

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color(UIColor.white.withAlphaComponent(0.1)))
            .frame(height: 1)
    }
}

struct ExampleShowroomRow<Content: View>: View {
    var color: UIColor = .systemBlue
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
                                Color(uiColor: color.offset(by: 0.2)),
                                Color(uiColor: color),
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
