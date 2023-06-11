//
//  Popover.swift
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
        guard let topmostViewController = window.rootViewController else {
            print("[Popovers] - No view controller was found.  Please file a bug report (https://github.com/aheze/Popovers/issues)")
            return
        }

        /// Add the popover to the container view.
        let addPopover = {
            /// Get the popover model that's tied to the window.
            let model = window.popoverModel
            
            withTransaction(transaction) {
                model.add(self)
            }
        }
        
        /// If there is an existing popover container view controller, use it.
        if let existingPopoverViewController = topmostViewController.children.first(where: { $0 is PopoverContainerViewController }) as? PopoverContainerViewController {
            context.presentedPopoverViewController = existingPopoverViewController
            addPopover()
        } else {
            let newPopoverViewController = PopoverContainerViewController()
            context.presentedPopoverViewController = newPopoverViewController
            topmostViewController.add(
                childViewController: newPopoverViewController,
                in: topmostViewController.view
            )
            
            /// Add a slight delay to ensure the view controller has ben added.
            DispatchQueue.main.async {
                addPopover()
            }
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
                presentingViewController.remove()
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

    /// Get the frontmost view controller.
    var topmostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topmostViewController
        } else {
            return self
        }
    }
}
