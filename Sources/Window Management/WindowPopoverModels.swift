import UIKit

/// A map of `PopoverModel`s scoped to
class WindowPopoverModels {
    
    /// The singleton `WindowPopoverMap` instance.
    static let shared = WindowPopoverModels()
    
    /// Aggregates the collection of models applicable to each `UIWindow` in the application.
    ///
    /// `UIWindow` references are weakly retained to avoid us leaking application scenes that have been disposed of
    /// by iOS, e.g. when dismissed from the multitasking UI or explicitly closed by the app.
    private var windowModels = [Weak<UIWindow>: PopoverModel]()
    
    private init() {
        /// Enforcing singleton by marking `init` as private.
    }
    
    /// Retrieves the `PopoverModel` associated with the given `UIWindow`.
    ///
    /// Where a `PopoverModel` already exists for the given `UIWindow`, the same reference will be returned by this
    /// function. Otherwise, a new model is created and associated with the window.
    ///
    /// - Parameter window: The `UIWindow` whose `PopoverModel` is being requested, e.g. to present a popover.
    /// - Returns: The `PopoverModel` used to model the visible popovers for the given window.
    func popoverModel(for window: UIWindow) -> PopoverModel {
        /// Continually remove entries that refer to `UIWindow`s that are no longer about. The view hiearchies have
        /// already been dismantled - this is just for our own book keeping.
        pruneDeallocatedWindowModels()
        
        if let existingModel = existingPopoverModel(for: window) {
            return existingModel
        } else {
            return prepareAndRetainModel(for: window)
        }
    }
    
    private func pruneDeallocatedWindowModels() {
        let keysToRemove = windowModels.keys.filter(\.isPointeeDeallocated)
        for key in keysToRemove {
            windowModels[key] = nil
        }
    }
    
    private func existingPopoverModel(for window: UIWindow) -> PopoverModel? {
        return windowModels.first(where: { (holder, _) in holder.pointee === window })?.value
    }

    private func prepareAndRetainModel(for window: UIWindow) -> PopoverModel {
        let newModel = PopoverModel()
        let weakWindowReference = Weak(pointee: window)
        windowModels[weakWindowReference] = newModel
        
        return newModel
    }
    
    /// Container type to enable storage of an object type without incrementing its retain count.
    private class Weak<T>: NSObject where T: AnyObject {
        
        private(set) weak var pointee: T?
        
        var isPointeeDeallocated: Bool {
            pointee == nil
        }
        
        init(pointee: T) {
            self.pointee = pointee
        }
        
    }
    
}
