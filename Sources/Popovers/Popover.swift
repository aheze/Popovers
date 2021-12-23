//
//  Popover.swift
//  Popover
//
//  Created by Zheng on 12/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI
import Combine

/**
 A view that is placed over other views.
 */
public struct Popover: Identifiable {
    
    /// Stores information about the popover.
    ///
    /// This includes the attributes, frame, and acts like a view model. If using SwiftUI, access it using `PopoverReader`.
    public var context: Context
    
    /// The view that the popover presents.
    public var view: AnyView
    
    /// A view that goes behind the popover.
    public var background: AnyView
    
    /**
     A popover.
     - parameter attributes: Customize the popover.
     - parameter view: The view to present.
     */
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
    
    /**
     A popover with a background.
     - parameter attributes: Customize the popover.
     - parameter view: The view to present.
     - parameter background: The view to present in the background.
     */
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
    
    /**
     Properties to customize the popover.
     */
    public struct Attributes {
        
        /// Add a tag to reference the popover from anywhere.
        public var tag: String?
        
        /// The frame that the popover attaches to. Automatically provided if you're using SwiftUI.
        public var sourceFrame: (() -> CGRect) = { .zero }
        
        /// Inset the source frame by this.
        public var sourceFrameInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        /// The popover's position.
        public var position = Position.absolute(originAnchor: .bottom, popoverAnchor: .top)
        
        /// Padding to prevent the popover from overflowing off the screen.
        public var screenEdgePadding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        /// Stores popover animation and transition values for presentation.
        public var presentation = Presentation()
        
        /// Stores popover animation and transition values for dismissal.
        public var dismissal = Dismissal()
        
        /// The axes that the popover will "rubber-band" on when dragged
        public var rubberBandingMode: RubberBandingMode = [.xAxis, .yAxis]
        
        /// Prevent views underneath the popover from being pressed.
        public var blocksBackgroundTouches = false
        
        /// Called when the user taps outside the popover.
        public var onTapOutside: (() -> Void)?
        
        /// Called when the popover is dismissed.
        public var onDismiss: (() -> Void)?
        
        /// Called when the context changes.
        public var onContextChange: ((Context) -> Void)?
        
        /**
         Create the default attributes for a popover.
         */
        public init(
            tag: String? = nil,
            sourceFrame: @escaping (() -> CGRect) = { .zero },
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
        
        /**
         The "rubber-banding" behavior of the popover when it is dragged.
         */
        public struct RubberBandingMode: OptionSet {
            public let rawValue: Int
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            /// Enable rubber banding on the x-axis.
            public static let xAxis = RubberBandingMode(rawValue: 1 << 0) // 1
            
            /// Enable rubber banding on the y-axis.
            public static let yAxis = RubberBandingMode(rawValue: 1 << 1) // 2
            
            /// Disable rubber banding.
            public static let none = RubberBandingMode([])
        }
        
        /// The popover's presentation animation and transition.
        public struct Presentation {
            
            /// The animation timing used when the popover is presented.
            public var animation: Animation? = .default
            
            /// The transition used when the popover is presented.
            public var transition: AnyTransition? = .opacity
            
            /// Create the default animation and transition for the popover.
            public init(
                animation: Animation? = .default,
                transition: AnyTransition? = .opacity
            ) {
                self.animation = animation
                self.transition = transition
            }
        }
        
        /// The popover's dismissal animation, transition, and other behavior.
        public struct Dismissal {
            
            /// The animation timing used when the popover is dismissed.
            public var animation: Animation? = .default
            
            /// The transition used when the popover is dismissed.
            public var transition: AnyTransition? = .opacity
            
            /**
             The dismissal behavior of the popover.
             - `.tapOutside` - dismiss the popover when the user taps outside.
             - `.dragDown` - dismiss the popover when the user drags it down.
             - `.dragUp` - dismiss the popover when the user drags it up.
             - `.none` - don't automatically dismiss the popover.
             */
            
            public var mode = Mode.tapOutside
            
            /// Don't dismiss the popover when the user taps on these frames. Only applies when `mode` is `.tapOutside`.
            public var excludedFrames: (() -> [CGRect]) = { [] }
            
            /// Move the popover off the screen if a `.dragDown` or `.dragUp` happens.
            public var dragMovesPopoverOffScreen = true
            
            /// The point on the screen until the popover can be dismissed. Only applies when `mode` is `.dragDown` or `.dragUp`. See diagram for details.
            /**
          
         ┌────────────────┐
         |░░░░░░░░░░░░░░░░|    ░ = if the popover is dragged
         |░░░░░░░░░░░░░░░░|        to this area, it will be dismissed.
         |░░░░░░░░░░░░░░░░|
         |░░░░░░░░░░░░░░░░|        the height of this area is 0.25 * screen height.
         |                |
         |                |
         |                |
              
             */
            public var dragDismissalProximity = CGFloat(0.25)
            
            
            public init(
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

