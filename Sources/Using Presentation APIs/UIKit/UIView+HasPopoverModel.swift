import UIKit

extension UIView: HasPopoverModel {
    
    public var popoverModel: PopoverModel {
        if let window = self as? UIWindow {
            return window.objc_popoverModel
        } else if let superview = superview {
            return superview.popoverModel
        } else {
            fatalError("Popover model not associated with window! Ensure this `UIView` is installed into a view hiearchy before attempting to present popovers.")
        }
    }
    
}
