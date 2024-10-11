
//  PopoverContainerViewController.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 The View Controller that hosts `PopoverContainerView`. This is automatically managed.
 */
public class PopoverContainerViewController: UIViewController {
    /// The `UIView` used to handle gesture interactions for popovers.
    private var popoverGestureContainerView: PopoverGestureContainer?
    
    /// If this is nil, the view hasn't been laid out yet.
    var previousBounds: CGRect?
    
    /**
     Create a new `PopoverContainerViewController`. This is automatically managed.
     */
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Only update frames on a bounds change.
        if let previousBounds = previousBounds, previousBounds != view.bounds {
            /// Orientation or screen bounds changed, so update popover frames.
            popoverModel.updateFramesAfterBoundsChange()
        }
        
        /// Store the bounds for later.
        previousBounds = view.bounds
    }
    
    override public func loadView() {
        /**
         Instantiate the base `view`.
         */
        popoverGestureContainerView = PopoverGestureContainer(windowAvailable: { [unowned self] window in
            /// Embed `PopoverContainerView` in a view controller.
            let popoverContainerView = PopoverContainerView(popoverModel: popoverModel)
                .environment(\.window, window)
            
            let hostingController = UIHostingController(rootView: popoverContainerView)
            hostingController.view.frame = view.bounds
            hostingController.view.backgroundColor = .clear
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        })
        
        view = popoverGestureContainerView
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Use the presenting view controller's view as the next element in the gesture container's responder chain
        /// when a hit test indicates no popover was tapped.
        popoverGestureContainerView?.presentingViewGestureTarget = presentingViewController?.view
    }
    
    override public func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
    }
    
    private class PopoverGestureContainer: UIView {
        private let windowAvailable: (UIWindow) -> Void
        
        /// The `UIView` to forward hit tests to when a check fails in this view.
        weak var presentingViewGestureTarget: UIView?
        
        init(windowAvailable: @escaping (UIWindow) -> Void) {
            self.windowAvailable = windowAvailable
            super.init(frame: .zero)
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            if let window = window {
                windowAvailable(window)
            }
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
                    let allowedFrames = popover.attributes.blocksBackgroundTouchesAllowedFrames()
                    
                    if allowedFrames.contains(where: { $0.contains(point) }) {
                        dismissPopoverIfNecessary(popoverToDismiss: popover)
                        
//                        return nil
                        return presentingViewGestureTarget?.hitTest(point, with: event) ?? super.hitTest(point, with: event)
                    } else {
                        /// Receive the touch and block it from going through.
                        return super.hitTest(point, with: event)
                    }
                }
                
                /// Check if the touch hit an excluded view. If so, don't dismiss it.
                if popover.attributes.dismissal.mode.contains(.tapOutside) {
                    let excludedFrames = popover.attributes.dismissal.excludedFrames()
                    if excludedFrames.contains(where: { $0.contains(point) }) {
                        /// The touch hit an excluded view, so don't dismiss it.
                        return super.hitTest(point, with: event)
                    } else {
//                        return nil
                        return presentingViewGestureTarget?.hitTest(point, with: event) ?? super.hitTest(point, with: event)
                    }
                }
                
                /// All checks did not pass, which means the touch landed outside the popover. So, dismiss it if necessary.
                dismissPopoverIfNecessary(popoverToDismiss: popover)
            }
            
            /// The touch did not hit any popover, so pass it through to the hit testing target.
//            return nil
            return presentingViewGestureTarget?.hitTest(point, with: event) ?? super.hitTest(point, with: event)
        }
    }
}
