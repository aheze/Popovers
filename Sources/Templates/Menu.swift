//
//  Menu.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/3/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension Templates {
    /// A set of attributes for the popover menu.
    struct MenuConfiguration {
        public var holdDelay = CGFloat(0.2) /// The duration of a long press to activate the menu.
        public var presentationAnimation = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 1)
        public var dismissalAnimation = Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 1)
        public var labelFadeAnimation = Animation.default /// The animation used when calling the `fadeLabel`.
        public var clipContent = true /// Replicate the system's default clipping animation.
        public var sourceFrameInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        public var originAnchor = Popover.Attributes.Position.Anchor.bottom /// The label's anchor.
        public var popoverAnchor = Popover.Attributes.Position.Anchor.top /// The menu's anchor.
        public var scaleAnchor: Popover.Attributes.Position.Anchor? /// If nil, the anchor will be automatically picked.
        public var excludedFrames: (() -> [CGRect]) = { [] }
        public var menuBlur = UIBlurEffect.Style.prominent
        public var width: CGFloat? = CGFloat(240) /// If nil, hug the content.
        public var cornerRadius = CGFloat(14)
        public var showDivider = true /// Show divider between menu items.
        public var shadow = Shadow.system
        public var backgroundColor = Color.clear /// A color that is overlaid over the entire screen, just underneath the menu.
        public var scaleRange = CGFloat(40) ... CGFloat(90) /// For rubber banding - the range at which rubber banding should be applied.
        public var minimumScale = CGFloat(0.7) /// For rubber banding - the scale the the popover should shrink to when rubber banding.

        /// Create the default attributes for the popover menu.
        public init(
            holdDelay: CGFloat = CGFloat(0.2),
            presentationAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 1),
            dismissalAnimation: Animation = .spring(response: 0.5, dampingFraction: 0.9, blendDuration: 1),
            labelFadeAnimation: Animation = .easeOut,
            sourceFrameInset: UIEdgeInsets = .init(top: -8, left: -8, bottom: -8, right: -8),
            originAnchor: Popover.Attributes.Position.Anchor = .bottom,
            popoverAnchor: Popover.Attributes.Position.Anchor = .top,
            scaleAnchor: Popover.Attributes.Position.Anchor? = nil,
            excludedFrames: @escaping (() -> [CGRect]) = { [] },
            menuBlur: UIBlurEffect.Style = .prominent,
            width: CGFloat? = CGFloat(240),
            cornerRadius: CGFloat = CGFloat(14),
            showDivider: Bool = true,
            shadow: Shadow = .system,
            backgroundColor: Color = .clear,
            scaleRange: ClosedRange<CGFloat> = 30 ... 80,
            minimumScale: CGFloat = 0.85
        ) {
            self.holdDelay = holdDelay
            self.presentationAnimation = presentationAnimation
            self.dismissalAnimation = dismissalAnimation
            self.labelFadeAnimation = labelFadeAnimation
            self.sourceFrameInset = sourceFrameInset
            self.originAnchor = originAnchor
            self.popoverAnchor = popoverAnchor
            self.scaleAnchor = scaleAnchor
            self.excludedFrames = excludedFrames
            self.menuBlur = menuBlur
            self.width = width
            self.cornerRadius = cornerRadius
            self.showDivider = showDivider
            self.shadow = shadow
            self.backgroundColor = backgroundColor
            self.scaleRange = scaleRange
            self.minimumScale = minimumScale
        }
    }

    /**
     A built-from-scratch version of the system menu.
     */
    struct Menu<Label: View>: View {
        /// A unique ID for the menu (to support multiple menus in the same screen).
        @State var id = UUID()

        /// If the user is pressing down on the label, this will be a unique `UUID`.
        @State var labelPressUUID: UUID?

        /**
         If the label was pressed/dragged when the menu was already presented.
         In this case, dismiss the menu if the user lifts their finger on the label.
         */
        @State var labelPressedWhenAlreadyPresented = false

        /// The current position of the user's finger.
        @State var dragPosition: CGPoint?

        /// View model for the menu buttons.
        @ObservedObject var model = MenuModel()

        /// Allow presenting from an external view via `$present`.
        @Binding var overridePresent: Bool

        /// Attributes that determine what the menu looks like.
        public let configuration: MenuConfiguration

        /// The menu buttons.
        public let content: [AnyView]

        /// The origin label.
        public let label: (Bool) -> Label

        /// Fade the origin label.
        @State var fadeLabel = false

        /**
         A built-from-scratch version of the system menu, for SwiftUI.
         This initializer lets you pass in a multiple menu items.
         */
        public init<Contents>(
            present: Binding<Bool> = .constant(false),
            configuration buildConfiguration: @escaping ((inout MenuConfiguration) -> Void) = { _ in },
            @ViewBuilder content: @escaping () -> TupleView<Contents>,
            @ViewBuilder label: @escaping (Bool) -> Label
        ) {
            _overridePresent = present

            var configuration = MenuConfiguration()
            buildConfiguration(&configuration)
            self.configuration = configuration
            self.content = ViewExtractor.getViews(from: content)
            self.label = label
        }

        /**
         A built-from-scratch version of the system menu, for SwiftUI.
         This initializer lets you pass in a single menu item.
         */
        public init<Content: View>(
            present: Binding<Bool> = .constant(false),
            configuration buildConfiguration: @escaping ((inout MenuConfiguration) -> Void) = { _ in },
            @ViewBuilder content: @escaping () -> Content,
            @ViewBuilder label: @escaping (Bool) -> Label
        ) {
            _overridePresent = present

            var configuration = MenuConfiguration()
            buildConfiguration(&configuration)
            self.configuration = configuration
            self.content = [AnyView(content())]
            self.label = label
        }

        public var body: some View {
            WindowReader { window in
                label(fadeLabel)
                    .frameTag(id)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { value in

                                /// Keep the drag position updated for the `asyncAfter`.
                                dragPosition = value.location

                                MenuModel.onDragChanged(
                                    location: value.location,
                                    model: model,
                                    id: id,
                                    labelPressUUID: &labelPressUUID,
                                    labelFrame: window.frameTagged(id),
                                    configuration: configuration,
                                    window: window,
                                    labelPressedWhenAlreadyPresented: &labelPressedWhenAlreadyPresented
                                ) {
                                    labelPressUUID
                                } getDragPosition: {
                                    dragPosition
                                } present: { present in
                                    model.present = present
                                } fadeLabel: { fade in
                                    fadeLabel = fade
                                }
                            }
                            .onEnded { value in
                                MenuModel.onDragEnded(
                                    location: value.location,
                                    model: model,
                                    id: id,
                                    labelPressUUID: &labelPressUUID,
                                    labelFrame: window.frameTagged(id),
                                    configuration: configuration,
                                    window: window,
                                    labelPressedWhenAlreadyPresented: &labelPressedWhenAlreadyPresented
                                ) { present in
                                    model.present = present
                                } fadeLabel: { fade in
                                    fadeLabel = fade
                                }
                            }
                    )
                    .onValueChange(of: model.present) { _, present in
                        if !present {
                            withAnimation(configuration.labelFadeAnimation) {
                                fadeLabel = false
                                model.selectedIndex = nil
                                model.hoveringIndex = nil
                            }
                            overridePresent = present
                        }
                    }
                    .onValueChange(of: overridePresent) { _, present in
                        if present != model.present {
                            model.present = present
                            withAnimation(configuration.labelFadeAnimation) {
                                fadeLabel = present
                            }
                        }
                    }
                    .popover(
                        present: $model.present,
                        attributes: {
                            $0.position = .absolute(originAnchor: configuration.originAnchor, popoverAnchor: configuration.popoverAnchor)
                            $0.rubberBandingMode = .none
                            $0.dismissal.excludedFrames = {
                                [
                                    window.frameTagged(id)
                                ]
                                    + configuration.excludedFrames()
                            }
                            $0.sourceFrameInset = configuration.sourceFrameInset
                        }
                    ) {
                        MenuView(
                            model: model,
                            present: { model.present = $0 },
                            configuration: configuration,
                            content: content
                        )
                    } background: {
                        configuration.backgroundColor
                    }
            }
        }
    }

    /// Map each menu item index with its size.
    struct MenuItemSize {
        var index: Int
        var size: CGSize
    }

    internal class MenuModel: ObservableObject {
        /// Whether to show the popover or not.
        @Published var present = false

        /// The popover's scale (for rubber banding).
        @Published var scale = CGFloat(1)

        /// The index of the menu button that the user's finger hovers on.
        @Published var hoveringIndex: Int?

        /// The selected menu button if it exists.
        @Published var selectedIndex: Int?

        /// The frames of the menu buttons, relative to the window.
        @Published var sizes: [MenuItemSize] = []

        /**
         The indices of tappable menu buttons.
         `getIndex` will only return indices that are contained in here.
         */
        @Published var itemIndices = [Int]()

        /// The frame of the menu in global coordinates.
        @Published var menuFrame = CGRect.zero

        /// Get the menu button index that intersects the drag gesture's touch location.
        func getIndex(from location: CGPoint) -> Int? {
            /// Create frames from the sizes.
            var frames = [Int: CGRect]()
            for item in sizes {
                let previousSizes = sizes.filter { $0.index < item.index }
                let previousHeight = previousSizes.map { $0.size.height }.reduce(0, +)
                let frame = CGRect(x: 0, y: previousHeight, width: item.size.width, height: item.size.height)
                frames[item.index] = frame
            }

            let zeroedLocation = CGPoint(x: location.x - menuFrame.minX, y: location.y - menuFrame.minY)

            for (index, frame) in frames {
                if
                    frame.contains(zeroedLocation),
                    itemIndices.contains(index) /// Make sure that the index is a tappable button.
                {
                    return index
                }
            }
            return nil
        }

        func getDistanceFromMenu(from location: CGPoint) -> CGFloat? {
            let menuCenter = CGPoint(x: menuFrame.midX, y: menuFrame.midY)

            /// The location relative to the popover menu's center (0, 0)
            let normalizedLocation = CGPoint(x: location.x - menuCenter.x, y: location.y - menuCenter.y)

            if abs(normalizedLocation.y) >= menuFrame.height / 2, abs(normalizedLocation.y) >= abs(normalizedLocation.x) {
                /// top and bottom
                let distance = abs(normalizedLocation.y) - menuFrame.height / 2
                return distance
            } else {
                /// left and right
                let distance = abs(normalizedLocation.x) - menuFrame.width / 2
                return distance
            }
        }

        /// Get the anchor point to scale from.
        func getScaleAnchor(from context: Popover.Context) -> UnitPoint {
            if case let .absolute(_, popoverAnchor) = context.attributes.position {
                return popoverAnchor.unitPoint
            }

            return .center
        }

        /// Process the drag gesture, updating the menu to match.
        static func onDragChanged(
            location: CGPoint,
            model: MenuModel,
            id: UUID,
            labelPressUUID: inout UUID?,
            labelFrame: CGRect,
            configuration: MenuConfiguration,
            window: UIWindow?,
            labelPressedWhenAlreadyPresented: inout Bool,
            getCurrentLabelPressUUID: @escaping (() -> UUID?),
            getDragPosition: @escaping (() -> CGPoint?),
            present: @escaping ((Bool) -> Void),
            fadeLabel: @escaping ((Bool) -> Void)
        ) {
            if model.present == false {
                /// The menu is not yet presented.
                if labelPressUUID == nil {
                    labelPressUUID = UUID()
                    let currentUUID = labelPressUUID
                    DispatchQueue.main.asyncAfter(deadline: .now() + configuration.holdDelay) {
                        if
                            currentUUID == getCurrentLabelPressUUID(),
                            let dragPosition = getDragPosition()
                        {
                            if labelFrame.contains(dragPosition) {
                                present(true)
                            }
                        }
                    }
                }

                withAnimation(configuration.labelFadeAnimation) {
                    let shouldFade = labelFrame.contains(location)
                    fadeLabel(shouldFade)
                }
            } else if labelPressUUID == nil {
                /// The menu was already presented.
                labelPressUUID = UUID()
                labelPressedWhenAlreadyPresented = true
            } else {
                /// Highlight the button that the user's finger is over.
                model.hoveringIndex = model.getIndex(from: location)

                /// Rubber-band the menu.
                withAnimation {
                    if let distance = model.getDistanceFromMenu(from: location) {
                        if configuration.scaleRange.contains(distance) {
                            let percentage = (distance - configuration.scaleRange.lowerBound) / (configuration.scaleRange.upperBound - configuration.scaleRange.lowerBound)
                            let scale = 1 - (1 - configuration.minimumScale) * percentage
                            model.scale = scale
                        } else if distance < configuration.scaleRange.lowerBound {
                            model.scale = 1
                        } else {
                            model.scale = configuration.minimumScale
                        }
                    }
                }
            }
        }

        /// Process the drag gesture ending, updating the menu to match.
        static func onDragEnded(
            location: CGPoint,
            model: MenuModel,
            id: UUID,
            labelPressUUID: inout UUID?,
            labelFrame: CGRect,
            configuration: MenuConfiguration,
            window: UIWindow?,
            labelPressedWhenAlreadyPresented: inout Bool,
            present: @escaping ((Bool) -> Void),
            fadeLabel: @escaping ((Bool) -> Void)
        ) {
            withAnimation {
                model.scale = 1
            }

            labelPressUUID = nil

            /// The user started long pressing when the menu was **already** presented.
            if labelPressedWhenAlreadyPresented {
                labelPressedWhenAlreadyPresented = false

                let selectedIndex = model.getIndex(from: location)
                model.selectedIndex = selectedIndex
                model.hoveringIndex = nil

                /// The user lifted their finger on the label **and** it did not hit a menu item.
                if
                    selectedIndex == nil,
                    labelFrame.contains(location)
                {
                    present(false)
                }
            } else {
                if !model.present {
                    if labelFrame.contains(location) {
                        present(true)
                    } else {
                        withAnimation(configuration.labelFadeAnimation) {
                            fadeLabel(false)
                        }
                    }
                } else {
                    let selectedIndex = model.getIndex(from: location)
                    model.selectedIndex = selectedIndex
                    model.hoveringIndex = nil

                    /// The user lifted their finger on a button.
                    if selectedIndex != nil {
                        present(false)
                    }
                }
            }
        }
    }

    internal struct MenuView: View {
        @ObservedObject var model: MenuModel
        let present: (Bool) -> Void
        let configuration: MenuConfiguration

        /// The menu buttons.
        let content: [AnyView]

        /// For the scale animation.
        @State var expanded = false

        init(
            model: MenuModel,
            present: @escaping (Bool) -> Void,
            configuration: MenuConfiguration,
            content: [AnyView]
        ) {
            self.model = model
            self.present = present
            self.configuration = configuration
            self.content = content
        }

        var body: some View {
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

                            /// Use `sizeReader` to prevent interfering with the scale effect.
                            .sizeReader { size in
                                if let firstIndex = model.sizes.firstIndex(where: { $0.index == index }) {
                                    model.sizes[firstIndex].size = size
                                } else {
                                    model.sizes.append(MenuItemSize(index: index, size: size))
                                }
                            }

                        if configuration.showDivider, index != content.count - 1 {
                            Rectangle()
                                .fill(Color(UIColor.label))
                                .frame(height: 0.4)
                                .opacity(0.3)
                        }
                    }
                }
                .frame(width: configuration.width)
                .fixedSize() /// hug the width of the inner content
                .modifier(ClippedBackgroundModifier(context: context, configuration: configuration, expanded: expanded)) /// Clip the content if desired.
                .scaleEffect(expanded ? 1 : 0.1, anchor: configuration.scaleAnchor?.unitPoint ?? model.getScaleAnchor(from: context))
                .scaleEffect(model.scale, anchor: configuration.scaleAnchor?.unitPoint ?? model.getScaleAnchor(from: context))
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            model.hoveringIndex = model.getIndex(from: value.location)

                            /// Rubber-band the menu.
                            withAnimation {
                                if let distance = model.getDistanceFromMenu(from: value.location) {
                                    if configuration.scaleRange.contains(distance) {
                                        let percentage = (distance - configuration.scaleRange.lowerBound) / (configuration.scaleRange.upperBound - configuration.scaleRange.lowerBound)
                                        let scale = 1 - (1 - configuration.minimumScale) * percentage
                                        model.scale = scale
                                    } else if distance < configuration.scaleRange.lowerBound {
                                        model.scale = 1
                                    } else {
                                        model.scale = configuration.minimumScale
                                    }
                                }
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                model.scale = 1
                            }

                            let activeIndex = model.getIndex(from: value.location)
                            model.selectedIndex = activeIndex
                            model.hoveringIndex = nil
                            if activeIndex != nil {
                                present(false)
                            }
                        }
                )
                .onAppear {
                    withAnimation(configuration.presentationAnimation) {
                        expanded = true
                    }
                    /// when the popover is about to be dismissed, shrink it again.
                    context.attributes.onDismiss = {
                        withAnimation(configuration.dismissalAnimation) {
                            expanded = false
                        }
                    }
                    context.attributes.onContextChange = { context in
                        model.menuFrame = context.frame
                    }
                }
            }
        }
    }

    /// A special button for use inside `PopoverMenu`s.
    struct MenuItem<Content: View>: View {
        @Environment(\.index) var index: Int?
        @EnvironmentObject var model: MenuModel

        public let action: () -> Void
        public let label: (Bool) -> Content

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
                .onAppear {
                    if
                        let index = index,
                        !model.itemIndices.contains(index)
                    {
                        /// Append this button's index to the model's item indices.
                        model.itemIndices.append(index)
                    }
                }
        }
    }

    /// A wrapper for `PopoverMenuItem` that mimics the system menu button style.
    struct MenuButton: View {
        public let text: Text?
        public let image: Image?
        public let action: () -> Void

        /// A wrapper for `PopoverMenuItem` that mimics the system menu button style (title + image)
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

        /// A wrapper for `PopoverMenuItem` that mimics the system menu button style (title + image).
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
            MenuItem(action) { pressed in
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
                .background(pressed ? Templates.buttonHighlightColor : Color.clear) /// Add highlight effect when pressed.
            }
        }
    }

    /// Place this inside a Menu to separate content.
    struct MenuDivider: View {
        /// Place this inside a Menu to separate content.
        public init() {}
        public var body: some View {
            Rectangle()
                .fill(Color(UIColor.label))
                .opacity(0.15)
                .frame(height: 7)
        }
    }

    /// Replicates the system menu's subtle clip effect.
    internal struct ClippedBackgroundModifier: ViewModifier {
        let context: Popover.Context
        let configuration: MenuConfiguration
        let expanded: Bool
        func body(content: Content) -> some View {
            if configuration.clipContent {
                content

                    /// Replicates the system menu's subtle clip effect.
                    .mask(
                        Color.clear
                            .overlay(
                                RoundedRectangle(cornerRadius: configuration.cornerRadius)
                                    .frame(height: expanded ? nil : context.frame.height / 3),
                                alignment: .top
                            )
                    )

                    /// Avoid limiting the frame of the content to ensure proper hit-testing (for popover dismissal).
                    .background(
                        Templates.VisualEffectView(configuration.menuBlur)
                            .cornerRadius(configuration.cornerRadius)
                            .popoverShadow(shadow: configuration.shadow)
                            .frame(height: expanded ? nil : context.frame.height / 3),
                        alignment: .top
                    )
            } else {
                content
            }
        }
    }
}

/// For passing the index of the `MenuItem` into the view itself
extension EnvironmentValues {
    /// The index of the `MenuItem`.
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
