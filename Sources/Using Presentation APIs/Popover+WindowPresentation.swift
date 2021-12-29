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
        let model: PopoverModel
        
        if let existingPopoverViewController = presentingViewController as? PopoverContainerViewController {
            popoverViewController = existingPopoverViewController
            model = existingPopoverViewController.popoverModel
        } else {
            model = PopoverModel()
            popoverViewController = PopoverContainerViewController(popoverModel: model)
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
