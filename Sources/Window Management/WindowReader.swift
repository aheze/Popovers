import SwiftUI
import UIKit

/// Reads the `UIWindow` that is managing the hosting of some SwiftUI content.
public struct WindowReader<Content: View>: View {
    
    public let view: (UIWindow) -> Content
    @State var window: UIWindow?
    @Environment(\.window) var environmentWindow
    
    public init(@ViewBuilder view: @escaping (UIWindow) -> Content) {
        self.view = view
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let window = window ?? environmentWindow {
                view(window)
                    .environment(\.window, window)
            }
            
            WindowHandlerRepresentable(binding: $window)
                .allowsHitTesting(false)
                .frame(width: 0, height: 0)
        }
    }
    
    private struct WindowHandlerRepresentable: UIViewRepresentable {
        
        var binding: Binding<UIWindow?>
        
        func makeUIView(context: Context) -> WindowHandler {
            WindowHandler(binding: binding)
        }
        
        func updateUIView(_ uiView: WindowHandler, context: Context) {
            
        }
        
    }
    
    private class WindowHandler: UIView {
        
        @Binding var windowFinder: UIWindow?
        
        init(binding: Binding<UIWindow?>) {
            self._windowFinder = binding
            
            super.init(frame: .zero)
            self.backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            windowFinder = window
        }
        
    }
    
}
