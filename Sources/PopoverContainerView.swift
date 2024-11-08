//
//  PopoverContainerView.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

#if os(iOS)
import SwiftUI

/**
 The container view that shows the popovers. This is automatically managed.
 */
struct PopoverContainerView: View {
    /// The view model that stores the popovers.
    @ObservedObject var popoverModel: PopoverModel

    /// The currently-dragging popover.
    @State var selectedPopover: Popover? = nil

    /// How much to offset the currently-dragging popover.
    @State var selectedPopoverOffset: CGSize = .zero

    var body: some View {
        /// Support multiple popovers without interfering with each other.
        ZStack {
            /// Loop over the popovers.
            ForEach(popoverModel.popovers) { popover in

                /// All frames are calculated from the origin at the top-left, so use `.topLeading`.
                ZStack(alignment: .topLeading) {
                    /// Show the popover's background.
                    popover.background

                    /// Show the popover's main content view.
                    HStack(alignment: .top) {
                        popover.view

                            /// Have VoiceOver read the popover view first, before the dismiss button.
                            .accessibility(sortPriority: 1)

                        /// If VoiceOver is on and a `dismissButtonLabel` was set, show it.
                        if
                            UIAccessibility.isVoiceOverRunning,
                            let dismissButtonLabel = popover.attributes.accessibility.dismissButtonLabel
                        {
                            Button {
                                popover.dismiss()
                            } label: {
                                dismissButtonLabel
                            }
                        }
                    }
                    /// Hide the popover until its size has been calculated.
                    .opacity(popover.context.size != nil ? 1 : 0)

                    /// Read the popover's size in the view.
                    .sizeReader(transaction: popover.context.transaction) { size in
                        if
                            let transaction = popover.context.transaction,
                            let existingSize = popover.context.size
                        {
                            /// If the size is different during an existing transaction, this means
                            /// the size is still not final and can change.
                            /// So, update without an animation - but just make sure it's not replacing an existing one.
                            if existingSize != size, !popover.context.isReplacement {
                                popover.updateFrame(with: size)
                                updatePopoverOffset(for: popover)
                                popoverModel.reload()
                            } else {
                                /// Otherwise, since the size is the same, the popover is *replacing* a previous popover - animate it.
                                /// This could also be true when the screen bounds changed.
                                withTransaction(transaction) {
                                    popover.updateFrame(with: size)
                                    updatePopoverOffset(for: popover)
                                    popoverModel.reload()
                                }
                            }
                            popover.context.transaction = nil
                        } else {
                            /// When `popover.context.size` is nil or there is no transaction, the popover was just presented.
                            popover.updateFrame(with: size)
                            updatePopoverOffset(for: popover)
                            popoverModel.reload()
                        }
                    }

                    /// Offset the popover by the gesture's translation, if this current popover is the selected one.
                    .modifier {
                        if #available(iOS 17, *) {
                            $0.offset(popover.context.offset)
                        } else {
                            $0.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .padding(edgeInsets(for: popover)) /// Apply edge padding so that the popover doesn't overflow off the screen.
                }

                /// Ensure the popover container can use up all available space.
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                /// Apply the presentation and dismissal transitions.
                .transition(
                    .asymmetric(
                        insertion: popover.attributes.presentation.transition ?? .opacity,
                        removal: popover.attributes.dismissal.transition ?? .opacity
                    )
                )

                /// Clean up the container view.
                .onDisappear {
                    popover.context.onDisappear?()
                }
            }
        }
        .edgesIgnoringSafeArea(.all) /// All calculations are done from the screen bounds.
    }

    /**
     Apply edge padding to squish the available space, preventing screen overflow.

     Since the popover's top and left are set via the frame origin in `Popover.swift`, only apply padding to the bottom and right.
     */
    func edgeInsets(for popover: Popover) -> EdgeInsets {
        let screenEdgePadding = popover.attributes.screenEdgePadding()
        let horizontalInsets = screenEdgePadding.left + screenEdgePadding.right
        let verticalInsets = screenEdgePadding.top + screenEdgePadding.bottom

        return EdgeInsets(
            top: 0,
            leading: 0,
            bottom: verticalInsets,
            trailing: horizontalInsets
        )
    }

    /// Get the offset of a popover in order to place it in its correct location.
    func updatePopoverOffset(for popover: Popover) {
        guard popover.context.size != nil else {
            popover.context.offset = .zero
            return
        }
        let frame = popover.context.staticFrame
        let offset = CGSize(
            width: frame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0),
            height: frame.origin.y + ((selectedPopover == popover) ? selectedPopoverOffset.height : 0)
        )
        popover.context.offset = offset
    }

    // MARK: - Dragging

    /// Apply the additional offset needed if a popover is dragged.
    func applyDraggingOffset(popover: Popover, translation: CGSize) {
        var selectedPopoverOffset = CGSize.zero

        /// If `.dragDown` or `.dragUp` is in the popover's dismissal mode, then apply rubber banding.
        func applyVerticalOffset(dragDown: Bool) {
            let condition = dragDown ? translation.height <= 0 : translation.height >= 0
            if condition {
                /// Popover was dragged in the opposite direction, so apply rubber banding.
                selectedPopoverOffset.height = getRubberBanding(translation: translation).height
            } else {
                selectedPopoverOffset.height = translation.height
            }
        }

        switch popover.attributes.position {
        case .absolute:
            if popover.attributes.dismissal.mode.contains(.dragDown) {
                applyVerticalOffset(dragDown: true)
            } else if popover.attributes.dismissal.mode.contains(.dragUp) {
                applyVerticalOffset(dragDown: false)
            } else {
                selectedPopoverOffset = applyRubberBanding(to: popover, translation: translation)
            }
        case let .relative(popoverAnchors):

            /// There is only 1 anchor for the popovers, so it can't be dragged to a different position.
            if popoverAnchors.count <= 1 {
                if popover.attributes.dismissal.mode.contains(.dragDown) {
                    applyVerticalOffset(dragDown: true)
                } else if popover.attributes.dismissal.mode.contains(.dragUp) {
                    applyVerticalOffset(dragDown: false)
                } else {
                    selectedPopoverOffset = applyRubberBanding(to: popover, translation: translation)
                }
            } else {
                /// Popover can be dragged to a different position, so don't apply any rubber banding and directly set its translation.
                selectedPopoverOffset = translation
            }
        }

        self.selectedPopoverOffset = selectedPopoverOffset
    }

    /// "Rubber-band" the popover's translation.
    func getRubberBanding(translation: CGSize) -> CGSize {
        var offset = CGSize.zero
        offset.width = pow(abs(translation.width), 0.7) * (translation.width > 0 ? 1 : -1)
        offset.height = pow(abs(translation.height), 0.7) * (translation.height > 0 ? 1 : -1)
        return offset
    }

    /// Apply rubber banding to the selected popover's offset.
    func applyRubberBanding(to popover: Popover, translation: CGSize) -> CGSize {
        let offset = getRubberBanding(translation: translation)
        var selectedPopoverOffset = CGSize.zero

        if popover.attributes.rubberBandingMode.contains(.xAxis) {
            selectedPopoverOffset.width = offset.width
        }
        if popover.attributes.rubberBandingMode.contains(.yAxis) {
            selectedPopoverOffset.height = offset.height
        }

        return selectedPopoverOffset
    }
}

internal extension View {
    /// Modify a view with a `ViewBuilder` closure.
    ///
    /// This represents a streamlining of the
    /// [`modifier`](https://developer.apple.com/documentation/swiftui/view/modifier(_:))
    /// \+ [`ViewModifier`](https://developer.apple.com/documentation/swiftui/viewmodifier)
    /// pattern.
    /// - Note: Useful only when you don't need to reuse the closure.
    /// If you do, turn the closure into an extension! ♻️
    func modifier<ModifiedContent: View>(
        @ViewBuilder body: (_ content: Self) -> ModifiedContent
    ) -> ModifiedContent {
        body(self)
    }
}
#endif
