import SwiftUI

/**
 Some templates to get started with Popovers.
 */
public struct PopoverTemplates {
    
    /// Highlight color for the alert and menu buttons.
    public static var buttonHighlightColor = Color.secondary.opacity(0.2)
    
    
    // MARK: - Alert
    
    /// A button style to resemble that of a system alert.
    public struct AlertButtonStyle: ButtonStyle {
        
        /// A button style to resemble that of a system alert.
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .padding()
                .background(
                    configuration.isPressed ? PopoverTemplates.buttonHighlightColor : Color.clear
                )
        }
    }
    
    // MARK: - Blur
    
    /// Use UIKit blurs in SwiftUI.
    public struct VisualEffectView: UIViewRepresentable {
        
        /// The blur's style.
        public var style: UIBlurEffect.Style
        
        /// Use UIKit blurs in SwiftUI.
        public init(_ style: UIBlurEffect.Style) {
            self.style = style
        }
        public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
            UIVisualEffectView()
        }
        public func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
            uiView.effect = UIBlurEffect(style: style)
        }
    }
    
    // MARK: - Shadow Modifier
    
    /**
     A convenient way to apply shadows. Access using the `.popoverContainerShadow()` modifier.
     */
    public struct ContainerShadow: ViewModifier {
        
        /// The shadow color.
        public static var color = Color(.label.withAlphaComponent(0.25))
        
        /// The shadow radius.
        public static var radius = CGFloat(40)
        
        /// The shadow's x offset.
        public static var x = CGFloat(0)
        
        /// The shadow's y offset.
        public static var y = CGFloat(4)
        
        public func body(content: Content) -> some View {
            content
                .shadow(
                    color: ContainerShadow.color,
                    radius: ContainerShadow.radius,
                    x: ContainerShadow.x,
                    y: ContainerShadow.y
                )
        }
    }
    
    // MARK: - Container
    
    /// The side of the popover that the arrow should be placed on.
    /**
     
                          top
            X──────────────X──────────────X
            |                             |
            |                             |
      left  X                             X  right
            |                             |
            |                             |
            X──────────────X──────────────X
                         bottom
     */
    public enum ArrowSide {
        case top(ArrowAlignment)
        case right(ArrowAlignment)
        case bottom(ArrowAlignment)
        case left(ArrowAlignment)
        
        /// Place the arrow on the left, middle, or right on a side.
        /**
               
            mostCounterClockwise    centered          mostClockwise
            ────X──────────────────────X──────────────────────X────
            |                                                     |
                        * diagram is for `ArrowSide.top`
         */
        public enum ArrowAlignment {
            case mostCounterClockwise
            case centered
            case mostClockwise
        }
    }
    
    /**
     A standard container for popovers, complete with arrow.
     */
    public struct Container<Content: View>: View {
        
        /// Which side to place the arrow on.
        public var arrowSide: ArrowSide?
        
        /// The container's corner radius.
        public var cornerRadius = CGFloat(12)
        
        /// The container's background/fill color.
        public var backgroundColor = Color(.systemBackground)
        
        /// The padding around the content view.
        public var padding = CGFloat(16)
        
        /// The content view.
        @ViewBuilder public var view: Content
        
        /**
         A standard container for popovers, complete with arrow.
         - parameter arrowSide: Which side to place the arrow on.
         - parameter cornerRadius: The container's corner radius.
         - parameter backgroundColor: The container's background/fill color.
         - parameter padding: The padding around the content view.
         - parameter view: The content view.
         */
        public init(
            arrowSide: PopoverTemplates.ArrowSide? = nil,
            cornerRadius: CGFloat = CGFloat(12),
            backgroundColor: Color = Color(.systemBackground),
            padding: CGFloat = CGFloat(16),
            @ViewBuilder view: () -> Content
        ) {
            self.arrowSide = arrowSide
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.padding = padding
            self.view = view()
        }
        
        public var body: some View {
            PopoverReader { context in
                view
                    .padding(padding)
                    .background(
                        BackgroundWithArrow(
                            arrowSide: arrowSide ?? context.attributes.position.getArrowPosition(),
                            cornerRadius: cornerRadius
                        )
                            .fill(backgroundColor)
                            .shadow(
                                color: Color(.label.withAlphaComponent(0.25)),
                                radius: 40,
                                x: 0,
                                y: 4
                            )
                    )
            }
        }
    }
    
    // MARK: - Background With Arrow
    
    /**
     A shape that has an arrow protruding.
     */
    public struct BackgroundWithArrow: Shape {
        
        /// The side of the rectangle to have the arrow
        public var arrowSide: ArrowSide
        
        /// The shape's corner radius
        public var cornerRadius: CGFloat
        
        /// The rectangle's width.
        public static var width = CGFloat(48)
        
        /// The rectangle's height.
        public static var height = CGFloat(12)
        
        /// The corner radius for the arrow's tip.
        public static var tipCornerRadius = CGFloat(4)
        
        /// The inverse corner radius for the arrow's base.
        public static var edgeCornerRadius = CGFloat(10)
        
        /// Offset the arrow from the sides - otherwise it will overflow out of the corner radius.
        /**
         
                      /\
                     /_ \
            ----------     <---- Avoid this gap.
                        \
             rectangle  |
         */
        public static var arrowSidePadding = CGFloat(28)
        
        /// Path for the triangular arrow.
        public func arrowPath() -> Path {
            let arrowHalfWidth = (BackgroundWithArrow.width / 2) * 0.6
            
            let arrowPath = Path { path in
                let arrowRect = CGRect(x: 0, y: 0, width: BackgroundWithArrow.width, height: BackgroundWithArrow.height)
                
                path.move(to: CGPoint(x: arrowRect.minX, y: arrowRect.maxY))
                path.addArc(
                    tangent1End: CGPoint(x: arrowRect.midX - arrowHalfWidth, y: arrowRect.maxY),
                    tangent2End: CGPoint(x: arrowRect.midX, y: arrowRect.minX),
                    radius: BackgroundWithArrow.edgeCornerRadius
                )
                path.addArc(
                    tangent1End: CGPoint(x: arrowRect.midX, y: arrowRect.minX),
                    tangent2End: CGPoint(x: arrowRect.midX + arrowHalfWidth, y: arrowRect.maxY),
                    radius: BackgroundWithArrow.tipCornerRadius
                )
                path.addArc(
                    tangent1End: CGPoint(x: arrowRect.midX + arrowHalfWidth, y: arrowRect.maxY),
                    tangent2End: CGPoint(x: arrowRect.maxX, y: arrowRect.maxY),
                    radius: BackgroundWithArrow.edgeCornerRadius
                )
                path.addLine(to: CGPoint(x: arrowRect.maxX, y: arrowRect.maxY))
            }
            return arrowPath
        }
        
        /// Draw the shape.
        public func path(in rect: CGRect) -> Path {
            
            var arrowPath = arrowPath()
            arrowPath = arrowPath.applying(
                .init(translationX: -(BackgroundWithArrow.width / 2), y: -(BackgroundWithArrow.height))
            )
            
            var path = Path()
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
            
            /// Rotation transform to make the arrow hit a different side.
            let arrowTransform: CGAffineTransform
            
            /// Half of the rectangle's smallest side length, used for the arrow's alignment.
            let popoverRadius: CGFloat
            
            let alignment: ArrowSide.ArrowAlignment
            switch arrowSide {
            case .top(let arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(translationX: rect.midX, y: 0)
                popoverRadius = (rect.width / 2) - BackgroundWithArrow.arrowSidePadding
            case .right(let arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(rotationAngle: 90.degreesToRadians)
                    .translatedBy(x: rect.midY, y: -rect.maxX)
                popoverRadius = (rect.height / 2) - BackgroundWithArrow.arrowSidePadding
            case .bottom(let arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(rotationAngle: 180.degreesToRadians)
                    .translatedBy(x: -rect.midX, y: -rect.maxY)
                popoverRadius = (rect.width / 2) - BackgroundWithArrow.arrowSidePadding
            case .left(let arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(rotationAngle: 270.degreesToRadians)
                    .translatedBy(x: -rect.midY, y: 0)
                popoverRadius = (rect.height / 2) - BackgroundWithArrow.arrowSidePadding
            }
            
            switch alignment {
            case .mostCounterClockwise:
                arrowPath = arrowPath.applying(
                    .init(translationX: -popoverRadius, y: 0)
                )
            case .centered:
                break
            case .mostClockwise:
                arrowPath = arrowPath.applying(
                    .init(translationX: popoverRadius, y: 0)
                )
            }

            path.addPath(arrowPath, transform: arrowTransform)
            
            return path
            
        }
    }
    
    
    // MARK: - Curve Connector
    
    /**
     A curved line between 2 points.
     */
    public struct CurveConnector: Shape {
        
        /// The start point.
        public var start: CGPoint
        
        /// The end point.
        public var end: CGPoint
        
        /// The curve's steepness.
        public var steepness = CGFloat(0.3)
        
        /// The curve's direction.
        public var direction = Direction.vertical
        
        /**
         A curved line between 2 points.
         - parameter start: The start point.
         - parameter end: The end point.
         - parameter steepness: The curve's steepness.
         - parameter direction: The curve's direction.
         */
        public init(
            start: CGPoint,
            end: CGPoint,
            steepness: CGFloat = CGFloat(0.3),
            direction: PopoverTemplates.CurveConnector.Direction = Direction.vertical
        ) {
            self.start = start
            self.end = end
            self.steepness = steepness
            self.direction = direction
        }
        
        /**
         Horizontal or Vertical line.
         */
        public enum Direction {
            case horizontal
            case vertical
        }
        
        /// Allow animations. From https://www.objc.io/blog/2020/03/10/swiftui-path-animations/
        public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
            get { AnimatablePair(start.animatableData, end.animatableData) }
            set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
        }
        
        /// Draw the curve.
        public func path(in rect: CGRect) -> Path {
            
            let startControlPoint: CGPoint
            let endControlPoint: CGPoint
            
            switch direction {
            case .horizontal:
                let curveWidth = end.x - start.x
                let curveSteepness = curveWidth * steepness
                startControlPoint = CGPoint(x: start.x + curveSteepness, y: start.y)
                endControlPoint = CGPoint(x: end.x - curveSteepness, y: end.y)
            case .vertical:
                let curveHeight = end.y - start.y
                let curveSteepness = curveHeight * steepness
                startControlPoint = CGPoint(x: start.x, y: start.y + curveSteepness)
                endControlPoint = CGPoint(x: end.x, y: end.y - curveSteepness)
            }
            
            var path = Path()
            path.move(to: start)
            path.addCurve(to: end, control1: startControlPoint, control2: endControlPoint)
            return path
        }
    }
    
    // MARK: - Menu
    
    /// View model for the menu.
    public class MenuModel: ObservableObject {
        
        /// The active (hovering) button.
        @Published var active: Int?
        
        /// The selected button.
        @Published var selected: Int?
        
        /// Array of buttons.
        @Published var destinations: [Int: CGRect] = [:]
    }
    
    /// Class for injecting an ID into a `MenuButton`.
    class MenuID: ObservableObject {
        @Published var id: Int
        init(_ id: Int) {
            self.id = id
        }
    }
    
    /**
     A button for use in a `PopoverTemplates.Menu`.
     */
    public struct MenuButton: View {
        
        /// The button's title.
        public var title: String
        
        /// The button's image (system icon).
        public var image: String
        
        /// The action to be executed when the button is pressed.
        public var action: (() -> Void)
        
        /// The Menu view model.
        @EnvironmentObject var model: MenuModel
        
        /// The button's ID in a wrapper class.
        @EnvironmentObject var menuID: MenuID
        
        /**
         A button for use in a `PopoverTemplates.Menu`.
         - parameter title: The button's title.
         - parameter image: The button's image (system icon).
         - parameter action: The action to be executed when the button is pressed.
         */
        public init(title: String, image: String, action: @escaping (() -> Void)) {
            self.title = title
            self.image = image
            self.action = action
        }
        
        public var body: some View {
            HStack(spacing: 8) {
                Text(title)
                
                Spacer()
                
                Image(systemName: image)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
            .background(model.active == menuID.id ? PopoverTemplates.buttonHighlightColor : .clear)
            .foregroundColor(.primary)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        
                        /// First set to nil (out of bounds).
                        model.active = nil
                        
                        /// Then check if the point is inside another button.
                        for (id, destination) in model.destinations {
                            if destination.contains(value.location) {
                                model.active = id
                            }
                        }
                    }
                    .onEnded { value in
                        model.selected = model.active
                        model.active = nil
                    }
            )
            .onDataChange(of: model.selected) { (_, _) in
                if
                    let selected = model.selected,
                    selected == menuID.id
                {
                    /// Call the action if the selected button is this button.
                    action()
                }
            }
            .background(DestinationDataSetter(destination: menuID.id))
        }
    }
    
    /**
     A built-from-scratch version of the system menu.
     */
    public struct Menu: View {
        
        /// View model for the child buttons.
        @StateObject var model = MenuModel()
        
        /// If the menu is shrunk down and not visible (for transitions).
        @State var shrunk = true
        
        /// The menu buttons.
        public let content: [AnyView]
        
        /**
         Create a custom menu.
         */
        public init<Views>(@ViewBuilder content: @escaping () -> TupleView<Views>) {
            self.content = content().getViews
        }
        
        public var body: some View {
            PopoverReader { context in
                VStack(spacing: 0) {
                    ForEach(content.indices) { index in
                        content[index]
                            .environmentObject(MenuID(index)) /// Pass down the index.
                            .environmentObject(model) /// Pass down the model.
                    }
                    .border(
                        Color(.secondaryLabel.withAlphaComponent(0.25)),
                        width: 0.3
                    )
                }
                .onPreferenceChange(DestinationDataKey.self) { preferences in
                    for p in preferences {
                        self.model.destinations[p.destination] = p.frame
                    }
                }
                .fixedSize()
                .padding(-1) /// To hide the border's horizontal edges.
                .background(VisualEffectView(.regular))
                .cornerRadius(12)
                .popoverContainerShadow()
                .scaleEffect( /// Add a scale effect to shrink down the popover at first.
                    shrunk ? 0.2 : 1,
                    anchor: .topTrailing
                )
            }
            .onAppear {
                withAnimation(
                    .spring(
                        response: 0.4,
                        dampingFraction: 0.8,
                        blendDuration: 1
                    )
                ) {
                    shrunk = false
                }
            }
        }
        
        /// Get the point to scale from.
        func getScaleAnchor(attributes: Popover.Attributes) -> UnitPoint {
            if case let .absolute(_, popoverAnchor) = attributes.position {
                return popoverAnchor.unitPoint
            }
            
            return .center
        }
    }
    
    
    /// Allow dragging between buttons. From https://stackoverflow.com/a/58901508/14351818
    struct DestinationDataKey: PreferenceKey {
        typealias Value = [DestinationData]
        static var defaultValue: [DestinationData] = []
        static func reduce(value: inout [DestinationData], nextValue: () -> [DestinationData]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    struct DestinationData: Equatable {
        let destination: Int
        let frame: CGRect
    }
    
    struct DestinationDataSetter: View {
        let destination: Int
        
        var body: some View {
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .preference(
                        key: DestinationDataKey.self,
                        value: [
                            DestinationData(
                                destination: self.destination,
                                frame: geometry.frame(in: .global)
                            )
                        ]
                    )
            }
        }
    }
}


// MARK: - Arrow Position

public extension Popover.Attributes.Position {
    
    /// Determine which side an arrow is best placed.
    func getArrowPosition() -> PopoverTemplates.ArrowSide {
        
        /// This only applied when the position is `.absolute`.
        if case let .absolute(originAnchor, popoverAnchor) = self {
            
            /// X = popover
            switch originAnchor {
            case .topLeft:
                // X ------------
                // | source frame
                // |
                switch popoverAnchor {
                case .topRight:
                    return .right(.mostCounterClockwise)
                case .right:
                    return .right(.centered)
                case .bottomLeft:
                    return .bottom(.mostClockwise)
                case .bottom:
                    return .bottom(.centered)
                default:
                    break
                }
            case .top:
                //  -------X-------
                // | source frame  |
                // |               |
                switch popoverAnchor {
                case .bottomRight:
                    return .bottom(.mostCounterClockwise)
                case .bottom:
                    return .bottom(.centered)
                case .bottomLeft:
                    return .bottom(.mostClockwise)
                default:
                    break
                }
            case .topRight:
                //  ------------- X
                //   source frame |
                //                |
                switch popoverAnchor {
                case .bottomRight:
                    return .bottom(.mostCounterClockwise)
                case .bottom:
                    return .bottom(.centered)
                case .left:
                    return .left(.centered)
                case .topLeft:
                    return .left(.mostClockwise)
                default:
                    break
                }
            case .right:
                //  ------------- |
                //  source frame  X
                //  ______________|
                switch popoverAnchor {
                case .bottomLeft:
                    return .left(.mostCounterClockwise)
                case .left:
                    return .left(.centered)
                case .topLeft:
                    return .left(.mostClockwise)
                default:
                    break
                }
            case .bottomRight:
                //                 |
                //  source frame   |
                //  ______________ X
                switch popoverAnchor {
                case .bottomLeft:
                    return .left(.mostCounterClockwise)
                case .left:
                    return .left(.centered)
                case .top:
                    return .top(.centered)
                case .topRight:
                    return .top(.mostClockwise)
                default:
                    break
                }
            case .bottom:
                //  |                |
                //  |  source frame  |
                //  |_______X________|
                switch popoverAnchor {
                case .topRight:
                    return .top(.mostCounterClockwise)
                case .top:
                    return .top(.centered)
                case .topLeft:
                    return .top(.mostClockwise)
                default:
                    break
                }
            case .bottomLeft:
                //  |
                //  | source frame
                //  X ______________
                switch popoverAnchor {
                case .topLeft:
                    return .top(.mostCounterClockwise)
                case .top:
                    return .top(.centered)
                case .right:
                    return .right(.centered)
                case .bottomRight:
                    return .top(.mostClockwise)
                default:
                    break
                }
            case .left:
                //  |--------------
                //  X  source frame
                //  |______________
                switch popoverAnchor {
                case .topRight:
                    return .right(.mostCounterClockwise)
                case .right:
                    return .right(.centered)
                case .bottomRight:
                    return .right(.mostClockwise)
                default:
                    break
                }
            case .center:
                break
            }
        }
        
        /// No preferred arrow. Just go with a top-centered one.
        return .top(.centered)
    }
}

// MARK: - Shadow
public extension View {
    
    /// Apply a system-like shadow.
    func popoverContainerShadow() -> some View {
        self.modifier(PopoverTemplates.ContainerShadow())
    }
}

// MARK: - Utilities

/// Convert degrees to radians and back. From https://stackoverflow.com/a/29179878
public extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

public extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}


/// Get an array of views from `@ViewBuilder`. From https://stackoverflow.com/a/67243688/14351818
/// Used for the Menu template.
public extension TupleView {
    var getViews: [AnyView] {
        makeArray(from: value)
    }
    
    private struct GenericView {
        let body: Any
        
        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }
    
    private func makeArray<Tuple>(from tuple: Tuple) -> [AnyView] {
        func convert(child: Mirror.Child) -> AnyView? {
            withUnsafeBytes(of: child.value) { ptr -> AnyView? in
                let binded = ptr.bindMemory(to: GenericView.self)
                return binded.first?.anyView
            }
        }
        
        let tupleMirror = Mirror(reflecting: tuple)
        return tupleMirror.children.compactMap(convert)
    }
}
