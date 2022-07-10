//
//  Menu+SwiftUI.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 6/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

#if os(iOS)
import SwiftUI

public extension Templates {
    /**
     A built-from-scratch version of the system menu.
     */
    @available(iOS 14.0, *)
    struct Menu<Label: View, Content: View>: View {
        /// View model for the menu buttons. Should be `StateObject` to avoid getting recreated by SwiftUI, but this works on iOS 13.
        @StateObject var model: MenuModel

        /// View model for controlling menu gestures.
        @StateObject var gestureModel: MenuGestureModel

        /// Allow presenting from an external view via `$present`.
        @Binding var overridePresent: Bool

        var temporaryConfiguration: MenuConfiguration?

        /// The menu buttons.
        public let content: () -> Content

        /// The origin label.
        public let label: (Bool) -> Label

        /// Fade the origin label.
        @State var fadeLabel = false

        /**
         A built-from-scratch version of the system menu, for SwiftUI.
         */
        public init(
            present: Binding<Bool> = .constant(false),
            configuration buildConfiguration: @escaping ((inout MenuConfiguration) -> Void) = { _ in },
            @ViewBuilder content: @escaping () -> Content,
            @ViewBuilder label: @escaping (Bool) -> Label
        ) {
            _overridePresent = present
            _model = StateObject(wrappedValue: MenuModel(buildConfiguration: buildConfiguration))
            _gestureModel = StateObject(wrappedValue: MenuGestureModel())
            self.content = content
            self.label = label
        }

        public var body: some View {
            WindowReader { window in
                label(fadeLabel)
                    .frameTag(model.id)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { value in

                                gestureModel.onDragChanged(
                                    newDragLocation: value.location,
                                    model: model,
                                    labelFrame: window.frameTagged(model.id),
                                    window: window
                                ) { present in
                                    model.present = present
                                } fadeLabel: { fade in
                                    fadeLabel = fade
                                }
                            }
                            .onEnded { value in
                                gestureModel.onDragEnded(
                                    newDragLocation: value.location,
                                    model: model,
                                    labelFrame: window.frameTagged(model.id),
                                    window: window
                                ) { present in
                                    model.present = present
                                } fadeLabel: { fade in
                                    fadeLabel = fade
                                }
                            }
                    )
                    .onValueChange(of: model.present) { _, present in
                        if !present {
                            withAnimation(model.configuration.labelFadeAnimation) {
                                fadeLabel = false
                                model.selectedItemID = nil
                                model.hoveringItemID = nil
                            }
                            overridePresent = present
                        }
                    }
                    .onValueChange(of: overridePresent) { _, present in
                        if present != model.present {
                            model.present = present
                            withAnimation(model.configuration.labelFadeAnimation) {
                                fadeLabel = present
                            }
                        }
                    }
                    .popover(
                        present: $model.present,
                        attributes: {
                            print("getting attributes. \(model.configuration.originAnchor)")
                            $0.position = .absolute(
                                originAnchor: model.configuration.originAnchor,
                                popoverAnchor: model.configuration.popoverAnchor
                            )
                            $0.rubberBandingMode = .none
                            $0.dismissal.excludedFrames = {
                                [
                                    window.frameTagged(model.id),
                                ]
                                    + model.configuration.excludedFrames()
                            }
                            $0.sourceFrameInset = model.configuration.sourceFrameInset
                        }
                    ) {
                        MenuView(
                            model: model,
                            content: content
                        )
                    } background: {
                        model.configuration.backgroundColor
                    }
            }
        }
    }
}
#endif
