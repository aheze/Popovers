//
//  TutorialView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct TutorialView: View {
    @State var present = false

    var body: some View {
        Button {
            present = true
        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0x00B900)) {
                HStack {
                    ExampleImage("questionmark.circle.fill", color: UIColor(hex: 0x00B900))

                    Text("Tutorial")
                        .fontWeight(.medium)
                }
            }
        }
        .popover(
            present: $present,
            attributes: {
                $0.position = .relative(
                    popoverAnchors: [
                        .center,
                    ]
                )

                let animation = Animation.spring(
                    response: 0.6,
                    dampingFraction: 0.8,
                    blendDuration: 1
                )
                let transition = AnyTransition.move(edge: .bottom).combined(with: .opacity)

                $0.presentation.animation = animation
                $0.presentation.transition = transition
                $0.dismissal.mode = [.dragDown, .tapOutside]
            }
        ) {
            TutorialViewPopover(present: $present)
                .frame(maxWidth: 500, maxHeight: 600)
        }
    }
}

struct TutorialViewPopover: View {
    @Binding var present: Bool
    @State var selection: String?

    var body: some View {
        VStack {
            VStack(spacing: 14) {
                HStack {
                    Spacer()

                    Button {
                        present = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 19))
                            .foregroundColor(.secondary)
                            .frame(width: 38, height: 38)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(19)
                    }
                }

                Text("Welcome!")
                    .font(.system(size: 36))
                    .fontWeight(.bold)

                Text("[Find](https://getfind.app) is an app to find text in real life. Here's a short tutorial to get you started.")
                    .accentColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Button {
                    withAnimation(.spring()) {
                        selection = "Step 1"
                    }
                } label: {
                    Text("Start Tutorial")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .padding(.top, 6)
            }
            .padding(24)

            PhoneView {
                VStack(spacing: 24) {
                    /// top rectangle
                    Button {
                        withAnimation(.spring()) {
                            selection = "Step 2"
                        }
                    } label: {
                        PopoverTemplates.VisualEffectView(.systemChromeMaterialDark)
                            .frame(height: 60)
                            .overlay {
                                Text("Search Bar")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 21, weight: .medium))
                            }
                            .cornerRadius(16)
                    }
                    .background {
                        Color.white.opacity(0.5)
                            .cornerRadius(16)
                            .padding(selection == "Step 1" ? -8 : 0)
                    }
                    .padding()
                    .popover(
                        selection: $selection,
                        tag: "Step 1",
                        attributes: {
                            $0.position = .absolute(
                                originAnchor: .left,
                                popoverAnchor: .right
                            )

                            /// account for the scale effect
                            /// try to avoid scale effect whenever possible, since it screws up the source frame
                            /// here I've added a hardcoded offset
                            $0.sourceFrameInset.top = -60
                        }
                    ) {
                        TutorialViewPopoverDetails(selection: $selection, step: 1)
                            .zIndex(1)
                    }

                    Button {
                        withAnimation(.spring()) {
                            selection = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 48))
                            .padding()
                            .background(
                                PopoverTemplates.VisualEffectView(.systemChromeMaterialDark)
                            )
                            .cornerRadius(16)
                    }
                    .background {
                        Color.white.opacity(0.5)
                            .cornerRadius(16)
                            .padding(selection == "Step 2" ? -8 : 0)
                    }
                    .popover(
                        selection: $selection,
                        tag: "Step 2",
                        attributes: {
                            $0.position = .absolute(
                                originAnchor: .right,
                                popoverAnchor: .left
                            )
                        }
                    ) {
                        TutorialViewPopoverDetails(selection: $selection, step: 2)
                            .zIndex(1)
                    }

                    Spacer()
                }
            }
            .clipped()
            .opacity(selection == nil ? 0.6 : 1)

            /// try to avoid scale effect
            /// this time, I've added some offset to cancel it out
            .scaleEffect(selection == nil ? 0.9 : 1, anchor: .bottom)
            .allowsHitTesting(selection != nil)
        }
        .background(.regularMaterial)
        .cornerRadius(16)
        .popoverContainerShadow()
        .onTapGesture {
            withAnimation(.spring()) {
                selection = nil
            }
        }
    }
}

struct TutorialViewPopoverDetails: View {
    @Binding var selection: String?
    var step: Int
    var body: some View {
        PopoverTemplates.Container(backgroundColor: .black) {
            VStack(alignment: .leading) {
                Text("Tutorial")
                    .font(.system(size: 14, weight: .bold))
                    .textCase(.uppercase)
                Button {
                    withAnimation(.spring()) {
                        selection = "Step 2"
                    }
                } label: {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .opacity(selection == "Step 2" ? 0 : 1)
                            .overlay {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .opacity(selection == "Step 2" ? 1 : 0)
                            }
                        Text("Tap the search bar")
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.2))
                    .cornerRadius(10)
                }

                Button {
                    withAnimation(.spring()) {
                        selection = nil
                    }
                } label: {
                    HStack {
                        Image(systemName: "2.circle.fill")
                        Text("Tap here to stop")
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.2))
                    .cornerRadius(10)
                    .opacity(step == 2 ? 1 : 0)
                    .frame(height: step == 2 ? nil : 0)
                }
            }
            .foregroundColor(.white)
        }
        .frame(width: 260)
    }
}

struct PhoneView<Content: View>: View {
    @ViewBuilder var view: Content
    var body: some View {
        Color.clear.overlay {
            RoundedRectangle(cornerRadius: 36)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(uiColor: UIColor(hex: 0x34788A)),
                            Color.black,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 300)
                .frame(maxHeight: .infinity)
                .cornerRadius(36)
                .overlay {
                    /// phone content
                    view
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(uiColor: .systemBlue),
                                    Color(uiColor: .systemTeal),
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(24)
                        .padding()
                }
                .padding(.horizontal, 48)
                .padding(.bottom, -80)
        }
    }
}
