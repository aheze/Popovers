import ObjectiveC
import UIKit

extension UIWindow {
    
    private struct Keys {
        static var popoverModelKey = "popoverModelKey"
    }
    
    /// Retains a `PopoverModel` in this `UIWindow`.
    ///
    /// `PopoverModel`s are scoped to the window level as frame mathematics pertain to a single view hiearchy from the
    /// window-down only. Hence presenting popovers in other windows using the `popoverModel` property will return
    /// a different value depending on the context of the window.
    var objc_popoverModel: PopoverModel {
        get {
            let holder = objc_getAssociatedObject(self, &Keys.popoverModelKey) as? PopoverModelHolder
            if let holder = holder {
                return holder.model
            } else {
                let newModel = PopoverModel()
                let holder = PopoverModelHolder(model: newModel)
                
                objc_setAssociatedObject(
                    self,
                    &Keys.popoverModelKey,
                    holder,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
                )
                
                return newModel
            }
        }
    }
    
    private class PopoverModelHolder: NSObject {
        
        let model: PopoverModel
        
        init(model: PopoverModel) {
            self.model = model
        }
        
    }
    
}
