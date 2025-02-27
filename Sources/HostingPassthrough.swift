#if os(iOS)
// From: https://github.com/Priva28/HostingPassthrough/blob/24ca7febe0d37386b5ba02025376c2753367c46d/Sources/HostingPassthrough/HostingPassthrough.swift
// created by christian privitelli on 10/01/2023

import SwiftUI

open class HostingParentController: UIViewController {
    public var makeBackgroundsClear = true
    
    /// If the touches land on the base view of the HostingParentController, they will be forwarded to this view if it is not nil.
    public var forwardBaseTouchesTo: UIView?
    
    /// If the touches land on the bottom of a SwiftUI scroll container (*not* the content), pass through these touches to the UIKit layer underneath.
    public var ignoreTouchesOnSwiftUIScrollView = false
    
    override public func loadView() {
        let capturer = HostingParentView()
        view = capturer
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let capturer = view as! HostingParentView
        capturer.makeBackgroundsClear = makeBackgroundsClear
        capturer.forwardBaseTouchesTo = forwardBaseTouchesTo
        capturer.ignoreTouchesOnSwiftUIScrollView = ignoreTouchesOnSwiftUIScrollView
    }
}

/// Use HostingParentView instead of UIView in places where you aren't adding a UIHostingController to a view controller. Otherwise use HostingParentController instead.
open class HostingParentView: UIView {
    private var hostingViews: [UIView] = []
    public var forwardBaseTouchesTo: UIView?
    public var makeBackgroundsClear = true
    public var ignoreTouchesOnSwiftUIScrollView = false
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitTest = super.hitTest(point, with: event) else { return nil }
        
        return checkBehind(view: hitTest, point: point, event: event)
    }
    
    // what you need to know for this logic >
    //
    // in the view hierachy a UIHostingController has a private _UIHostingView that contains all the SwiftUI content.
    // when we do a hit test and it returns a _UIHostingView, this means we have hit the background of the hosting view, and not actually a SwiftUI view.
    //
    // when a hit test lands on a SwiftUI view, the class is something like _TtCOCV7SwiftUI11DisplayList11ViewUpdater8Platform13CGDrawingView, so not the actual _UIHostingView that contains it.
    //
    // therefore we then should continue to check behind the _UIHostingView until we reach something underneath that isn't another _UIHostingView view.
    // this could either be a SwiftUI view with a weird class name like above OR a UIKit view.
    
    private func checkBehind(view: UIView, point: CGPoint, event: UIEvent?) -> UIView? {
        // if the hittest lands on a hosting view, and it has user interaction enabled, we check behind it.
        // otherwise just return the view directly (this is almost definitely a UIKit view).
        if let view = hostingViews.first(where: { $0 == view }), view.isUserInteractionEnabled {
            // in order to check behind the _UIHostingView that captures all of the touches, we can tell it to stop accepting touches, then perform another hittest in the same location to see what's underneath it.
            view.isUserInteractionEnabled = false
            guard let hitBehind = super.hitTest(point, with: event) else { return nil }
            
            // for some reason this causes a crash if we don't set it back on the main thread
            DispatchQueue.main.async {
                view.isUserInteractionEnabled = true
            }
            
            // if the view behind is another _UIHostingView, we check behind THAT, and the process continues until we land on something that isn't a _UIHostingView.
            if hostingViews.contains(hitBehind) {
                return checkBehind(view: hitBehind, point: point, event: event)
            } else {
                // yay we found something behind
                // if it is the base view, then forward it to whatever we have set here
                if let forwardBaseTouchesTo = forwardBaseTouchesTo, hitBehind == self {
                    // some special logic to check if we are forwarding to the superview.
                    // if we are, then we want to make sure not to return itself again otherwise we'd be creating an endless loop.
                    if forwardBaseTouchesTo == superview {
                        let hit = super.hitTest(point, with: event)
                        return hit == self ? nil : hit
                    } else {
                        return forwardBaseTouchesTo.hitTest(point, with: event)
                    }
                } else {
                    return view
                }
            }
        } else {
            if let forwardBaseTouchesTo = forwardBaseTouchesTo, view == self {
                if forwardBaseTouchesTo == superview {
                    let hit = super.hitTest(point, with: event)
                    return hit == self ? nil : hit
                } else {
                    return forwardBaseTouchesTo.hitTest(point, with: event)
                }
                
                // if we are hitting the back of a scroll view, it's possible you might want to pass this touch through to the uikit layer underneath. scrolling is still possible when touching items, just not the bottom of the scroll view.
            } else if String(describing: view).contains("HostingScrollView"), view.isUserInteractionEnabled, ignoreTouchesOnSwiftUIScrollView {
                view.isUserInteractionEnabled = false
                
                guard let hitBehindScrollView = super.hitTest(point, with: event) else { return nil }
                
                DispatchQueue.main.async {
                    view.isUserInteractionEnabled = true
                }
                
                return checkBehind(view: hitBehindScrollView, point: point, event: event)
            } else {
                return view
            }
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        hostingViews = subviews.filter {
            // so it isn't exactly called _UIHostingView, and it's a private class, so we just check against the description of it.
            // reliable as of iOS 16.3 when this was made
            String(describing: $0.self).contains("_UIHostingView")
        }
        
        guard makeBackgroundsClear else { return }
        
        hostingViews.forEach {
            $0.backgroundColor = .clear
        }
    }
}
#endif
