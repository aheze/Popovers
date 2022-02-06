//
//  Testing.swift
//  PopoversPlaygroundsApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct Testing: View {
    var body: some View {
        Section(
            header:
            Text("Testing")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        ) {
            Group {
                InsideNavigationView()
                MenuComparisonView()
                UIKitMenuView()
                PresentWithinSheetView()
            }
        }
    }
}

struct ExampleTestingRow: View {
    let image: String
    let title: String
    let color: UInt

    var body: some View {
        HStack {
            Image(systemName: image)
                .font(.system(size: 19, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        colors: [
                            Color(uiColor: UIColor(hex: color).offset(by: 0.2)),
                            Color(uiColor: UIColor(hex: color)),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)

            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }

        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
    }
}
