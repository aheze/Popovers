import SwiftUI
import UIKit

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
