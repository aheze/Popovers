//
//  Popovers.swift
//  Popover
//
//  Created by Zheng on 12/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

/**
 The main access point for the Popovers library.
 */
public struct Popovers {
    
    /**
     The windows to hold the popovers.
     
     There might be multiple scenes on iPad, so make a window for each one.
     */
    public static var windows: [UIWindowScene: PopoverContainerWindow] = [:]
    
    /// The bounds of the current window.
    public static var windowBounds: CGRect {
        return getWindow().0.bounds
    }
    
    /// The frame of the current window with the safe area applied.
    public static var safeWindowFrame: CGRect {
        let window = getWindow().0
        let safeAreaFrame = window.safeAreaLayoutGuide.layoutFrame
        return safeAreaFrame
    }
    
    /// The view model for the popovers.
    public static var model: PopoverModel = {
        let model = PopoverModel()
        return model
    }()
    
    /// The popovers that are currently presented.
    public static var current: [Popover] {
        get {
            model.popovers
        } set {
            model.popovers = newValue
        }
    }
    
    /**
     Enable or disable popover dragging globally.
     
     This is useful if you have nested sliders or other gestures that interfere with the popover's rubber banding. Set this to `true` to enable dragging, `false` to disable dragging.
     */
    public static var draggingEnabled: Bool {
        get {
            Popovers.model.popoversDraggable
        } set {
            Popovers.model.popoversDraggable = newValue
        }
    }
    
    /**
     Get the current window.
     - Returns: A tuple `(window, reused)`.
     
     - `window` - the current window.
     - `reused` - indicates if an existing window was reused.
     */
    public static func getWindow() -> (window: PopoverContainerWindow, reused: Bool) {
        if let currentScene = UIApplication.shared.currentWindowScene {
            
            /// Get the window for the current scene.
            if let window = windows[currentScene] {
                return (window, true)
            } else {
                
                /// No popover window exists yet, make one.
                let window = PopoverContainerWindow(
                    popoverModel: model,
                    scene: currentScene
                )
                
                windows[currentScene] = window
                return (window, false)
            }
        } else {
            
            /// No popover window exists yet and there is no scene active, make one.
            /// This is highly unlikely to be called.
            let window = PopoverContainerWindow(
                popoverModel: model,
                scene: nil
            )
            
            return (window, false)
        }
    }
    
    /**
     Present a popover.
     */
    public static func present(_ popover: Popover) {

        /// Make sure the view model exists.
        _ = model
        
        /// Make sure a window exists.
        let (_, reused) = getWindow()
        
        /// Configure and present the popover.
        func presentPopover() {
            /// Create a transaction for the presentation animation.
            let transaction = Transaction(animation: popover.attributes.presentation.animation)
            
            /// Inject the transaction into the popover, so following frame calculations are animated smoothly.
            popover.context.transaction = transaction
            
            withTransaction(transaction) {
                
                /// Add the popover to the container view.
                current.append(popover)
            }
        }
        
        /// Directly present the popover if an existing window was reused.
        if reused {
            presentPopover()
        } else {
            
            /// Otherwise, make sure the window is set up the first time and ready for SwiftUI.
            /// Without a delay, SwiftUI won't apply the animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                presentPopover()
            }
        }
    }
    
    /**
     Dismiss a popover.
     
     Provide `transaction` to override the default dismissal transition.
     */
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
    
    /// Dismiss all popovers.
    public static func dismissAll() {
        for popover in current.reversed() {
            dismiss(popover)
        }
    }
    
    /**
     Replace a popover with another popover smoothly.
     
     This is what `.popover(selection:tag:attributes:view)` in SwiftUI uses.
     */
    public static func replace(_ oldPopover: Popover, with newPopover: Popover) {
        _ = getWindow()
        
        /// Get the index of the previous popover.
        if let oldPopoverIndex = index(of: oldPopover) {

            /// Get the old popover's context.
            let oldContext = current[oldPopoverIndex].context
            
            /// Create a new transaction for the replacing animation.
            let transaction = Transaction(animation: newPopover.attributes.presentation.animation)
            
            /// Inject the transaction into the new popover, so following frame calculations are animated smoothly.
            newPopover.context.transaction = transaction
            
            /// Use same ID so that SwiftUI animates the change.
            newPopover.context.id = oldContext.id
            
            withTransaction(transaction) {
                
                /// Temporarily use the same size for a smooth animation.
                newPopover.setSize(oldContext.size)
                
                /// Replace the old popover with the new popover.
                current[oldPopoverIndex] = newPopover
            }
        }
    }
    
    /**
     Refresh the popovers with a new transaction.
     
     This is called when a popover's frame is being calculated.
     */
    public static func refresh(with transaction: Transaction?) {
        
        /// Set each popovers's transaction to the new transaction to keep the smooth animation.
        for popover in current {
            popover.context.transaction = transaction
        }
        
        /// Update all popovers.
        model.refresh()
    }
    
    /**
     Update all popover frames.
     
     This is called when the device rotates or has a bounds change.
     */
    public static func updateFrames() {
        for popover in current {
            if 
                case .relative(let popoverAnchors) = popover.attributes.position,
                popoverAnchors == [.center]
            {
                /// For some reason, relative positioning + `.center` doesn't need to be on the main queue to have a size change.
                popover.setSize(popover.context.size)
            } else {
                
                /// Must be on the main queue to get a different SwiftUI render loop
                DispatchQueue.main.async {
                    popover.setSize(popover.context.size)
                }
            }
        }
        
        /// Update all popovers.
        model.refresh()
    }
    
    /// Get a currently-presented popover with a tag. Returns `nil` if no popover with the tag was found.
    public static func popover(tagged tag: String) -> Popover? {
        return current.first(where: { $0.attributes.tag == tag })
    }
    
    /// Get the index in the `current` array for a popover. Returns `nil` if the popover is not in the `current` array.
    public static func index(of popover: Popover) -> Int? {
        return current.indices.first(where: { current[$0] == popover })
    }
}
