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

        /// Locate the topmost presented `UIViewController` in this window. We'll be presenting on top of this one.
        let presentingViewController = window.rootViewController?.topmostViewController

        /// There may already be a view controller presenting another popover - if so, let's use that.
        let popoverViewController: PopoverContainerViewController

        /// Get the popover model that's tied to the window.
        let model = window.popoverModel

        if let existingPopoverViewController = presentingViewController as? PopoverContainerViewController {
            popoverViewController = existingPopoverViewController
        } else {
            popoverViewController = PopoverContainerViewController()
        }

        context.presentedPopoverViewController = popoverViewController

        /**
         Add the popover to the container view.
         */
        let displayPopover: () -> Void = {
            withTransaction(transaction) {
                model.add(self)
            }
        }

        if presentingViewController === popoverViewController {
            displayPopover()
        } else {
            
            /**
             If we've prepared a new controller to present, then do so.
             This isn't animated as we perform the popover animation inside the container view instead -
             the view controller hosts the container that animates.
             */
            presentingViewController?.present(popoverViewController, animated: false, completion: displayPopover)
        }
    }

    /**
     Dismiss a popover.

     - parameter transaction: An optional transaction that can be applied for the dismissal animation.
     */
    func dismiss(transaction: Transaction? = nil) {
        guard let presentingViewController = context.presentedPopoverViewController else { return }

        /// Let the internal SwiftUI modifiers know that the popover was automatically dismissed.
        context.onDismiss?()

        /// Let the client know that the popover was automatically dismissed.
        attributes.onDismiss?()

        let model = presentingViewController.popoverModel
        let dismissalTransaction = transaction ?? Transaction(animation: attributes.dismissal.animation)

        /// Clean up the container view controller if no more popovers are visible.
        context.onDisappear = {
            if model.popovers.isEmpty {
                presentingViewController.dismiss(animated: false)
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
        guard let popoverContainerViewController = context.presentedPopoverViewController else { return }

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
            newPopover.context.presentedPopoverViewController = oldContext.presentedPopoverViewController

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
}

extension UIViewController {
    /// Present a `Popover` using this `UIViewController` as its presentation context.
    public func present(_ popoverToPresent: Popover) {
        guard let window = view.window else { return }
        popoverToPresent.present(in: window)
    }

    /// Get the frontmost view controller.
    var topmostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topmostViewController
        } else {
            return self
        }
    }
}
