//
//  Popover.swift
//  Popover
//
//  Created by Zheng on 12/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI
import Combine

public struct Popover: Identifiable {
    
    /// everything about the popover is stored here
    public var context: Context
    
    /// the content view
    public var view: AnyView
    
    /// background
    public var background: AnyView
    
    /// normal init
    public init<Content: View>(
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
    public init<MainContent: View, BackgroundContent: View>(
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
    
    public struct Attributes {
        /// for identifying the popover later
        public var tag: String?
        
        public var sourceFrame: (() -> CGRect) = { .zero }
        public var sourceFrameIgnoresSafeArea = true
        public var sourceFrameInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        public var position = Position.absolute(originAnchor: .bottom, popoverAnchor: .top)
        
        /// popover will never go past the screen edges if this is not nil
        public var screenEdgePadding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        public var presentation = Presentation()
        public var dismissal = Dismissal()
        
        /// how the popover will "rubber-band" when dragged
        public var rubberBandingMode: RubberBandingMode = [.xAxis, .yAxis]
        
        /// prevent anything else in the background to be pressed
        public var blocksBackgroundTouches = false
        
        public var onTapOutside: (() -> Void)?
        public var onDismiss: (() -> Void)?
        public var onContextChange: ((Context) -> Void)?
        
        
        public init(
            tag: String? = nil,
            sourceFrame: @escaping (() -> CGRect) = { .zero },
            sourceFrameIgnoresSafeArea: Bool = true,
            sourceFrameInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            position: Popover.Attributes.Position = Position.absolute(originAnchor: .bottom, popoverAnchor: .top),
            screenEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
            presentation: Popover.Attributes.Presentation = Presentation(),
            dismissal: Popover.Attributes.Dismissal = Dismissal(),
            rubberBandingMode: Popover.Attributes.RubberBandingMode = [.xAxis, .yAxis],
            blocksBackgroundTouches: Bool = false,
            onTapOutside: (() -> Void)? = nil,
            onDismiss: (() -> Void)? = nil,
            onContextChange: ((Popover.Context) -> Void)? = nil
        ) {
            self.tag = tag
            self.sourceFrame = sourceFrame
            self.sourceFrameIgnoresSafeArea = sourceFrameIgnoresSafeArea
            self.sourceFrameInset = sourceFrameInset
            self.position = position
            self.screenEdgePadding = screenEdgePadding
            self.presentation = presentation
            self.dismissal = dismissal
            self.rubberBandingMode = rubberBandingMode
            self.blocksBackgroundTouches = blocksBackgroundTouches
            self.onTapOutside = onTapOutside
            self.onDismiss = onDismiss
            self.onContextChange = onContextChange
        }
        
        public struct RubberBandingMode: OptionSet {
            public let rawValue: Int
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public static let xAxis = RubberBandingMode(rawValue: 1 << 0) // 1
            public static let yAxis = RubberBandingMode(rawValue: 1 << 1) // 2
            public static let none = RubberBandingMode([])
        }
        
        public struct Presentation {
            public var animation: Animation? = .default
            public var transition: AnyTransition? = .opacity
            
            
            public init(
                animation: Animation? = .default,
                transition: AnyTransition? = .opacity
            ) {
                self.animation = animation
                self.transition = transition
            }
        }
        
        public struct Dismissal {
            
            public var animation: Animation? = .default
            public var transition: AnyTransition? = .opacity
            
            
            public var mode = Mode.tapOutside
            
            /// only applies when `mode` is .whenTappedOutside
            public var excludedFrames: (() -> [CGRect]) = { [] }
            
            /// to move the popover off the screen or not
            public var dragMovesPopoverOffScreen = true
            
            /// in terms of a percent of the screen height
            /// only applies when `mode` is .dragDown or .dragUp
            /// 0.25 * screen height is where the popover will be dismissed
            public var dragDismissalProximity = CGFloat(0.25)
            
            
            public  init(
                animation: Animation? = .default,
                transition: AnyTransition? = .opacity,
                mode: Popover.Attributes.Dismissal.Mode = Mode.tapOutside,
                excludedFrames: @escaping (() -> [CGRect]) = { [] },
                dragMovesPopoverOffScreen: Bool = true,
                dragDismissalProximity: CGFloat = CGFloat(0.25)
            ) {
                self.animation = animation
                self.transition = transition
                self.mode = mode
                self.excludedFrames = excludedFrames
                self.dragMovesPopoverOffScreen = dragMovesPopoverOffScreen
                self.dragDismissalProximity = dragDismissalProximity
            }
            
            public struct Mode: OptionSet {
                public let rawValue: Int
                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }
                
                public static let tapOutside = Mode(rawValue: 1 << 0) // 1
                public static let dragDown = Mode(rawValue: 1 << 1) // 2
                public static let dragUp = Mode(rawValue: 1 << 2) // 4
                public static let none = Mode([])
            }
        }
        
        public enum Position {
            case absolute(originAnchor: Anchor, popoverAnchor: Anchor)
            case relative(popoverAnchors: [Anchor])
            
            public enum Anchor {
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
    
    public class Context: Identifiable, ObservableObject {
        
        /// id of the popover
        public var id = UUID()
        
        public var attributes = Attributes()
        
        /// calculated from SwiftUI. If this is `nil`, the popover is not yet ready.
        @Published public var size: CGSize?
        
        /// frame of the popover, without gestures applied
        @Published public var staticFrame = CGRect.zero
        
        /// visual frame of the popover shown to the user
        @Published public var frame = CGRect.zero
        
        /// for relative positioning
        @Published public var selectedAnchor: Popover.Attributes.Position.Anchor?
        
        /// for animations
        public var transaction: Transaction?
        
        /// for SwiftUI - set `$present` to false in the view modifier
        internal var dismissed: (() -> Void)?
        
        /// notify when context changed
        public var changeSink: AnyCancellable?
        
        public init() {
            changeSink = objectWillChange.sink { [weak self] in
                guard let self = self else { return }
                self.attributes.onContextChange?(self)
            }
        }
    }
}

public extension Popover {
    
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
    public static func == (lhs: Popover, rhs: Popover) -> Bool {
        return lhs.id == rhs.id
    }
}

