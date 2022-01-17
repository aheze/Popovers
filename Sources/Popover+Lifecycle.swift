//
//  Popover+Lifecycle.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 1/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Present a popover.
 */
public extension Popover {
    /**
     Present a popover in a window. It may be easier to use the `UIViewController.present(_:)` convenience method instead.
     */
    internal func present(in window: UIWindow) {
        /// Create a transaction for the presentation animation.
        let transaction = Transaction(animation: attributes.presentation.animation)

        /// Inject the transaction into the popover, so following frame calculations are animated smoothly.
        context.transaction = transaction
        
        /// Get the popover model that's tied to the window.
        let model = window.popoverModel
        
        /**
         Add the popover to the container view.
         */
        let displayPopover = {
            withTransaction(transaction) {
                model.add(self)
            }
        }
        
        /// Find the existing container view for popovers in this window. If it does not exist, we need to insert one.
        let container: PopoverGestureContainer
        if let existingContainer = window.popoverContainerView {
            container = existingContainer
            
            /// The container is already laid out in the window, so we can go ahead and show the popover.
            displayPopover()
        } else {
            container = PopoverGestureContainer(frame: window.bounds)
            
            /**
             Wait until the container is present in the view hierarchy before showing the popover,
             otherwise all the layout math will be working with wonky frames.
             */
            container.onMovedToWindow = displayPopover
            
            window.addSubview(container)
        }
        
        /// Hang on to the container for future dismiss/replace actions.
        context.presentedPopoverContainer = container
    }

    /**
     Dismiss a popover.

     - parameter transaction: An optional transaction that can be applied for the dismissal animation.
     */
    func dismiss(transaction: Transaction? = nil) {
        guard let presentingViewController = context.presentedPopoverContainer else { return }

        /// Let the internal SwiftUI modifiers know that the popover was automatically dismissed.
        context.onDismiss?()

        /// Let the client know that the popover was automatically dismissed.
        attributes.onDismiss?()

        let model = presentingViewController.popoverModel
        let dismissalTransaction = transaction ?? Transaction(animation: attributes.dismissal.animation)

        /// Clean up the container view controller if no more popovers are visible.
        context.onDisappear = {
            if model.popovers.isEmpty {
                context.presentedPopoverContainer?.removeFromSuperview()
                context.presentedPopoverContainer = nil
            }
        }

        /// Remove this popover from the view model, dismissing it.
        withTransaction(dismissalTransaction) {
            model.remove(self)
        }
    }

    /**
     Replace a popover with another popover smoothly.
     */
    func replace(with newPopover: Popover) {
        guard let popoverContainerViewController = context.presentedPopoverContainer else { return }

        let model = popoverContainerViewController.popoverModel

        /// Get the index of the previous popover.
        if let oldPopoverIndex = model.index(of: self) {
            /// Get the old popover's context.
            let oldContext = model.popovers[oldPopoverIndex].context

            /// Create a new transaction for the replacing animation.
            let transaction = Transaction(animation: newPopover.attributes.presentation.animation)

            /// Inject the transaction into the new popover, so following frame calculations are animated smoothly.
            newPopover.context.transaction = transaction

            /// Use the same `UIViewController` presenting the previous popover, so we animate the popover in the same container.
            newPopover.context.presentedPopoverContainer = oldContext.presentedPopoverContainer

            /// Use same ID so that SwiftUI animates the change.
            newPopover.context.id = oldContext.id

            withTransaction(transaction) {
                /// Temporarily use the same size for a smooth animation.
                newPopover.setSize(oldContext.size)

                /// Replace the old popover with the new popover.
                model.popovers[oldPopoverIndex] = newPopover
            }
        }
    }
}

extension UIResponder {
    /// Replace a popover with another popover. Convenience method for `Popover.replace(with:)`.
    public func replace(_ oldPopover: Popover, with newPopover: Popover) {
        oldPopover.replace(with: newPopover)
    }
    
    /// Dismiss a popover. Convenience method for `Popover.dismiss(transaction:)`.
    public func dismiss(_ popover: Popover) {
        popover.dismiss()
    }
}

extension UIViewController {
    /// Present a `Popover` using this `UIViewController` as its presentation context.
    public func present(_ popover: Popover) {
        guard let window = view.window else { return }
        popover.present(in: window)
    }
}

extension UIView {
    
    var popoverContainerView: PopoverGestureContainer? {
        if let container = self as? PopoverGestureContainer {
            return container
        } else {
            for subview in subviews {
                if let container = subview.popoverContainerView {
                    return container
                }
            }
            
            return nil
        }
    }
    
}
