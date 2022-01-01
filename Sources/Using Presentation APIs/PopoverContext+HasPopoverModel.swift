extension Popover.Context: HasPopoverModel {
    
    public var popoverModel: PopoverModel {
        precondition(presentedPopoverViewController != nil, "Present the popover before trying to access its model")
        return presentedPopoverViewController!.popoverModel
    }
    
}
