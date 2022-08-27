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
        public var presentationAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 1)
        public var dismissalAnimation = Animation.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 1)
        public var labelFadeAnimation = Animation.default /// The animation used when calling the `fadeLabel`.
        public var clipContent = true /// Replicate the system's default clipping animation.
        public var clipAlignment = Alignment.top /// Which edge the clipping animation should be animate from.
        public var sourceFrameInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        public var originAnchor = Popover.Attributes.Position.Anchor.bottom /// The label's anchor.
        public var popoverAnchor = Popover.Attributes.Position.Anchor.top /// The menu's anchor.
        public var scaleAnchor: Popover.Attributes.Position.Anchor? /// If nil, the anchor will be automatically picked.
        public var excludedFrames: (() -> [CGRect]) = { [] }
        public var menuBlur = UIBlurEffect.Style.prominent
        public var width: CGFloat? = CGFloat(240) /// If nil, hug the content.
        public var cornerRadius = CGFloat(14)
        public var shadow = Shadow.system
        public var backgroundColor = Color.clear /// A color that is overlaid over the entire screen, just underneath the menu.
        public var scaleRange = CGFloat(40) ... CGFloat(90) /// For rubber banding - the range at which rubber banding should be applied.
        public var minimumScale = CGFloat(0.7) /// For rubber banding - the scale the the popover should shrink to when rubber banding.
        public var useEntireMenuAsGestureHotspot: Bool = true /// Attach the gesture recognizer to the entire menu, for selection/dismissal. Set to false if using custom `MenuGestureHotspot`.
        public var dismissAfterSelecting = true /// Dismiss the menu after selecting an item.
        public var onLiftWithoutSelecting: (() -> Void)? = {} /// Called when the user lifts their finger either outside the menu, or in between menu items.

        /// Create the default attributes for the popover menu.
        public init(
            holdDelay: CGFloat = CGFloat(0.2),
            presentationAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 1),
            dismissalAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.9, blendDuration: 1),
            labelFadeAnimation: Animation = .easeOut,
            clipContent: Bool = true,
            clipAlignment: Alignment = .top,
            sourceFrameInset: UIEdgeInsets = .init(top: -8, left: -8, bottom: -8, right: -8),
            originAnchor: Popover.Attributes.Position.Anchor = .bottom,
            popoverAnchor: Popover.Attributes.Position.Anchor = .top,
            scaleAnchor: Popover.Attributes.Position.Anchor? = nil,
            excludedFrames: @escaping (() -> [CGRect]) = { [] },
            menuBlur: UIBlurEffect.Style = .prominent,
            width: CGFloat? = CGFloat(240),
            cornerRadius: CGFloat = CGFloat(14),
            shadow: Shadow = .system,
            backgroundColor: Color = .clear,
            scaleRange: ClosedRange<CGFloat> = 30 ... 80,
            minimumScale: CGFloat = 0.85,
            dismissAfterSelecting: Bool = true,
            onLiftWithoutSelecting: (() -> Void)? = {}
        ) {
            self.holdDelay = holdDelay
            self.presentationAnimation = presentationAnimation
            self.dismissalAnimation = dismissalAnimation
            self.labelFadeAnimation = labelFadeAnimation
            self.clipContent = clipContent
            self.clipAlignment = clipAlignment
            self.sourceFrameInset = sourceFrameInset
            self.originAnchor = originAnchor
            self.popoverAnchor = popoverAnchor
            self.scaleAnchor = scaleAnchor
            self.excludedFrames = excludedFrames
            self.menuBlur = menuBlur
            self.width = width
            self.cornerRadius = cornerRadius
            self.shadow = shadow
            self.backgroundColor = backgroundColor
            self.scaleRange = scaleRange
            self.minimumScale = minimumScale
            self.dismissAfterSelecting = dismissAfterSelecting
            self.onLiftWithoutSelecting = onLiftWithoutSelecting
        }
    }

    /// The popover that gets presented.
    internal struct MenuView<Content: View>: View {
        @ObservedObject var model: MenuModel

        /// The menu buttons.
        var content: Content

        /// For the scale animation.
        @State var expanded = false

        init(
            model: MenuModel,
            @ViewBuilder content: () -> Content
        ) {
            self.model = model
            self.content = content()
        }

        var body: some View {
            /// Reference this here instead of repeating `model.configuration` over and over again.
            let configuration = model.configuration

            PopoverReader { context in
                content

                    /// Inject model.
                    .environmentObject(model)

                    /// Work with frames.
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .frame(width: configuration.width)
                    .fixedSize() /// Hug the width of the inner content.
                    .modifier(
                        ClippedBackgroundModifier(
                            context: context,
                            configuration: configuration,
                            expanded: expanded
                        )
                    ) /// Clip the content if desired.
                    .scaleEffect(expanded ? 1 : 0.2, anchor: configuration.scaleAnchor?.unitPoint ?? model.getScaleAnchor(from: context))
                    .scaleEffect(model.scale, anchor: configuration.scaleAnchor?.unitPoint ?? model.getScaleAnchor(from: context))
                    .if(model.configuration.useEntireMenuAsGestureHotspot) {
                        $0.menuGesture(model: model) /// Attach a gesture hotspot to the entire view if necessary.
                    }
                    .onAppear {
                        withAnimation(configuration.presentationAnimation) {
                            expanded = true
                        }
                        /// When the popover is about to be dismissed, shrink it again.
                        context.attributes.onDismiss = {
                            withAnimation(configuration.dismissalAnimation) {
                                expanded = false
                            }

                            /// Clear frames once the menu is done presenting.
                            model.frames = [:]
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
        @State var itemID = UUID()
        @EnvironmentObject var model: MenuModel

        public let action: () -> Void
        public let label: (Bool) -> Content

        public init(
            _ action: @escaping (() -> Void),
            @ViewBuilder label: @escaping (Bool) -> Content
        ) {
            self.action = action
            self.label = label
        }

        public var body: some View {
            label(model.hoveringItemID == itemID)

                /// Read the frame of the menu item.
                .frameReader { frame in

                    /// Don't set frames when dismissing.
                    guard model.present else { return }

                    model.frames[itemID] = frame
                }
                .onValueChange(of: model.selectedItemID) { _, newValue in
                    if newValue == itemID {
                        action()
                    }
                    model.selectedItemID = nil
                }
        }
    }

    /// A wrapper for `PopoverMenuItem` that mimics the system menu button style.
    struct MenuButton: View {
        public let text: Text?
        public let image: Image?
        public let action: () -> Void
        private var disabled: Bool = false

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

        var baseButton: some View {
            HStack {
                if let text = text {
                    text
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let image = image {
                    image
                }
            }
            .accessibilityElement(children: .combine) /// Merge text and image into a single element.
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18))
        }

        public var body: some View {
            /// Rendering outside of `MenuItem` when disabled because: 1) actions aren't run, 2) so tapping the disabled button won't dismiss the popover.
            if self.disabled {
                baseButton
                    .foregroundColor(.secondary) /// Add dimmed effect when disabled
                    .opacity(0.9)
            } else {
                MenuItem(action) { pressed in
                    baseButton
                        .background(pressed ? Templates.buttonHighlightColor : Color.clear) /// Add highlight effect when pressed.
                }
            }
        }

        /// Disable this menu button.
        public func disabled(_ disabled: Bool = true) -> Self {
            var newView = self
            newView.disabled = disabled
            return newView
        }
    }

    struct MenuGestureHotspot<Content: View>: View {
        @EnvironmentObject var model: MenuModel
        public let content: () -> Content

        public init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content
        }

        public var body: some View {
            content()
                .menuGesture(model: model)
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
                                alignment: configuration.clipAlignment
                            )
                    )

                    /// Avoid limiting the frame of the content to ensure proper hit-testing (for popover dismissal).
                    .background(
                        Templates.VisualEffectView(configuration.menuBlur)
                            .cornerRadius(configuration.cornerRadius)
                            .popoverShadow(shadow: configuration.shadow)
                            .frame(height: expanded ? nil : context.frame.height / 3),
                        alignment: configuration.clipAlignment
                    )
            } else {
                content
            }
        }
    }
}

extension View {
    func menuGesture(model: Templates.MenuModel) -> some View {
        let configuration = model.configuration

        return simultaneousGesture(
            /// Handle gestures that started on the popover.
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    model.hoveringItemID = model.getItemID(from: value.location)

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

                /// Clicked (tap down, then lift) on a a selection
                .onEnded { value in
                    withAnimation {
                        model.scale = 1
                    }

                    let selectedItemID = model.getItemID(from: value.location)
                    model.selectedItemID = selectedItemID
                    model.hoveringItemID = nil

                    if selectedItemID == nil {
                        /// The user lifted their finger outside an item target.
                        model.configuration.onLiftWithoutSelecting?()
                    } else if model.configuration.dismissAfterSelecting {
                        /// Dismiss if the user lifted up their finger on an item.
                        model.present = false
                    }
                }
        )
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
