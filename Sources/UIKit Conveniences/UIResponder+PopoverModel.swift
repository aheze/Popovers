import CoreGraphics
import UIKit

extension UIResponder {
    
    /// The `PopoverModel` in the current responder chain.
    ///
    /// Each responder chain hosts a single `PopoverModel` at the window level. Each scene containing
    /// a seperate window will contain its own `PopoverModel`, scoping the layout code to each window.
    ///
    /// - Important: Attempting to request the `PopoverModel` for a responder not present in the chain is programmer error.
    var popoverModel: PopoverModel {
        /// If we're a view, continue to walk up the responder chain until we hit the root view.
        if let view = self as? UIView, let superview = view.superview {
            return superview.popoverModel
        }
        
        /// If we're a window, we define the scoping for the model - access it.
        if let window = self as? UIWindow {
            return WindowPopoverModels.shared.popoverModel(for: window)
        }
        
        /// If we're a view controller, begin walking the responder chain up to the root view.
        if let viewController = self as? UIViewController {
            return viewController.view.popoverModel
        }

        fatalError("No `PopoverModel` present in responder chain - has the source view been installed into a window?")
    }
    
}


// MARK: - Convenience Popover Functions

extension UIResponder {
    
    /**
     Replace a popover with another popover smoothly.
     
     This is what `.popover(selection:tag:attributes:view:)` in SwiftUI uses.
     */
    public func replace(_ oldPopover: Popover, with newPopover: Popover) {
        popoverModel.replace(oldPopover, with: newPopover)
    }
    
    /**
     Get a currently-presented popover with a tag. Returns `nil` if no popover with the tag was found.
     - parameter tag: The tag of the popover to look for.
     */
    public func popover(tagged tag: String) -> Popover? {
        return popoverModel.popover(tagged: tag)
    }
    
    /**
     Get the saved frame of a frame-tagged view. You must first set the frame using `.frameTag(_:)`.
     - parameter tag: The tag that you used for the frame.
     
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    public func frameTagged(_ tag: String) -> CGRect {
        return popoverModel.frameTagged(tag)
    }
    
}
