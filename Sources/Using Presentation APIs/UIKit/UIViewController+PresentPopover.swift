import UIKit

extension UIViewController {
    
    public func present(_ popoverToPresent: Popover) {
        guard let window = view.window else { return }
        popoverToPresent.present(in: window)
    }
    
}
