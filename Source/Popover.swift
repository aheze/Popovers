//
//  Popover.swift
//  Popover
//
//  Created by Zheng on 12/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI
import Combine

struct Popover: Identifiable {
    
    /// everything about the popover is stored here
    var context: Context
    
    /// the content view
    var view: AnyView
    
    /// background
    var background: AnyView
    
    /// normal init
    init<Content: View>(
        attributes: Attributes = .init(),
        @ViewBuilder view: @escaping () -> Content
    ) {
        let context = Context()
        context.attributes = attributes
        self.context = context
        self.view = AnyView(view().environmentObject(context))
        self.background = AnyView(Color.clear)
    }
    
    /// for a background view
    init<MainContent: View, BackgroundContent: View>(
        attributes: Attributes = .init(),
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) {
        let context = Context()
        context.attributes = attributes
        self.context = context
        self.view = AnyView(view().environmentObject(context))
        self.background = AnyView(background().environmentObject(context))
    }
    
    struct Attributes {
        var sourceFrame: (() -> CGRect) = { .zero }
        var sourceFrameIgnoresSafeArea = true
        var sourceFrameInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        var position = Position.absolute(originAnchor: .bottom, popoverAnchor: .top)
        
        /// popover will never go past the screen edges if this is not nil
        var screenEdgePadding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        var presentation = Presentation()
        var dismissal = Dismissal()
        
        /// how the popover will "rubber-band" when dragged
        var rubberBandingMode: RubberBandingMode = [.xAxis, .yAxis]
        
        /// prevent anything else in the background to be pressed
        var blocksBackgroundTouches = false
        
        var onTapOutside: (() -> Void)?
        var onDismiss: (() -> Void)?
        var onContextChange: ((Context) -> Void)?
        
        /// for identifying the popover later. Optional.
        var tag: String?
        
        struct RubberBandingMode: OptionSet {
            let rawValue: Int
            public static let xAxis = RubberBandingMode(rawValue: 1 << 0) // 1
            public static let yAxis = RubberBandingMode(rawValue: 1 << 1) // 2
            public static let none = RubberBandingMode([])
        }
        
        struct Presentation {
            var animation: Animation? = .default
            var transition: AnyTransition? = .opacity
        }
        
        struct Dismissal {
            var animation: Animation? = .default
            var transition: AnyTransition? = .opacity
            
            /// to move the popover off the screen or not
            var dragMovesPopoverOffScreen = true
            
            var mode = Mode.tapOutside
            
            /// only applies when `mode` is .whenTappedOutside
            var excludedFrames: (() -> [CGRect]) = { [] }
            
            /// in terms of a percent of the screen height
            /// only applies when `mode` is .dragDown or .dragUp   
            /// 0.25 * screen height is where the popover will be dismissed
            var dragDismissalProximity = CGFloat(0.25)
            
            struct Mode: OptionSet {
                let rawValue: Int
                public static let tapOutside = Mode(rawValue: 1 << 0) // 1
                public static let dragDown = Mode(rawValue: 1 << 1) // 2
                public static let dragUp = Mode(rawValue: 1 << 2) // 4
                public static let none = Mode([])
            }
        }
        
        enum Position {
            case absolute(originAnchor: Anchor, popoverAnchor: Anchor)
            case relative(popoverAnchors: [Anchor])
            
            struct Absolute {
                
                /// the side of the origin view which the popover is attached to
                var originAnchor = Anchor.bottomLeft
                
                /// the side of the popover that gets attached to the origin
                var popoverAnchor = Anchor.topLeft
            }
            
            struct Relative {
                var popoverAnchors: [Anchor]
                
                init(popoverAnchor: Anchor = .bottomLeft) {
                    self.popoverAnchors = [popoverAnchor]
                }
                
                init(popoverAnchors: [Anchor] = [.bottomLeft]) {
                    self.popoverAnchors = popoverAnchors
                }
            }
            
            enum Anchor {
                case topLeft
                case top
                case topRight
                case right
                case bottomRight
                case bottom
                case bottomLeft
                case left
                case center
            }
        }
    }
    
    class Context: Identifiable, ObservableObject {
        
        /// id of the popover
        var id = UUID()
        
        var attributes = Attributes()
        
        /// calculated from SwiftUI. If this is `nil`, the popover is not yet ready.
        @Published var size: CGSize?
        
        /// frame of the popover, without gestures applied
        @Published var staticFrame = CGRect.zero
        
        /// visual frame of the popover shown to the user
        @Published var frame = CGRect.zero
        
        /// for relative positioning
        @Published var selectedAnchor: Popover.Attributes.Position.Anchor?
        
        /// for animations
        var transaction: Transaction?
        
        /// for SwiftUI - set `$present` to false in the view modifier
        internal var dismissed: (() -> Void)?
        
        /// notify when context changed 
        var changeSink: AnyCancellable?
        
        init() {
            changeSink = objectWillChange.sink { [weak self] in
                guard let self = self else { return }
                self.attributes.onContextChange?(self)
            }
        }
    }
}

extension Popover {
    
    var id: UUID {
        get {
            context.id
        } set {
            context.id = newValue
        }
    }
    
    var attributes: Attributes {
        get {
            context.attributes
        } set {
            context.attributes = newValue
        }
    }
    
    func setSize(_ size: CGSize?) {
        context.size = size
        let frame = getFrame(from: size)
        context.staticFrame = frame
        context.frame = frame
    }
    
    func getFrame(from size: CGSize?) -> CGRect {
        switch attributes.position {
        case .absolute(let originAnchor, let popoverAnchor):
            var popoverFrame = attributes.position.absoluteFrame(
                originAnchor: originAnchor,
                popoverAnchor: popoverAnchor,
                originFrame: attributes.sourceFrame().inset(by: attributes.sourceFrameInset),
                popoverSize: size ?? .zero
            )
            
            let screenEdgePadding = attributes.screenEdgePadding
            let maxX = Popovers.safeWindowFrame.maxX - screenEdgePadding.right
            let maxY = Popovers.safeWindowFrame.maxY - screenEdgePadding.bottom
            
            /// popover overflows on left/top side
            if popoverFrame.origin.x < screenEdgePadding.left {
                popoverFrame.origin.x = screenEdgePadding.left
            }
            if popoverFrame.origin.y < screenEdgePadding.top {
                popoverFrame.origin.y = screenEdgePadding.top
            }
            
            /// popover overflows on the right/bottom side
            if popoverFrame.maxX > maxX {
                let difference = popoverFrame.maxX - maxX 
                popoverFrame.origin.x -= difference
            }
            if popoverFrame.maxY > maxY {
                let difference = popoverFrame.maxY - maxY 
                popoverFrame.origin.y -= difference
            }
            
            return popoverFrame
        case .relative(let popoverAnchors):
            
            /// set the selected anchor to the first one
            if context.selectedAnchor == nil {
                context.selectedAnchor = popoverAnchors.first
            }
            
            let popoverFrame = attributes.position.relativeFrame(
                containerFrame: attributes.sourceFrame().inset(by: attributes.sourceFrameInset),
                popoverSize: size ?? .zero,
                selectedAnchor: context.selectedAnchor ?? popoverAnchors.first ?? .bottom
            )
            return popoverFrame
        }
    }
    
    func positionChanged(to point: CGPoint) {
        if 
            attributes.dismissal.mode.contains(.dragDown),
            point.y >= Popovers.windowBounds.height - Popovers.windowBounds.height * self.attributes.dismissal.dragDismissalProximity 
        {
            if attributes.dismissal.dragMovesPopoverOffScreen {
                var newFrame = context.staticFrame
                newFrame.origin.y = Popovers.windowBounds.height
                context.staticFrame = newFrame
                context.frame = newFrame
            }
            Popovers.dismiss(self)
            return
        }
        if 
            attributes.dismissal.mode.contains(.dragUp),
            point.y <= Popovers.windowBounds.height * self.attributes.dismissal.dragDismissalProximity 
        {
            if attributes.dismissal.dragMovesPopoverOffScreen {
                var newFrame = context.staticFrame
                newFrame.origin.y = -newFrame.height
                context.staticFrame = newFrame
                context.frame = newFrame
            }
            Popovers.dismiss(self)
            return
        } 
        
        if case .relative(let popoverAnchors) = attributes.position {
            let frame = attributes.sourceFrame().inset(by: attributes.sourceFrameInset)
            let size = context.size ?? .zero
            
            let closestAnchor = attributes.position.relativeClosestAnchor(
                popoverAnchors: popoverAnchors,
                containerFrame: frame,
                popoverSize: size,
                targetPoint: point
            )
            let popoverFrame = attributes.position.relativeFrame(
                containerFrame: frame,
                popoverSize: size,
                selectedAnchor: closestAnchor
            )
            
            context.selectedAnchor = closestAnchor
            context.staticFrame = popoverFrame
            context.frame = popoverFrame
        }
    }
}

extension Popover: Equatable {
    
    /// conform to equatable
    static func == (lhs: Popover, rhs: Popover) -> Bool {
        return lhs.id == rhs.id
    }
}
