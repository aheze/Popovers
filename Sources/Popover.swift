//
//  Popover.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

/**
 A view that is placed over other views.
 */
public struct Popover: Identifiable {
    /**
     Stores information about the popover.
     This includes the attributes, frame, and acts like a view model. If using SwiftUI, access it using `PopoverReader`.
     */
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
        background = AnyView(Color.clear)
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
        self.view = AnyView(view().environmentObject(self.context))
        self.background = AnyView(background().environmentObject(self.context))
    }

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
        public init(
            tag: AnyHashable? = nil,
            position: Popover.Attributes.Position = Position.absolute(originAnchor: .bottom, popoverAnchor: .top),
            sourceFrame: @escaping (() -> CGRect) = { .zero },
            sourceFrameInset: UIEdgeInsets = UIEdgeInsets.zero,
            screenEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
            presentation: Popover.Attributes.Presentation = Presentation(),
            dismissal: Popover.Attributes.Dismissal = Dismissal(),
            rubberBandingMode: Popover.Attributes.RubberBandingMode = [.xAxis, .yAxis],
            blocksBackgroundTouches: Bool = false,
            accessibility: Accessibility = Accessibility(),
            onTapOutside: (() -> Void)? = nil,
            onDismiss: (() -> Void)? = nil,
            onContextChange: ((Popover.Context) -> Void)? = nil
        ) {
            self.tag = tag
            self.position = position
            self.sourceFrame = sourceFrame
            self.sourceFrameInset = sourceFrameInset
            self.screenEdgePadding = screenEdgePadding
            self.presentation = presentation
            self.dismissal = dismissal
            self.rubberBandingMode = rubberBandingMode
            self.blocksBackgroundTouches = blocksBackgroundTouches
            self.accessibility = accessibility
            self.onTapOutside = onTapOutside
            self.onDismiss = onDismiss
            self.onContextChange = onContextChange
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

    /**
     The popover's view model (stores attributes, frame, and other visible traits).
     */
    public class Context: Identifiable, ObservableObject {
        /// The popover's ID. Must be unique, unless replacing an existing popover.
        public var id = UUID()

        /// The popover's customizable properties.
        public var attributes = Attributes()

        /// The popover's dynamic size, calculated from SwiftUI. If this is `nil`, the popover is not yet ready to be displayed.
        @Published public var size: CGSize?

        /// The frame of the popover, without drag gesture offset applied.
        @Published public var staticFrame = CGRect.zero

        /// The current frame of the popover.
        @Published public var frame = CGRect.zero

        /// The currently selected anchor, if the popover has a `.relative` position.
        @Published public var selectedAnchor: Popover.Attributes.Position.Anchor?

        /// For animation syncing. If this is not nil, the popover is in the middle of a frame refresh.
        public var transaction: Transaction?

        /// Notify when the context changed.
        public var changeSink: AnyCancellable?

        /// Indicates whether the popover can be dragged.
        public var isDraggingEnabled: Bool {
            get {
                popoverModel?.popoversDraggable ?? false
            }
            set {
                popoverModel?.popoversDraggable = newValue
            }
        }

        public var window: UIWindow {
            if let window = presentedPopoverContainer?.window {
                return window
            } else {
                print("[Popovers] - This popover is not tied to a window. Please file a bug report (https://github.com/aheze/Popovers/issues).")
                return UIWindow()
            }
        }

        /**
         The bounds of the window in which the `Popover` is being presented, or the `zero` frame if the popover has not been presented yet.
         */
        public var windowBounds: CGRect {
            presentedPopoverContainer?.window?.bounds ?? .zero
        }

        /**
         For the SwiftUI `.popover` view modifier. This is for internal use only - use `Popover.Attributes.onDismiss` if you want to know when the popover is dismissed.

         This is called just after the popover is removed from the model - inside the view modifier, set `$present` to false when this is called.
         */
        internal var onAutoDismiss: (() -> Void)?

        /// Invoked by the SwiftUI container view when the view has fully disappeared.
        internal var onDisappear: (() -> Void)?

        /// The `UIView` presenting this `Popover`, or `nil` if no popovers are currently being presented.
        internal var presentedPopoverContainer: UIView?

        /// The `PopoverModel` managing the `Popover`. Sourced from the `presentedPopoverViewController`.
        private var popoverModel: PopoverModel? {
            return presentedPopoverContainer?.popoverModel
        }

        /// Create a context for the popover. You shouldn't need to use this - it's done automatically when you create a new popover.
        public init() {
            changeSink = objectWillChange.sink { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.attributes.onContextChange?(self)
                }
            }
        }
    }
}

public extension Popover {
    /**
     Convenience accessor for the popover's ID.
     */
    var id: UUID {
        get {
            context.id
        } set {
            context.id = newValue
        }
    }

    /// Convenience accessor for the popover's attributes.
    var attributes: Attributes {
        get {
            context.attributes
        } set {
            context.attributes = newValue
        }
    }

    /// Updates the popover's frame using its size.
    func updateFrame(with size: CGSize?) {
        let frame = calculateFrame(from: size)
        context.size = size
        context.staticFrame = frame
        context.frame = frame
    }

    /// Calculate the popover's frame based on its size and position.
    func calculateFrame(from size: CGSize?) -> CGRect {
        guard let window = context.presentedPopoverContainer?.window else { return .zero }

        switch attributes.position {
        case let .absolute(originAnchor, popoverAnchor):
            var popoverFrame = attributes.position.absoluteFrame(
                originAnchor: originAnchor,
                popoverAnchor: popoverAnchor,
                originFrame: attributes.sourceFrame().inset(by: attributes.sourceFrameInset),
                popoverSize: size ?? .zero
            )

            let screenEdgePadding = attributes.screenEdgePadding

            let safeWindowFrame = window.safeAreaLayoutGuide.layoutFrame
            let maxX = safeWindowFrame.maxX - screenEdgePadding.right
            let maxY = safeWindowFrame.maxY - screenEdgePadding.bottom

            /// Popover overflows on left/top side.
            if popoverFrame.origin.x < screenEdgePadding.left {
                popoverFrame.origin.x = screenEdgePadding.left
            }
            if popoverFrame.origin.y < screenEdgePadding.top {
                popoverFrame.origin.y = screenEdgePadding.top
            }

            /// Popover overflows on the right/bottom side.
            if popoverFrame.maxX > maxX {
                let difference = popoverFrame.maxX - maxX
                popoverFrame.origin.x -= difference
            }
            if popoverFrame.maxY > maxY {
                let difference = popoverFrame.maxY - maxY
                popoverFrame.origin.y -= difference
            }

            return popoverFrame
        case let .relative(popoverAnchors):

            /// Set the selected anchor to the first one.
            if context.selectedAnchor == nil {
                context.selectedAnchor = popoverAnchors.first
            }

            let popoverFrame = attributes.position.relativeFrame(
                selectedAnchor: context.selectedAnchor ?? popoverAnchors.first ?? .bottom,
                containerFrame: attributes.sourceFrame().inset(by: attributes.sourceFrameInset),
                popoverSize: size ?? .zero
            )
            return popoverFrame
        }
    }

    /// Calculate if the popover should be dismissed via drag **or** animated to another position (if using `.relative` positioning with multiple anchors). Called when the user stops dragging the popover.
    func positionChanged(to point: CGPoint) {
        let windowBounds = context.windowBounds

        if
            attributes.dismissal.mode.contains(.dragDown),
            point.y >= windowBounds.height - windowBounds.height * attributes.dismissal.dragDismissalProximity
        {
            if attributes.dismissal.dragMovesPopoverOffScreen {
                var newFrame = context.staticFrame
                newFrame.origin.y = windowBounds.height
                context.staticFrame = newFrame
                context.frame = newFrame
            }
            dismiss()
            return
        }
        if
            attributes.dismissal.mode.contains(.dragUp),
            point.y <= windowBounds.height * attributes.dismissal.dragDismissalProximity
        {
            if attributes.dismissal.dragMovesPopoverOffScreen {
                var newFrame = context.staticFrame
                newFrame.origin.y = -newFrame.height
                context.staticFrame = newFrame
                context.frame = newFrame
            }
            dismiss()
            return
        }

        if case let .relative(popoverAnchors) = attributes.position {
            let frame = attributes.sourceFrame().inset(by: attributes.sourceFrameInset)
            let size = context.size ?? .zero

            let closestAnchor = attributes.position.relativeClosestAnchor(
                popoverAnchors: popoverAnchors,
                containerFrame: frame,
                popoverSize: size,
                targetPoint: point
            )
            let popoverFrame = attributes.position.relativeFrame(
                selectedAnchor: closestAnchor,
                containerFrame: frame,
                popoverSize: size
            )

            context.selectedAnchor = closestAnchor
            context.staticFrame = popoverFrame
            context.frame = popoverFrame
        }
    }
}

extension Popover: Equatable {
    /// Conform to equatable.
    public static func == (lhs: Popover, rhs: Popover) -> Bool {
        return lhs.id == rhs.id
    }
}
