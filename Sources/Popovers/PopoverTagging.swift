import SwiftUI

/// store a view's frame for later use
struct FrameTagModifier: ViewModifier {
    let tag: String
    
    func body(content: Content) -> some View {
        content
            .frameReader { rect in
                Popovers.model.frameTags[tag] = rect
            }
    }
}

/// tag a view and store its frame
public extension View {
    func frameTag(_ tag: String) -> some View {
        return self.modifier(FrameTagModifier(tag: tag))
    }
}

/// get the frame of a tagged view
public extension Popovers {
    static func frameTagged(_ tag: String) -> CGRect {
        let frame = model.frameTags[tag]
        return frame ?? .zero
    }
}
