//
//  Modifiers.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

/**
 Present a popover in SwiftUI. Access using `.popover(present:attributes:view:)`.
 */
struct PopoverModifier: ViewModifier {
    /**
     Binding to the popover's presentation state.

     Set to `true` to present, `false` to dismiss.
     */
    @Binding var present: Bool

    /// Build the attributes.
    let buildAttributes: (inout Popover.Attributes) -> Void

    /// The popover's view.
    let view: AnyView

    /// The popover's background.
    let background: AnyView

    /// Reference to the popover.
    @State var popover: Popover?

    /// The source frame to present from. Calculated by reading the frame of whatever view the modifier is attached to.
    @State var sourceFrame: CGRect?

    /// Create a popover. Use `.popover(present:attributes:view:)` to access.
    init<Content: View>(
        present: Binding<Bool>,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> Content
    ) {
        _present = present
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        background = AnyView(Color.clear)
    }

    /// Create a popover with a background. Use `.popover(present:attributes:view:background:)` to access.
    init<MainContent: View, BackgroundContent: View>(
        present: Binding<Bool>,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) {
        _present = present
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        self.background = AnyView(background())
    }

    func body(content: Content) -> some View {
        WindowReader { window in
            content

                /// Read the frame of the source view.
                .frameReader { frame in
                    sourceFrame = frame
                }

                /// Detect a state change in `$present`.
                .onValueChange(of: present) { oldValue, newValue in

                    /// Make sure there is a window first.
                    guard let window = window else {
                        print("[Popovers] - No window was found when presenting popover. Please file a bug report (https://github.com/aheze/Popovers/issues).")
                        return
                    }

                    /// `newValue` is true, so present the popover.
                    if newValue {
                        guard popover == nil else { return }
                        var attributes = Popover.Attributes()

                        /// Set the default source frame to the source view.
                        attributes.sourceFrame = {
                            if case .absolute = attributes.position {
                                return sourceFrame ?? .zero
                            } else {
                                return window.safeAreaLayoutGuide.layoutFrame
                            }
                        }

                        /// Build the attributes using the closure. If you supply a custom source frame, the default will be overridden.
                        buildAttributes(&attributes)

                        let popover = Popover(
                            attributes: attributes,
                            view: { view },
                            background: { background }
                        )

                        /// Store a reference to the popover.
                        self.popover = popover

                        /**
                         Listen to the internal `onDismiss` callback.

                         This is called just after the popover is removed from the model.
                         */
                        popover.context.onAutoDismiss = {
                            self.present = false
                            self.popover = nil /// Remove the reference to the popover.
                        }

                        /// Present the popover.
                        popover.present(in: window)

                    } else {
                        /// `$present` was set to `false`, dismiss the popover.

                        /// If there is still a popover, it means the client set `$present` to false.
                        guard let popover = popover else { return }

                        popover.dismiss()
                    }
                }
        }
    }
}

/**
 Present a popover that can transition to another popover in SwiftUI. Access using `.popover(selection:tag:attributes:view:)`.
 */
struct MultiPopoverModifier: ViewModifier {
    /// The current selection. Present the popover when this equals `tag.`
    @Binding var selection: String?

    /// The popover's tag.
    let tag: String

    /// Build the attributes.
    let buildAttributes: (inout Popover.Attributes) -> Void

    /// The popover's view.
    let view: AnyView

    /// The popover's background.
    let background: AnyView

    /// Reference to the popover.
    @State var popover: Popover?

    /// The source frame to present from. Calculated by reading the frame of whatever view the modifier is attached to.
    @State var sourceFrame: CGRect?

    /// Create a popover. Use `.popover(selection:tag:attributes:view)` to access.
    init<Content: View>(
        selection: Binding<String?>,
        tag: String,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void),
        @ViewBuilder view: @escaping () -> Content
    ) {
        _selection = selection
        self.tag = tag
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        background = AnyView(Color.clear)
    }

    /// Create a popover with a background. Use `.popover(selection:tag:attributes:view:background:)` to access.
    init<MainContent: View, BackgroundContent: View>(
        selection: Binding<String?>,
        tag: String,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void),
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) {
        _selection = selection
        self.tag = tag
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        self.background = AnyView(background())
    }

    func body(content: Content) -> some View {
        WindowReader { window in
            content

                /// Read the frame of the source view.
                .frameReader { frame in

                    /// Save the frame for now, until the selection changes (by that time, the window scene should be ready).
                    sourceFrame = frame
                }

                /// `$selection` was changed, determine if the popover should be presented, animated, or dismissed.
                .onValueChange(of: selection) { oldSelection, newSelection in

                    /// Make sure there is a window first.
                    guard let window = window else {
                        print("[Popovers] - No window was found when presenting popover. Please file a bug report (https://github.com/aheze/Popovers/issues).")
                        return
                    }

                    let model = window.popoverModel

                    /// Save the frame in `selectionFrameTags` to provide `excludedFrames`.
                    model.selectionFrameTags[tag] = sourceFrame

                    /// If the new selection is nil, dismiss the popover.
                    guard newSelection != nil else {
                        if let popover = popover {
                            popover.dismiss()
                        }
                        return
                    }

                    /// New selection is this popover, so present.
                    if newSelection == tag {
                        var attributes = Popover.Attributes()

                        /// Set the attributes' tag as `self.tag`.
                        attributes.tag = tag

                        /**
                         Provide the other views' frames excluded frames.
                         This makes sure that the popover isn't dismissed when you tap outside to present another popover.
                         To opt-out, set `attributes.dismissal.excludedFrames` manually.
                         */
                        attributes.dismissal.excludedFrames = { Array(window.popoverModel.selectionFrameTags.values) }

                        /// Set the source frame.
                        attributes.sourceFrame = {
                            if case .absolute = attributes.position {
                                return sourceFrame ?? .zero
                            } else {
                                return window.safeAreaLayoutGuide.layoutFrame
                            }
                        }

                        /// Build the attributes.
                        buildAttributes(&attributes)

                        let popover = Popover(
                            attributes: attributes,
                            view: { view },
                            background: { background }
                        )

                        /// Store a reference to the popover.
                        self.popover = popover

                        /**
                         Listen to the internal `onDismiss` callback.

                         This is called just after the popover is removed from the model.
                         */
                        popover.context.onAutoDismiss = {
                            self.selection = nil
                            self.popover = nil /// Remove the reference to the popover.
                        }

                        /// If an old selection with the same tag exists, animate the change.
                        if let oldSelection = oldSelection, let oldPopover = window.popover(tagged: oldSelection) {
                            oldPopover.replace(with: popover)
                        } else {
                            /// Otherwise, present the popover.
                            popover.present(in: window)
                        }
                    }
                }
        }
    }
}

public extension View {
    /**
     Popover for SwiftUI.
     - parameter present: The binding to the popover's presentation state. Set to `true` to present, `false` to dismiss.
     - parameter attributes: The popover's attributes.
     - parameter view: The popover's view.
     */
    func popover<Content: View>(
        present: Binding<Bool>,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> Content
    ) -> some View {
        return modifier(
            PopoverModifier(
                present: present,
                buildAttributes: buildAttributes,
                view: view
            )
        )
    }

    /**
     Popover for SwiftUI with a background.
     - parameter present: The binding to the popover's presentation state. Set to `true` to present, `false` to dismiss.
     - parameter attributes: The popover's attributes.
     - parameter view: The popover's view.
     - parameter background: The popover's background.
     */
    func popover<MainContent: View, BackgroundContent: View>(
        present: Binding<Bool>,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) -> some View {
        return modifier(
            PopoverModifier(
                present: present,
                buildAttributes: buildAttributes,
                view: view,
                background: background
            )
        )
    }

    /**
     For presenting multiple popovers in SwiftUI.
     - parameter selection: The binding to the popover's presentation state. When this is equal to `tag`, the popover will present.
     - parameter tag: The popover's tag. Equivalent to `attributes.tag`.
     - parameter attributes: The popover's attributes.
     - parameter view: The popover's view.
     */
    func popover<Content: View>(
        selection: Binding<String?>,
        tag: String,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> Content
    ) -> some View {
        return modifier(
            MultiPopoverModifier(
                selection: selection,
                tag: tag,
                buildAttributes: buildAttributes,
                view: view
            )
        )
    }

    /**
     For presenting multiple popovers with backgrounds in SwiftUI.
     - parameter selection: The binding to the popover's presentation state. When this is equal to `tag`, the popover will present.
     - parameter tag: The popover's tag. Equivalent to `attributes.tag`.
     - parameter attributes: The popover's attributes.
     - parameter view: The popover's view.
     - parameter background: The popover's background.
     */
    func popover<MainContent: View, BackgroundContent: View>(
        selection: Binding<String?>,
        tag: String,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) -> some View {
        return modifier(
            MultiPopoverModifier(
                selection: selection,
                tag: tag,
                buildAttributes: buildAttributes,
                view: view,
                background: background
            )
        )
    }
}
