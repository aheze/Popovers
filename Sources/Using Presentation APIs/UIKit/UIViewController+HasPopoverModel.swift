import UIKit

extension UIViewController: HasPopoverModel {
    
    public var popoverModel: PopoverModel {
        view.popoverModel
    }
    
}
