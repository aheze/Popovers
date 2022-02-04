//
//  PopoverWindows.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 1/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Popovers supports multiple windows (iOS) by associating each `PopoverModel` with a window.
 */

/// A map of `PopoverModel`s scoped to each window.
class WindowPopoverModels {
    /// The singleton `WindowPopoverMap` instance.
    static let shared = WindowPopoverModels()

    /**
     Aggregates the collection of models applicable to each `UIWindow` in the application.

     `UIWindow` references are weakly retained to avoid us leaking application scenes that have been disposed of by iOS,
     e.g. when dismissed from the multitasking UI or explicitly closed by the app.
     */
    private var windowModels = [Weak<UIWindow>: PopoverModel]()

    private init() {
        /// Enforcing singleton by marking `init` as private.
    }

    /**
     Retrieves the `PopoverModel` associated with the given `UIWindow`.

     When a `PopoverModel` already exists for the given `UIWindow`, the same reference will be returned by this function.
     Otherwise, a new model is created and associated with the window.

     - parameter window: The `UIWindow` whose `PopoverModel` is being requested, e.g. to present a popover.
     - Returns: The `PopoverModel` used to model the visible popovers for the given window.
     */
    func popoverModel(for window: UIWindow) -> PopoverModel {
        /**
         Continually remove entries that refer to `UIWindow`s that are no longer about.
         The view hierarchies have already been dismantled - this is just for our own book keeping.
         */
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

    /// Get an existing popover model for this window if it exists.
    private func existingPopoverModel(for window: UIWindow) -> PopoverModel? {
        return windowModels.first(where: { holder, _ in holder.pointee === window })?.value
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

extension UIResponder {
    /**
     The `PopoverModel` in the current responder chain.

     Each responder chain hosts a single `PopoverModel` at the window level.
     Each scene containing a separate window will contain its own `PopoverModel`, scoping the layout code to each window.

     - Important: Attempting to request the `PopoverModel` for a responder not present in the chain is programmer error.
     */
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

        fatalError("[Popovers] - No `PopoverModel` present in responder chain (\(self)) - has the source view been installed into a window?")
    }
}

public extension UIResponder {
    /**
     Get a currently-presented popover with a tag. Returns `nil` if no popover with the tag was found.
     - parameter tag: The tag of the popover to look for.
     */
    func popover(tagged tag: AnyHashable) -> Popover? {
        return popoverModel.popover(tagged: tag)
    }
}

/// For passing the hosting window into the environment.
extension EnvironmentValues {
    /// Designates the `UIWindow` hosting the views within the current environment.
    var window: UIWindow? {
        get {
            self[WindowEnvironmentKey.self]
        }
        set {
            self[WindowEnvironmentKey.self] = newValue
        }
    }

    private struct WindowEnvironmentKey: EnvironmentKey {
        typealias Value = UIWindow?

        static var defaultValue: UIWindow? = nil
    }
}
