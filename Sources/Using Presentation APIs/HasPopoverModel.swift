import CoreGraphics

public protocol HasPopoverModel {
    
    var popoverModel: PopoverModel { get }
    
}


// MARK: - Convenience Popover Functions

extension HasPopoverModel {
    
    public func replace(_ oldPopover: Popover, with newPopover: Popover) {
        oldPopover.replace(with: newPopover)
    }
    
    public func popover(tagged tag: String) -> Popover? {
        return popoverModel.popover(tagged: tag)
    }
    
    var frameTags: [FrameTag: CGRect] {
        get {
            popoverModel.frameTags
        }
        set {
            popoverModel.frameTags = newValue
        }
    }
    
    /**
     Get the saved frame of a frame-tagged view. You must first set the frame using `.frameTag(_:)`.
     - parameter tag: The tag that you used for the frame.
     
     - Returns: The frame of a frame-tagged view, or `nil` if no view with the tag exists.
     */
    public func frameTagged(_ tag: String) -> CGRect {
        let frameTag = FrameTag(tag: tag)
        let frame = frameTags[frameTag]
        return frame ?? .zero
    }
    
}
