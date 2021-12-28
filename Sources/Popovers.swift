//
//  Popovers.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
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
        return getWindow().bounds
    }
    
    /// The frame of the current window with the safe area applied.
    public static var safeWindowFrame: CGRect {
        let window = getWindow()
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
    
    /// Make sure that a window exists, so that the popover's presentation animation doesn't stutter..
    public static func prepare() {
        _ = getWindow()
    }
    
    /**
     Present a popover.
     */
    public static func present(_ popover: Popover) {
        
        /// Make sure the view model exists.
        _ = model
        
        /// Make sure a window exists.
        _ = getWindow()
        
        /// Create a transaction for the presentation animation.
        let transaction = Transaction(animation: popover.attributes.presentation.animation)
        
        /// Inject the transaction into the popover, so following frame calculations are animated smoothly.
        popover.context.transaction = transaction
        
        /// Set the popover's window scene as the current one.
        popover.context.windowScene = UIApplication.shared.currentWindowScene
        
        withTransaction(transaction) {
            
            /// Add the popover to the container view.
            current.append(popover)
        }
    }
    
    /**
     Replace a popover with another popover smoothly.
     
     This is what `.popover(selection:tag:attributes:view:)` in SwiftUI uses.
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
            
            /// Set the popover's window scene as the current one.
            newPopover.context.windowScene = UIApplication.shared.currentWindowScene
            
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
    
    /// Remove all saved frames for `.popover(selection:tag:attributes:view:)`. Call this method when you present another view where the frames don't apply.
    public static func clearSavedFrames() {
        model.selectionFrameTags.removeAll()
    }
    
    /**
     Get a currently-presented popover with a tag. Returns `nil` if no popover with the tag was found.
     - parameter tag: The tag of the popover to look for.
     - parameter windowScene: The window scene of the popover to look for. Only needed if your app supports multiple windows.
     */
    public static func popover(tagged tag: String, in windowScene: UIWindowScene? = UIApplication.shared.currentWindowScene) -> Popover? {
        return current.first(where: { $0.context.windowScene == windowScene && $0.attributes.tag == tag })
    }
    
    /// Get the index in the `current` array for a popover. Returns `nil` if the popover is not in the `current` array.
    public static func index(of popover: Popover) -> Int? {
        return current.indices.first(where: { current[$0] == popover })
    }
    
    /**
     Get the current window.
     */
    public static func getWindow() -> PopoverContainerWindow {
        if let currentScene = UIApplication.shared.currentWindowScene {
            
            /// Get the window for the current scene.
            if let window = windows[currentScene] {
                return window
            } else {
                
                /// No popover window exists yet, make one.
                let window = PopoverContainerWindow(
                    popoverModel: model,
                    windowScene: currentScene
                )
                
                windows[currentScene] = window
                return window
            }
        } else {
            
            /// No popover window exists yet and there is no scene active, make one.
            /// This is highly unlikely to be called.
            let window = PopoverContainerWindow(
                popoverModel: model,
                windowScene: nil
            )
            
            return window
        }
    }
}
