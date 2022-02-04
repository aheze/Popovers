//
//  File.swift
//
//
//  Created by A. Zheng (github.com/aheze) on 2/3/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/// For passing the hosting window into the environment.
extension EnvironmentValues {
    /// Designates the `UIWindow` hosting the views within the current environment.
    var index: Int? {
        get {
            self[IndexEnvironmentKey.self]
        }
        set {
            self[IndexEnvironmentKey.self] = newValue
        }
    }

    private struct IndexEnvironmentKey: EnvironmentKey {
        typealias Value = Int?

        static var defaultValue: Int? = nil
    }
}

public extension PopoverTemplates {
    struct MenuButton<Content: View>: View {
        @Environment(\.index) var index: Int?
        @EnvironmentObject var model: MenuModel
        let action: () -> Void
        @ViewBuilder let label: Content

        public init(
            _ action: @escaping (() -> Void),
            label: () -> Content
        ) {
            self.action = action
            self.label = label()
        }

        public var body: some View {
            label
                .onValueChange(of: model.selectedIndex) { _, newValue in
                    if newValue == index {
                        action()
                    }
                }
        }
    }

    class MenuModel: ObservableObject {
        /// The active (hovering) button.

        @Published var isPressed = false

        @Published var hoveringIndex: Int?

        /// The selected button.
        @Published var selectedIndex: Int?

        @Published var frames: [Int: CGRect] = [:]
    }

    struct MenuConfiguration {
        public var animation = Animation.default

        public init(animation: Animation = Animation.default) {
            self.animation = animation
        }
    }

    /**
     A built-from-scratch version of the system menu.
     */
    struct Menu<Views, Label: View>: View {
        @State var present = false

        /// View model for the child buttons.
        @StateObject var model = MenuModel()

        /// If the menu is shrunk down and not visible (for transitions).
        @State var shrunk = true

        public let configuration: MenuConfiguration

        /// The menu buttons.
        public let content: TupleView<Views>

        public let label: (Bool) -> Label

        /**
         Create a custom menu.
         */
        public init(
            configuration: MenuConfiguration = MenuConfiguration(),
            @ViewBuilder content: @escaping () -> TupleView<Views>,
            @ViewBuilder label: @escaping (Bool) -> Label
        ) {
            self.configuration = configuration
            self.content = content()
            self.label = label
        }

        public var body: some View {
            label(model.isPressed)
                .popoverMenuGesture(animation: configuration.animation, isPressed: $model.isPressed, model: model)
                .onValueChange(of: model.isPressed) { _, newValue in
                    if newValue {}
                }
                .popover(present: $present) {
                    MenuPopoverView(model: model, content: content.getViews)
                } background: {
                    Color.black.opacity(0.3)
                }
        }

        /// Get the point to scale from.
        func getScaleAnchor(attributes: Popover.Attributes) -> UnitPoint {
            if case let .absolute(_, popoverAnchor) = attributes.position {
                return popoverAnchor.unitPoint
            }

            return .center
        }
    }

    struct MenuPopoverView: View {
        @ObservedObject var model: MenuModel

        /// The menu buttons.
        public let content: [AnyView]

        public init(
            model: MenuModel,
            content: [AnyView]
        ) {
            self.model = model
            self.content = content
        }

        public var body: some View {
            PopoverReader { context in
                VStack(spacing: 0) {
                    ForEach(content.indices) { index in

                        content[index]

                            /// Inject index and model.
                            .environment(\.index, index)
                            .environmentObject(model)

                            .frame(maxWidth: .infinity)
                            .buttonStyle(PlainButtonStyle())
                            .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                            .frameReader { rect in
                                model.frames[index] = rect
                            }
                            .contentShape(Rectangle())
                            .background(
                                model.hoveringIndex == index ? PopoverTemplates.buttonHighlightColor : .clear
                            )
                            .foregroundColor(.primary)

                        if index != content.count - 1 {
                            Rectangle()
                                .fill(Color(UIColor.label))
                                .frame(height: 0.4)
                                .opacity(0.3)
                        }
                    }
                }
                .fixedSize() /// hug the width of the inner content
                .background(VisualEffectView(.systemChromeMaterial))
                .cornerRadius(12)
                .popoverContainerShadow()
            }
        }
    }
}

// struct MenuButtonModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .padding()
//            .border(
//                Color(.secondaryLabel.withAlphaComponent(0.25)),
//                width: 0.3
//            )
//    }
// }
// struct MenuModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .padding()
//            .background(.blue, in: Capsule())
//    }
// }

//    .scaleEffect( /// Add a scale effect to shrink down the popover at first.
//        shrunk ? 0.2 : 1,
//        anchor: .topTrailing
//    )
//    .opacity(shrunk ? 0 : 1)
//    .onAppear {
//        withAnimation(
//            .spring(
//                response: 0.4,
//                dampingFraction: 0.8,
//                blendDuration: 1
//            )
//        ) {
//            shrunk = false
//        }
//
//        /// when the popover is about to be dismissed, shrink it again.
//        context.attributes.onDismiss = {
//            withAnimation(
//                .spring(
//                    response: 0.3,
//                    dampingFraction: 0.9,
//                    blendDuration: 1
//                )
//            ) {
//                shrunk = true
//            }
//        }
//    }

extension View {
    func popoverMenuGesture(animation: Animation?, isPressed: Binding<Bool>, model: PopoverTemplates.MenuModel) -> some View {
        self.gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    if !isPressed.wrappedValue {
                        withAnimation(animation) {
                            isPressed.wrappedValue = true
                        }
                    }

                    for frame in model.frames {
                        if frame.value.contains(value.location) {
                            model.hoveringIndex = frame.key
                        }
                    }
                }
                .onEnded { value in
                    for frame in model.frames {
                        if frame.value.contains(value.location) {
                            model.selectedIndex = frame.key
                        }
                    }
                    model.hoveringIndex = nil
                    withAnimation(animation) {
                        isPressed.wrappedValue = false
                    }
                }
        )
    }
}
