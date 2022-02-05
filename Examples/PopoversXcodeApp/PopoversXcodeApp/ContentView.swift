//
//  ContentView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

/**
 Welcome to the Popovers example app!
 Here's some tips.
    - Actually run the app (tap the play button in the top-left). The App Preview sometimes doesn't work with Popovers.
    - The app already has Popovers installed. If you want to use Popovers in your own app, add the Swift Package: https://github.com/aheze/Popovers
    - If you need help, join the Discord server: https://getfind.app/discord
    - Thanks for checking out Popovers! - aheze
 */
struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 300))],
                    spacing: 16
                ) {
                    Playground()
                    Showroom()
                    UIKit()
                    Testing()
                    Color.clear.frame(height: 100)
                }
                .padding()
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .navigationTitle("Popovers")
            .modifier(ContentViewToolbar())
        }
        .navigationViewStyle(.stack)
    }
}
