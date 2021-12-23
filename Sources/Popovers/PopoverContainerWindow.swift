//
//  PopoverContainerWindow.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftUI

public class PopoverContainerWindow: UIWindow {
    
    public var popoverModel: PopoverModel
    public var scene: UIWindowScene?
    
    public init(popoverModel: PopoverModel, scene: UIWindowScene?) {
        self.popoverModel = popoverModel
        self.scene = scene
        
        if let scene = scene {
            super.init(windowScene: scene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        
        self.rootViewController = popoverContainerViewController
        self.windowLevel = .alert
        self.backgroundColor = .clear
        self.makeKeyAndVisible()
    }
    
    public lazy var popoverContainerViewController: PopoverContainerViewController = {
        let popoverContainerViewController = PopoverContainerViewController(popoverModel: popoverModel)
        return popoverContainerViewController
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        /// make sure the hit test was actually a touch - not a cursor hover or something else
        guard event.map({ $0.type == .touches }) ?? true else { return nil }
        
        for popover in popoverModel.popovers {
            
            /// check if hit a popover
            if popover.context.frame.contains(point) {
                return super.hitTest(point, with: event)
            }
            
            popover.attributes.onTapOutside?()
            
            /// block the touch event from falling through
            if popover.attributes.blocksBackgroundTouches {
                return super.hitTest(point, with: event)
            }
            
            /// check if hit a excluded view - don't dismiss
            if popover.attributes.dismissal.mode.contains(.tapOutside) {
                let excludedFrames = popover.attributes.dismissal.excludedFrames()
                if excludedFrames.contains(where: { $0.contains(point) }) {
                    return nil
                }
            }
        }
        
        /// the touch didn't land in any popover, so dismiss them
        for popover in popoverModel.popovers.reversed() {
            if popover.attributes.dismissal.mode.contains(.tapOutside) {
                Popovers.dismiss(popover)
            }
        }
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
