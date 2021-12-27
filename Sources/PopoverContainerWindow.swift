//
//  PopoverContainerWindow.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

/**
 The window that contains the popovers, overlaid over the main one. This is automatically managed.
 */
public class PopoverContainerWindow: UIWindow {
    
    /// The popover model that contains the popovers.
    public var popoverModel: PopoverModel
    
    /// The view controller that holds the popover.
    public lazy var popoverContainerViewController: PopoverContainerViewController = {
        let popoverContainerViewController = PopoverContainerViewController(
            popoverModel: popoverModel,
            windowScene: windowScene
        )
        return popoverContainerViewController
    }()
    
    /// Create a new container window for popovers. This is automatically managed.
    public init(popoverModel: PopoverModel, windowScene: UIWindowScene?) {
        self.popoverModel = popoverModel
        
        if let windowScene = windowScene {
            super.init(windowScene: windowScene)
        } else {
            
            /// no scene was provided, so fall back to the other window initializer.
            super.init(frame: UIScreen.main.bounds)
        }
        
        self.rootViewController = popoverContainerViewController
        self.windowLevel = .alert
        self.backgroundColor = .clear
        self.makeKeyAndVisible()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
     Determine if touches should land on popovers or pass through to the underlying view.
     
     The popover container view takes up the entire screen, so normally it would block all touches from going through. This method fixes that.
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        /// Make sure the hit event was actually a touch and not a cursor hover or something else.
        guard event.map({ $0.type == .touches }) ?? true else { return nil }
        
        /// Only loop through the popovers that are in this window.
        let popovers = popoverModel.popovers.filter { $0.context.windowScene == windowScene }
        
        /// The current popovers' frames
        let popoverFrames = popovers.map { $0.context.frame }
        
        /// Dismiss a popover, knowing that its frame does not contain the touch.
        func dismissPopoverIfNecessary(popoverToDismiss: Popover) {
            if
                popoverToDismiss.attributes.dismissal.mode.contains(.tapOutside), /// The popover can be automatically dismissed when tapped outside.
                popoverToDismiss.attributes.dismissal.tapOutsideIncludesOtherPopovers || /// The popover can be dismissed even if the touch hit another popover, **or...**
                !popoverFrames.contains(where: { $0.contains(point) }) /// ... no other popover frame contains the point (the touch landed outside)
            {
                Popovers.dismiss(popoverToDismiss)
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
                    
                    /// The touch hit an excluded view, so don't dismiss it.
                    continue
                }
            }
            
            /// All checks did not pass, which means the touch landed outside the popover. So, dismiss it if necessary.
            dismissPopoverIfNecessary(popoverToDismiss: popover)
        }
        
        /// The touch did not hit any popover, so pass it through.
        return nil
    }
}

public extension UIApplication {
    var currentWindowScene: UIWindowScene? {
        
        /// Get the current window scene. `keyWindow` is deprecated, but this seems to be the only way. See https://tengl.net/blog/2021/11/9/uiapplication-key-window-replacement
        UIApplication.shared.keyWindow?.windowScene
    }
}
