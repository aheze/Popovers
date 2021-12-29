import SwiftUI
import UIKit

struct WindowReader<Content>: View where Content: View {
    
    var content: (UIWindow) -> Content
    @State var window: UIWindow?
    
    var body: some View {
        ZStack {
            if let window = window {
                content(window)
            }
            
            WindowHandlerRepresentable(binding: $window)
                .allowsHitTesting(false)
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
        
        private let binding: Binding<UIWindow?>
        
        init(binding: Binding<UIWindow?>) {
            self.binding = binding
            
            super.init(frame: .zero)
            self.backgroundColor = .clear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            binding.wrappedValue = window
        }
        
    }
    
}
