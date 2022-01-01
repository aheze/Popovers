import SwiftUI
import UIKit

public struct FrameTagReader<Content>: View where Content: View {
    
    private let content: (FrameTagProxy) -> Content
    
    public init(@ViewBuilder _ content: @escaping (FrameTagProxy) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        WindowReader { (window) in
            let proxy = FrameTagProxy(window: window)
            content(proxy)
        }
    }
    
}

public struct FrameTagProxy {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    public func frameTagged(_ tag: String) -> CGRect {
        window.frameTagged(tag)
    }
    
}
