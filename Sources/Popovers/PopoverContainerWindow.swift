//
//  PopoverContainerWindow.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftUI

/**
 The window that contains the popovers, overlaid over the main one. This is automatically managed.
 */
public class PopoverContainerWindow: UIWindow {
    
    /// The popover model that contains the popovers.
    public var popoverModel: PopoverModel
    
    /// The scene that this window is tied to.
    public var scene: UIWindowScene?
    
    /// The view controller that holds the popover.
    public lazy var popoverContainerViewController: PopoverContainerViewController = {
        let popoverContainerViewController = PopoverContainerViewController(popoverModel: popoverModel)
        return popoverContainerViewController
    }()
    
    /// Create a new container window for popovers. This is automatically managed.
    public init(popoverModel: PopoverModel, scene: UIWindowScene?) {
        self.popoverModel = popoverModel
        self.scene = scene
        
        if let scene = scene {
            super.init(windowScene: scene)
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
        
        /// Loop through the popovers and see if the touch hit it.
        for popover in popoverModel.popovers {
            
            /// Check it the popover was hit.
            if popover.context.frame.contains(point) {
                
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
            
            /// Check if the touch hit an excluded view. In this case, don't dismiss it.
            if popover.attributes.dismissal.mode.contains(.tapOutside) {
                let excludedFrames = popover.attributes.dismissal.excludedFrames()
                if excludedFrames.contains(where: { $0.contains(point) }) {
                    
                    /// The touch hit an excluded view, so don't dismiss it.
                    continue
                }
            }
            
            /// If all checks did not pass, dismiss the popover if necessary.
            if popover.attributes.dismissal.mode.contains(.tapOutside) {
                Popovers.dismiss(popover)
            }
        }
        
        /// the touch didn't land in any popover, so dismiss them
//        for popover in popoverModel.popovers.reversed() {
//            if popover.attributes.dismissal.mode.contains(.tapOutside) {
//                Popovers.dismiss(popover)
//            }
//        }
        return nil
    }
}

/// from https://stackoverflow.com/a/58673530/14351818
extension UIApplication {
    var currentWindowScene: UIWindowScene? {
        connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow})
            .first?
            .windowScene
    }
}
