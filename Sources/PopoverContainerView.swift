//
//  PopoverContainerView.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

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
                        if let transaction = popover.context.transaction {
                            /// When `popover.context.size` is nil, the popover was just presented.
                            if popover.context.size == nil {
                                popover.updateFrame(with: size)
                                popoverModel.refresh(with: transaction)
                            } else {
                                /// Otherwise, the popover is *replacing* a previous popover, so animate it.
                                withTransaction(transaction) {
                                    popover.updateFrame(with: size)
                                    popoverModel.refresh(with: transaction)
                                }
                            }
                            popover.context.transaction = nil
                        }
                    }

                    /// Offset the popover by the gesture's translation, if this current popover is the selected one.
                    .offset(popoverOffset(for: popover))
                    /// Add the drag gesture.
                    .simultaneousGesture(
                        /// `minimumDistance: 2` is enough to allow scroll views to scroll, if one is contained in the popover.
                        DragGesture(minimumDistance: Popovers.minimumDragDistance)
                            .onChanged { value in

                                func update() {
                                    /// Apply the offset.
                                    applyDraggingOffset(popover: popover, translation: value.translation)

                                    /// Update the visual frame to account for the dragging offset.
                                    popover.context.frame = CGRect(
                                        origin: popover.context.staticFrame.origin + CGPoint(
                                            x: selectedPopoverOffset.width,
                                            y: selectedPopoverOffset.height
                                        ),
                                        size: popover.context.size ?? .zero
                                    )
                                }

                                /// Select the popover for dragging.
                                if selectedPopover == nil {
                                    /// Apply an animation to make up for the `minimumDistance`.
                                    withAnimation(.spring()) {
                                        selectedPopover = popover
                                        update()
                                    }
                                } else {
                                    /// The user is already dragging, so update the frames immediately.
                                    update()
                                }
                            }
                            .onEnded { value in

                                /// The expected dragging end point.
                                let finalOrigin = CGPoint(
                                    x: popover.context.staticFrame.origin.x + value.predictedEndTranslation.width,
                                    y: popover.context.staticFrame.origin.y + value.predictedEndTranslation.height
                                )

                                /// Recalculate the popover's frame.
                                withAnimation(.spring()) {
                                    selectedPopoverOffset = .zero

                                    /// Let the popover know that it finished dragging.
                                    popover.positionChanged(to: finalOrigin)
                                    popover.context.frame = popover.context.staticFrame
                                }

                                /// Unselect the popover.
                                self.selectedPopover = nil
                            },
                        including: popover.attributes.rubberBandingMode.isEmpty
                            ? .subviews /// Stop gesture and only allow those in the popover's view if dragging is not enabled.
                            : (popoverModel.popoversDraggable ? .all : .subviews) /// Otherwise, allow dragging - but also check if `popoversDraggable` is true first.
                    )
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
        let horizontalInsets = popover.attributes.screenEdgePadding.left + popover.attributes.screenEdgePadding.right
        let verticalInsets = popover.attributes.screenEdgePadding.top + popover.attributes.screenEdgePadding.bottom

        return EdgeInsets(
            top: 0,
            leading: 0,
            bottom: verticalInsets,
            trailing: horizontalInsets
        )
    }

    /// Get the offset of a popover in order to place it in its correct location.
    func popoverOffset(for popover: Popover) -> CGSize {
        guard popover.context.size != nil else { return .zero }
        let frame = popover.context.staticFrame
        let offset = CGSize(
            width: frame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0),
            height: frame.origin.y + ((selectedPopover == popover) ? selectedPopoverOffset.height : 0)
        )
        return offset
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
