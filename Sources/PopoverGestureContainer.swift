//
//  PopoverGestureContainer.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/// A hosting view for `PopoverContainerView` with tap filtering.
class PopoverGestureContainer: UIView {
    /// A closure to be invoked when this view is inserted into a window's view hierarchy.
    var onMovedToWindow: (() -> Void)?

    /// Create a new `PopoverGestureContainer`.
    override init(frame: CGRect) {
        super.init(frame: frame)

        /// Allow resizing.
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        /// Orientation or screen bounds changed, so update popover frames.
        popoverModel.updateFramesAfterBoundsChange()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        /// There might not be a window yet, but that's fine. Just wait until there's actually a window.
        guard let window = window else { return }

        /// Create the SwiftUI view that contains all the popovers.
        let popoverContainerView = PopoverContainerView(popoverModel: popoverModel)
            .environment(\.window, window) /// Inject the window.

        let hostingController = UIHostingController(rootView: popoverContainerView)
        hostingController.view.frame = bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(hostingController.view)

        /// Ensure the view is laid out so that SwiftUI animations don't stutter.
        setNeedsLayout()
        layoutIfNeeded()

        /// Let the presenter know that its window is available.
        onMovedToWindow?()
    }

    /**
     Determine if touches should land on popovers or pass through to the underlying view.

     The popover container view takes up the entire screen, so normally it would block all touches from going through. This method fixes that.
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        /// Make sure the hit event was actually a touch and not a cursor hover or something else.
        guard event.map({ $0.type == .touches }) ?? true else { return nil }

        /// Only loop through the popovers that are in this window.
        let popovers = popoverModel.popovers

        /// The current popovers' frames
        let popoverFrames = popovers.map { $0.context.frame }

        /// Dismiss a popover, knowing that its frame does not contain the touch.
        func dismissPopoverIfNecessary(popoverToDismiss: Popover) {
            if
                popoverToDismiss.attributes.dismissal.mode.contains(.tapOutside), /// The popover can be automatically dismissed when tapped outside.
                popoverToDismiss.attributes.dismissal.tapOutsideIncludesOtherPopovers || /// The popover can be dismissed even if the touch hit another popover, **or...**
                !popoverFrames.contains(where: { $0.contains(point) }) /// ... no other popover frame contains the point (the touch landed outside)
            {
                popoverToDismiss.dismiss()
            }
        }

        /// Loop through the popovers and see if the touch hit it.
        /// `reversed` to start from the most recently presented popovers, working backwards.
        for popover in popovers.reversed() {
            /// Check it the popover was hit.
            if popover.context.frame.contains(point) {
                /// Dismiss other popovers if they have `tapOutsideIncludesOtherPopovers` set to true.
                for popoverToDismiss in popovers {
                    if
                        popoverToDismiss != popover,
                        !popoverToDismiss.context.frame.contains(point) /// The popover's frame doesn't contain the touch point.
                    {
                        dismissPopoverIfNecessary(popoverToDismiss: popoverToDismiss)
                    }
                }

                /// Receive the touch and block it from going through.
                return super.hitTest(point, with: event)
            }

            /// The popover was not hit, so let it know that the user tapped outside.
            popover.attributes.onTapOutside?()

            /// If the popover has `blocksBackgroundTouches` set to true, stop underlying views from receiving the touch.
            if popover.attributes.blocksBackgroundTouches {
                /// Receive the touch and block it from going through.
                return super.hitTest(point, with: event)
            }

            /// Check if the touch hit an excluded view. If so, don't dismiss it.
            if popover.attributes.dismissal.mode.contains(.tapOutside) {
                let excludedFrames = popover.attributes.dismissal.excludedFrames()
                if excludedFrames.contains(where: { $0.contains(point) }) {
                    /**
                     The touch hit an excluded view, so don't dismiss it.
                     However, if the touch hit another popover, block it from passing through.
                     */
                    if popoverFrames.contains(where: { $0.contains(point) }) {
                        return super.hitTest(point, with: event)
                    } else {
                        return nil
                    }
                }
            }

            /// All checks did not pass, which means the touch landed outside the popover. So, dismiss it if necessary.
            dismissPopoverIfNecessary(popoverToDismiss: popover)
        }

        /// The touch did not hit any popover, so pass it through to the hit testing target.
        return nil
    }

    /// Dismiss all popovers if the accessibility escape gesture was performed.
    override func accessibilityPerformEscape() -> Bool {
        for popover in popoverModel.popovers {
            popover.dismiss()
        }

        return true
    }

    /// Boilerplate code.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("[Popovers] - Create this view programmatically.")
    }
}
