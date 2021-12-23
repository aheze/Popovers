//
//  Popovers.swift
//  Popover
//
//  Created by Zheng on 12/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

public struct Popovers {
    
    /// there might be multiple scenes on iPad, so make a window for each one
    public static var windows: [UIWindowScene: PopoverContainerWindow] = [:]
    
    public static var windowBounds: CGRect {
        return getWindow().bounds
    }
    
    /// window bounds with safe area
    public static var safeWindowFrame: CGRect {
        let window = getWindow()
        let safeAreaFrame = window.safeAreaLayoutGuide.layoutFrame
        return safeAreaFrame
    }
    
    static var model: PopoverModel = {
        let model = PopoverModel()
        return model
    }()
    
    public static func getWindow() -> PopoverContainerWindow {
        if let currentScene = UIApplication.shared.currentWindowScene {
            if let window = windows[currentScene] {
                return window
            } else {
                let window = PopoverContainerWindow(
                    popoverModel: model,
                    scene: currentScene
                )
                windows[currentScene] = window
                return window
            }
        } else {
            let window = PopoverContainerWindow(
                popoverModel: model,
                scene: nil
            )
            return window
        }
    }
    
    public static func present(_ popover: Popover) {

        _ = model
        
        _ = getWindow()
        
        /// make sure the window is set up the first time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            let transaction = Transaction(animation: popover.attributes.presentation.animation)
            popover.context.transaction = transaction
            withTransaction(transaction) {
                current.append(popover)
            }
        }
    }
    
    public static func dismiss(_ popover: Popover, transaction: Transaction? = nil) {
        if let popoverIndex = index(of: popover) {
            popover.context.dismissed?()
            popover.attributes.onDismiss?()
            
            let dismissalTransaction = transaction ?? Transaction(animation: popover.attributes.dismissal.animation)
            withTransaction(dismissalTransaction) {
                _ = current.remove(at: popoverIndex)
            }
        }
    }
    
    public static func dismissAll() {
        for popover in current.reversed() {
            dismiss(popover)
        }
    }
    
    public static func replace(_ oldPopover: Popover, with newPopover: Popover) {
        _ = getWindow()
        
        if let oldPopoverIndex = index(of: oldPopover) {

            let currentContext = current[oldPopoverIndex].context
            
            let transaction = Transaction(animation: newPopover.attributes.presentation.animation)
            
            /// set this for future animations
            newPopover.context.transaction = transaction
            
            /// use same ID so that SwiftUI animates the change
            newPopover.context.id = currentContext.id
            
            withTransaction(transaction) {
                newPopover.setSize(currentContext.size)
                current[oldPopoverIndex] = newPopover
            }
        }
    }
    
    public static var current: [Popover] {
        get {
            model.popovers
        } set {
            model.popovers = newValue
        }
    }
    
    /// optional refresh
    public static func refresh(with transaction: Transaction? = nil) {
        for popover in current {
            popover.context.transaction = transaction
        }
        model.refresh()
    }
    public static func updateFrames() {
        for popover in current {
            if 
                case .relative(let popoverAnchors) = popover.attributes.position,
                popoverAnchors == [.center]
            {
                /// for some reason, relative positioning + .center does not need to be on the main queue
                popover.setSize(popover.context.size)
            } else {
                
                /// must be on main queue to get a different SwiftUI render loop
                DispatchQueue.main.async {
                    popover.setSize(popover.context.size)
                }
            }
        }
        model.refresh()
    }
    public static func popover(tagged tag: String) -> Popover? {
        return current.first(where: { $0.attributes.tag == tag })
    }
    public static func index(of popover: Popover) -> Int? {
        return current.indices.first(where: { current[$0] == popover })
    }
    
    public static var draggingEnabled: Bool {
        get {
            Popovers.model.popoversDraggable
        } set {
            Popovers.model.popoversDraggable = newValue
        }
    }
}
