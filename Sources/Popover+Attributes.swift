//
//  Popover+Attributes.swift
//
//
//  Created by A. Zheng (github.com/aheze) on 3/19/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

#if os(iOS)
import SwiftUI

extension Popover {
    /**
     Properties to customize the popover.
     */
    public struct Attributes {
        /**
         Add a tag to reference the popover from anywhere. If you use `.popover(selection:tag:attributes:view:)`, this `tag` is automatically set to what you provide in the parameter.
         
         Use `Popovers.popovers(tagged: "Your Tag")` to access popovers that are currently presented.
         */
        public var tag: AnyHashable?
        
        /// The popover's position.
        public var position = Position.absolute(originAnchor: .bottom, popoverAnchor: .top)
        
        /**
         The frame that the popover attaches to or is placed within (configure in `position`). This must be in global window coordinates.
         
         If you're using SwiftUI, this is automatically provided.
         If you're using UIKit, you must provide this. Use `.windowFrame()` to convert to window coordinates.
         
         attributes.sourceFrame = { [weak button] in /// `weak` to prevent a retain cycle
         button.windowFrame()
         }
         */
        public var sourceFrame: (() -> CGRect) = { .zero }
        
        /// Inset the source frame by this.
        public var sourceFrameInset = UIEdgeInsets.zero
        
        public var source = Source.stayAboveWindows
        
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
        
        /// Allows popover's location to be changed to its last location.
        public var changeLocationOnDismiss = false
        
        /// Frames that won't be blocked when `blocksBackgroundTouches` is turned on.
        public var blocksBackgroundTouchesAllowedFrames: () -> [CGRect] = { [] }
        
        /// Stores accessibility values.
        public var accessibility = Accessibility()
        
        /// Called when the user taps outside the popover.
        public var onTapOutside: (() -> Void)?
        
        /// Called when the popover is dismissed.
        public var onDismiss: (() -> Void)?
        
        /// Called when the context changes.
        public var onContextChange: ((Context) -> Void)?
        
        /**
         Create the default attributes for a popover.
         */
        public init() {}
        
        public enum Source {
            case aboveCurrentWindow
            case stayAboveWindows
        }
        
        /**
         The position of the popover.
         - `absolute` - attach the popover to a source view.
         - `relative` - place the popover within a container view.
         */
        public enum Position {
            /**
             Attach the popover to a source view (supplied by the attributes' `sourceFrame` property).
             - parameter originAnchor: The corner of the source view used as the attaching point.
             - parameter popoverAnchor: The corner of the popover that attaches to the source view.
             */
            case absolute(originAnchor: Anchor, popoverAnchor: Anchor)
            
            /**
             Place the popover within a container view (supplied by the attributes' `sourceFrame` property).
             - parameter popoverAnchors: The corners of the container view that the popover can be placed. Supply multiple to get a picture-in-picture behavior..
             */
            case relative(popoverAnchors: [Anchor])
            
            /// The edges and corners of a rectangle.
            /**
             
             topLeft              top              topRight
             X──────────────X──────────────X
             |                             |
             |                             |
             left   X            center           X   right
             |                             |
             |                             |
             X──────────────X──────────────X
             bottomLeft          bottom         bottomRight
             
             */
            public enum Anchor {
                /// The point at the **top-left** of a rectangle.
                case topLeft
                
                /// The point at the **top** of a rectangle.
                case top
                
                /// The point at the **top-right** of a rectangle.
                case topRight
                
                /// The point at the **right** of a rectangle.
                case right
                
                /// The point at the **bottom-right** of a rectangle.
                case bottomRight
                
                /// The point at the **bottom** of a rectangle.
                case bottom
                
                /// The point at the **bottom-left** of a rectangle.
                case bottomLeft
                
                /// The point at the **left** of a rectangle.
                case left
                
                /// The point at the **center** of a rectangle.
                case center
            }
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
            public var animation: Animation? = .easeOut
            
            /// The transition used when the popover is presented.
            public var transition: AnyTransition? = .opacity
            
            /// Create the default animation and transition for the popover.
            public init(
                animation: Animation? = .easeOut,
                transition: AnyTransition? = .opacity
            ) {
                self.animation = animation
                self.transition = transition
            }
        }
        
        /// The popover's dismissal animation, transition, and other behavior.
        public struct Dismissal {
            /// The animation timing used when the popover is dismissed.
            public var animation: Animation? = .easeOut
            
            /// The transition used when the popover is dismissed.
            public var transition: AnyTransition? = .opacity
            
            /**
             The auto-dismissal behavior of the popover.
             - `.tapOutside` - dismiss the popover when the user taps outside the popover.
             - `.dragDown` - dismiss the popover when the user drags it down.
             - `.dragUp` - dismiss the popover when the user drags it up.
             - `.none` - don't automatically dismiss the popover.
             */
            public var mode = Mode.tapOutside
            
            /// Dismiss the popover when the user taps outside, **even when another presented popover is what's tapped**. Only applies when `mode` is `.tapOutside`.
            public var tapOutsideIncludesOtherPopovers = false
            
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
            
            /// Create the default dismissal behavior for the popover.
            public init(
                animation: Animation? = .easeOut,
                transition: AnyTransition? = .opacity,
                mode: Popover.Attributes.Dismissal.Mode = Mode.tapOutside,
                tapOutsideIncludesOtherPopovers: Bool = false,
                excludedFrames: @escaping (() -> [CGRect]) = { [] },
                dragMovesPopoverOffScreen: Bool = true,
                dragDismissalProximity: CGFloat = CGFloat(0.25)
            ) {
                self.animation = animation
                self.transition = transition
                self.mode = mode
                self.tapOutsideIncludesOtherPopovers = tapOutsideIncludesOtherPopovers
                self.excludedFrames = excludedFrames
                self.dragMovesPopoverOffScreen = dragMovesPopoverOffScreen
                self.dragDismissalProximity = dragDismissalProximity
            }
            
            /**
             The auto-dismissal behavior of the popover.
             - `.tapOutside` - dismiss the popover when the user taps outside.
             - `.dragDown` - dismiss the popover when the user drags it down.
             - `.dragUp` - dismiss the popover when the user drags it up.
             - `.none` - don't automatically dismiss the popover.
             */
            public struct Mode: OptionSet {
                public let rawValue: Int
                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }
                
                /// Dismiss the popover when the user taps outside.
                public static let tapOutside = Mode(rawValue: 1 << 0) // 1
                
                /// Dismiss the popover when the user drags it down.
                public static let dragDown = Mode(rawValue: 1 << 1) // 2
                
                /// Dismiss the popover when the user drags it up.
                public static let dragUp = Mode(rawValue: 1 << 2) // 4
                
                /// Don't automatically dismiss the popover.
                public static let none = Mode([])
            }
        }
        
        /// Define VoiceOver behavior.
        public struct Accessibility {
            /// Focus the popover when presented.
            public var shiftFocus = true
            
            /**
             A view that's only shown when VoiceOver is running. Dismisses the popover when tapped.
             
             Tap-outside-to-dismiss is unsupported in VoiceOver, so this provides an alternate method for dismissal.
             */
            public var dismissButtonLabel: AnyView? = defaultDismissButtonLabel
            
            /// Create the default VoiceOver behavior for the popover.
            public init(
                shiftFocus: Bool = true,
                dismissButtonLabel: (() -> AnyView)? = { defaultDismissButtonLabel }
            ) {
                self.shiftFocus = shiftFocus
                self.dismissButtonLabel = dismissButtonLabel?()
            }
            
            /// The default voiceover dismiss button view, an X
            public static let defaultDismissButtonLabel: AnyView = .init(
                AnyView(
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.25))
                        .cornerRadius(18)
                )
                .accessibilityElement()
                .accessibility(label: Text("Close"))
                .accessibility(hint: Text("Dismiss this popover."))
            )
        }
    }
}
#endif
