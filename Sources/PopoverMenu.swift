//
//  File.swift
//
//
//  Created by A. Zheng (github.com/aheze) on 2/3/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public struct PopoverMenuButton<Content: View>: View {
    @Environment(\.index) var index: Int?
    @EnvironmentObject var model: PopoverMenuModel
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

enum PopoverMenuGestureType {
    case attachedToLabel(pressed: (() -> Void)?)
    case attachedToPopover
}

class PopoverMenuModel: ObservableObject {
    @Published var present = false

    @Published var scale = CGFloat(0.1)

    @Published var hoveringIndex: Int?

    /// The selected button.
    @Published var selectedIndex: Int?

    @Published var frames: [Int: CGRect] = [:]
}

class PopoverMenuLabelModel: ObservableObject {
    /// The active (hovering) button.

//    @Published var isPressed = false

    @Published var currentPressUUID: UUID?
}

public struct PopoverMenuConfiguration {
    public var animation = Animation.default

    public init(animation: Animation = Animation.default) {
        self.animation = animation
    }
}

/**
 A built-from-scratch version of the system menu.
 */
public struct PopoverMenu<Views, Label: View>: View {
    @State var fadeButton = false

    /// View model for the child buttons.
    @StateObject var model = PopoverMenuModel()

    @StateObject var labelModel = PopoverMenuLabelModel()

    public let configuration: PopoverMenuConfiguration

    /// The menu buttons.
    public let content: TupleView<Views>

    public let label: (Bool) -> Label

    /**
     Create a custom menu.
     */
    public init(
        configuration: PopoverMenuConfiguration = PopoverMenuConfiguration(),
        @ViewBuilder content: @escaping () -> TupleView<Views>,
        @ViewBuilder label: @escaping (Bool) -> Label
    ) {
        self.configuration = configuration
        self.content = content()
        self.label = label
    }

    public var body: some View {
        label(fadeButton)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        if model.present == false {
                            labelModel.currentPressUUID = UUID()
                            let currentUUID = labelModel.currentPressUUID
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                if currentUUID == labelModel.currentPressUUID {
                                    model.selectedIndex = nil
                                    model.present = true
                                }
                            }
                        }

                        model.hoveringIndex = nil
                        for frame in model.frames {
                            if frame.value.contains(value.location) {
                                model.hoveringIndex = frame.key
                            }
                        }
                    }
                    .onEnded { value in

                        if labelModel.currentPressUUID != nil {
                            labelModel.currentPressUUID = nil
                            model.present = true
                        }
                        var found = false
                        for frame in model.frames {
                            if frame.value.contains(value.location) {
                                model.selectedIndex = frame.key
                                found = true
                            }
                        }

                        if found {
                            model.present = false
                        }

                        model.hoveringIndex = nil
                    }
            )
            .onValueChange(of: labelModel.currentPressUUID) { _, newUUID in
                withAnimation(configuration.animation) {
                    if newUUID != nil {
                        fadeButton = true
                    }
                }
            }
            .onValueChange(of: model.present) { _, newValue in
                if !newValue {
                    withAnimation(configuration.animation) {
                        fadeButton = false
                    }
                }
            }
            .popover(
                present: $model.present,
                attributes: {
                    $0.rubberBandingMode = .none
                }
            ) {
                PopoverMenuPopoverView(model: model, content: content.getViews)
            } background: {
                Color.black.opacity(0.3)
            }
    }
}

struct PopoverMenuPopoverView: View {
    @ObservedObject var model: PopoverMenuModel

    /// The menu buttons.
    public let content: [AnyView]

    public init(
        model: PopoverMenuModel,
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
            .background(PopoverTemplates.VisualEffectView(.prominent))
            .cornerRadius(12)
            .popoverContainerShadow()
            .scaleEffect(model.scale, anchor: getScaleAnchor(attributes: context.attributes))
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        model.hoveringIndex = nil
                        for frame in model.frames {
                            if frame.value.contains(value.location) {
                                model.hoveringIndex = frame.key
                            }
                        }
                    }
                    .onEnded { value in
                        var found = false
                        for frame in model.frames {
                            if frame.value.contains(value.location) {
                                model.selectedIndex = frame.key
                                found = true
                            }
                        }

                        if found {
                            model.present = false
                        }
                        model.hoveringIndex = nil
                    }
            )
            .onAppear {
                withAnimation(
                    .spring(
                        response: 0.4,
                        dampingFraction: 0.8,
                        blendDuration: 1
                    )
                ) {
                    model.scale = 1
                }
                /// when the popover is about to be dismissed, shrink it again.
                context.attributes.onDismiss = {
                    withAnimation(
                        .spring(
                            response: 0.3,
                            dampingFraction: 0.9,
                            blendDuration: 1
                        )
                    ) {
                        model.scale = 0.1
                    }
                }
            }
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
