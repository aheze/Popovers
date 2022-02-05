//
//  File.swift
//
//
//  Created by A. Zheng (github.com/aheze) on 2/3/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class PopoverMenuModel: ObservableObject {
    /// Whether to show the popover or not.
    @Published var present = false

    /// The popover's scale. Animate from `0.1` to `1.0` when it's presented.
    @Published var scale = CGFloat(0.1)

    /// The index of the menu button that the user's finger hovers on.
    @Published var hoveringIndex: Int?

    /// The selected menu button if it exists.
    @Published var selectedIndex: Int?

    /// The frames of the menu buttons, relative to the window.
    @Published var frames: [Int: CGRect] = [:]

    /// Get the menu button index that intersects the drag gesture's touch location.
    func getIndex(from location: CGPoint) -> Int? {
        for frame in frames {
            if frame.value.contains(location) {
                return frame.key
            }
        }
        return nil
    }

    /// Get the anchor point to scale from.
    func getScaleAnchor(from context: Popover.Context) -> UnitPoint {
        if case let .absolute(_, popoverAnchor) = context.attributes.position {
            return popoverAnchor.unitPoint
        }

        return .center
    }
}

public struct PopoverMenuConfiguration {
    public var holdDelay = CGFloat(0.15)
    public var presentationAnimation = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 1)
    public var dismissalAnimation = Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 1)
    public var labelFadeAnimation = Animation.default
    public var clipContent = true
    public var scaleAnchor: Popover.Attributes.Position.Anchor?
    public var menuBlur = UIBlurEffect.Style.prominent
    public var width: CGFloat? = CGFloat(240)
    public var cornerRadius = CGFloat(16)
    public var showDivider = true
    public var shadow = PopoverShadow.system
    public var backgroundColor = Color.black.opacity(0.1)

    public init(
        holdDelay: CGFloat = CGFloat(0.15),
        presentationAnimation: Animation = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 1),
        dismissalAnimation: Animation = Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 1),
        labelFadeAnimation: Animation = Animation.default,
        scaleAnchor: Popover.Attributes.Position.Anchor? = nil,
        menuBlur: UIBlurEffect.Style = UIBlurEffect.Style.prominent,
        width: CGFloat? = CGFloat(240),
        cornerRadius: CGFloat = CGFloat(16),
        showDivider: Bool = true,
        shadow: PopoverShadow = PopoverShadow.system,
        backgroundColor: Color = Color.black.opacity(0.1)
    ) {
        self.holdDelay = holdDelay
        self.presentationAnimation = presentationAnimation
        self.dismissalAnimation = dismissalAnimation
        self.labelFadeAnimation = labelFadeAnimation
        self.scaleAnchor = scaleAnchor
        self.menuBlur = menuBlur
        self.width = width
        self.cornerRadius = cornerRadius
        self.showDivider = showDivider
        self.shadow = shadow
        self.backgroundColor = backgroundColor
    }
}

/**
 A built-from-scratch version of the system menu.
 */
public struct PopoverMenu<Views, Label: View>: View {
    /// If the user is pressing down on the label, this will be a unique `UUID`.
    @State var labelPressUUID: UUID?

    @State var labelPressedWhenAlreadyPresented = false

    @State var dragPosition: CGPoint?

    /// View model for the menu buttons.
    @StateObject var model = PopoverMenuModel()

    /// Attributes that determine what the menu looks like.
    public let configuration: PopoverMenuConfiguration

    /// The menu buttons.
    public let content: TupleView<Views>

    /// The origin label.
    public let label: (Bool) -> Label

    /// Fade the origin label.
    @State var fadeLabel = false

    /**
     Create a custom menu.
     */
    public init(
        configuration: PopoverMenuConfiguration = .init(),
        @ViewBuilder content: @escaping () -> TupleView<Views>,
        @ViewBuilder label: @escaping (Bool) -> Label
    ) {
        self.configuration = configuration
        self.content = content()
        self.label = label
    }

    public var body: some View {
        WindowReader { window in
            label(fadeLabel)
                .frameTag("PopoverMenuLabel")
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in

                            dragPosition = value.location

                            if model.present == false {
                                /// The menu is not yet presented.
                                if labelPressUUID == nil {
                                    labelPressUUID = UUID()
                                    let currentUUID = labelPressUUID
                                    DispatchQueue.main.asyncAfter(deadline: .now() + configuration.holdDelay) {
                                        if
                                            currentUUID == labelPressUUID,
                                            let dragPosition = dragPosition
                                        {
                                            if window.frameTagged("PopoverMenuLabel").contains(dragPosition) {
                                                model.present = true
                                            }
                                        }
                                    }
                                }

                                withAnimation(configuration.labelFadeAnimation) {
                                    fadeLabel = window.frameTagged("PopoverMenuLabel").contains(value.location)
                                }
                            } else if labelPressUUID == nil {
                                /// The menu was already presented.
                                labelPressUUID = UUID()
                                labelPressedWhenAlreadyPresented = true
                            } else {
                                /// Highlight the button that the user's finger is over.
                                model.hoveringIndex = model.getIndex(from: value.location)
                            }
                        }
                        .onEnded { value in
                            labelPressUUID = nil

                            /// The user started long pressing when the menu was **already** presented.
                            if labelPressedWhenAlreadyPresented {
                                labelPressedWhenAlreadyPresented = false
                                if window.frameTagged("PopoverMenuLabel").contains(value.location) {
                                    model.present = false
                                }
                            } else {
                                if !model.present {
                                    if window.frameTagged("PopoverMenuLabel").contains(value.location) {
                                        model.present = true
                                    } else {
                                        withAnimation(configuration.labelFadeAnimation) {
                                            fadeLabel = false
                                        }
                                    }
                                } else {
                                    let selectedIndex = model.getIndex(from: value.location)
                                    model.selectedIndex = selectedIndex
                                    model.hoveringIndex = nil

                                    /// The user lifted their finger on a button.
                                    if selectedIndex != nil {
                                        model.present = false
                                    }
                                }
                            }
                        }
                )
                .onValueChange(of: model.present) { _, present in
                    if !present {
                        withAnimation(configuration.labelFadeAnimation) {
                            fadeLabel = false
                        }
                    }
                }
                .popover(
                    present: $model.present,
                    attributes: {
                        $0.rubberBandingMode = .none
                        $0.dismissal.excludedFrames = { [window.frameTagged("PopoverMenuLabel")] }
                    }
                ) {
                    PopoverMenuView(model: model, configuration: configuration, content: content.getViews)
                } background: {
                    configuration.backgroundColor
                }
        }
    }
}

struct PopoverMenuView: View {
    @ObservedObject var model: PopoverMenuModel

    let configuration: PopoverMenuConfiguration

    /// The menu buttons.
    let content: [AnyView]

    init(
        model: PopoverMenuModel,
        configuration: PopoverMenuConfiguration,
        content: [AnyView]
    ) {
        self.model = model
        self.configuration = configuration
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

                        /// Work with frames.
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .frameReader { rect in
                            model.frames[index] = rect
                        }

                    if configuration.showDivider, index != content.count - 1 {
                        Rectangle()
                            .fill(Color(UIColor.label))
                            .frame(height: 0.33)
                            .opacity(0.3)
                    }
                }
            }
            .frame(width: configuration.width)
            .fixedSize() /// hug the width of the inner content
            .modifier(ClippedModifier(context: context, configuration: configuration, expanded: model.scale >= 1)) /// Clip the content if desired.
            .background(PopoverTemplates.VisualEffectView(configuration.menuBlur))
            .cornerRadius(configuration.cornerRadius)
            .popoverShadow(shadow: configuration.shadow)
            .scaleEffect(model.scale, anchor: configuration.scaleAnchor?.unitPoint ?? model.getScaleAnchor(from: context))
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        model.hoveringIndex = model.getIndex(from: value.location)
                    }
                    .onEnded { value in
                        let activeIndex = model.getIndex(from: value.location)
                        model.selectedIndex = activeIndex
                        model.hoveringIndex = nil
                        if activeIndex != nil {
                            model.present = false
                        }
                    }
            )
            .onAppear {
                withAnimation(configuration.presentationAnimation) {
                    model.scale = 1
                }
                /// when the popover is about to be dismissed, shrink it again.
                context.attributes.onDismiss = {
                    withAnimation(configuration.dismissalAnimation) {
                        model.scale = 0.1
                    }
                }
            }
        }
    }
}

public struct PopoverMenuItem<Content: View>: View {
    @Environment(\.index) var index: Int?
    @EnvironmentObject var model: PopoverMenuModel

    let action: () -> Void
    let label: (Bool) -> Content

    public init(
        _ action: @escaping (() -> Void),
        label: @escaping (Bool) -> Content
    ) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        label(model.hoveringIndex == index)
            .onValueChange(of: model.selectedIndex) { _, newValue in
                if newValue == index {
                    action()
                }
            }
    }
}

public struct PopoverMenuButton: View {
    public let text: Text?
    public let image: Image?
    public let action: () -> Void

    public init(
        title: String? = nil,
        systemImage: String? = nil,
        _ action: @escaping (() -> Void)
    ) {
        if let title = title {
            text = Text(title)
        } else {
            text = nil
        }
        if let systemImage = systemImage {
            image = Image(systemName: systemImage)
        } else {
            image = nil
        }
        self.action = action
    }

    public init(
        text: Text? = nil,
        image: Image? = nil,
        _ action: @escaping (() -> Void)
    ) {
        self.text = text
        self.image = image
        self.action = action
    }

    public var body: some View {
        PopoverMenuItem(action) { pressed in
            HStack {
                if let text = text {
                    text
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let image = image {
                    image
                }
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18))
            .background(pressed ? PopoverTemplates.buttonHighlightColor : Color.clear)
        }
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

struct SystemMenuButtonModifier: ViewModifier {
    let pressed: Bool?
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
            .background(getBackground())
    }

    func getBackground() -> some View {
        if
            let pressed = pressed,
            pressed
        {
            return PopoverTemplates.buttonHighlightColor
        }
        return Color.clear
    }
}

struct ClippedModifier: ViewModifier {
    let context: Popover.Context
    let configuration: PopoverMenuConfiguration
    let expanded: Bool
    func body(content: Content) -> some View {
        if configuration.clipContent {
            content

                /// Replicates the system menu's subtle clip effect.
                .frame(height: expanded ? nil : context.frame.height / 2, alignment: .top)
                .clipped()
        } else {
            content
        }
    }
}

public extension View {
    func systemMenuButtonStyle(pressed: Bool? = nil) -> some View {
        modifier(SystemMenuButtonModifier(pressed: pressed))
    }
}
