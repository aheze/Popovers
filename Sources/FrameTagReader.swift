import SwiftUI
import UIKit

/// A container view that allows other content to access tagged frames within the window's coordinate space.
public struct FrameTagReader<Content>: View where Content: View {
    
    private let content: (FrameTagProxy) -> Content
    
    public init(@ViewBuilder _ content: @escaping (FrameTagProxy) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        WindowReader { (window) in
            let proxy = FrameTagProxy(hasPopoverModel: window)
            content(proxy)
        }
    }
    
}

/// A proxy for access to tagged frames in the window's coordinate space.
public struct FrameTagProxy {
    
    private let popoverModel: PopoverModel
    
    init(hasPopoverModel: HasPopoverModel) {
        self.popoverModel = hasPopoverModel.popoverModel
    }
    
    /**
     Get the saved frame of a frame-tagged view. You must first set the frame using `.frameTag(_:)`.
     - parameter tag: The tag that you used for the frame.
     
     - Returns: The frame of a frame-tagged view, or `CGRect.zero` if no view with the tag exists.
     */
    public func frameTagged(_ tag: String) -> CGRect {
        let frameTag = FrameTag(tag: tag)
        return popoverModel.frameTags[frameTag] ?? .zero
    }
    
    /// Remove all saved frames for `.popover(selection:tag:attributes:view:)`. Call this method when you present another view where the frames don't apply.
    public func clearSavedFrames() {
        popoverModel.selectionFrameTags.removeAll()
    }
    
    func save(_ frame: CGRect, for tag: String) {
        let frameTag = FrameTag(tag: tag)
        popoverModel.frameTags[frameTag] = frame
    }
    
}
