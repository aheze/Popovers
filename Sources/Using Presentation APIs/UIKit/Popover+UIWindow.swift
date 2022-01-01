import SwiftUI
import UIKit

extension Popover {
    
    func present(in window: UIWindow) {
        /// Create a transaction for the presentation animation.
        let transaction = Transaction(animation: attributes.presentation.animation)
        
        /// Inject the transaction into the popover, so following frame calculations are animated smoothly.
        context.transaction = transaction
        
        /// Locate the topmost presented `UIViewController` in this window. We'll be presenting on top of this one.
        let presentingViewController = window.rootViewController?.topmostViewController
        
        /// There may already be a view controller presenting another popover - if so, lets use that.
        let popoverViewController: PopoverContainerViewController
        let model = window.popoverModel
        
        if let existingPopoverViewController = presentingViewController as? PopoverContainerViewController {
            popoverViewController = existingPopoverViewController
        } else {
            popoverViewController = PopoverContainerViewController()
        }
            
        context.presentedPopoverViewController = popoverViewController
        
        /// If we've prepared a new controller to present, then do so.
        /// This isn't animated as we perform the popover animation inside the container view instead - the view
        /// controller hosts the container that animates.
        let displayPopover: () -> Void = {
            withTransaction(transaction) {
                /// Add the popover to the container view.
                model.popovers.append(self)
            }
        }
        
        if presentingViewController === popoverViewController {
            displayPopover()
        } else {        
            presentingViewController?.present(popoverViewController, animated: false, completion: displayPopover)
        }
    }
    
    public func dismiss(transaction: Transaction? = nil) {
        guard let presentingViewController = context.presentedPopoverViewController else { return }
        
        context.dismissed?()
        attributes.onDismiss?()
        
        let model = presentingViewController.popoverModel
        let dismissalTransaction = transaction ?? Transaction(animation: attributes.dismissal.animation)
        
        withTransaction(dismissalTransaction) {
            model.remove(self)
            
            if model.popovers.isEmpty {
                presentingViewController.dismiss(animated: true)
            }
        }
    }
    
    public func replace(with newPopover: Popover) {
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

private extension UIViewController {
    
    var topmostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topmostViewController
        } else {
            return self
        }
    }
    
}
