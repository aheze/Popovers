import SwiftUI

extension View {
    func popoverContainerShadow() -> some View {
        self.modifier(PopoverTemplates.ContainerShadow())
    }
}

struct PopoverTemplates {
    static var buttonHighlightColor = Color.secondary.opacity(0.2)
    
    class MenuModel: ObservableObject {
        @Published var active: Int?
        @Published var selected: Int?
        @Published var destinations: [Int: CGRect] = [:]
    }
    class MenuID: ObservableObject {
        @Published var id: Int
        init(_ id: Int) {
            self.id = id
        }
    }
    struct MenuButton: View {
        var title: String
        var image: String
        var action: (() -> Void)
        @EnvironmentObject var model: MenuModel
        @EnvironmentObject var menuID: MenuID
        
        var body: some View {
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
                        
                        /// first set to nil (out of bounds)
                        model.active = nil
                        
                        /// then check if the point is inside another button
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
            .onChange(of: model.selected) { _ in
                if 
                    let selected = model.selected,
                    selected == menuID.id
                {
                    action()
                }
            }
            .background(DestinationDataSetter(destination: menuID.id))
        }
    }
    
    struct Menu: View {
        @StateObject var model = MenuModel()
        @State var shrunk = true
        
        let content: [AnyView]
        
        init<Views>(@ViewBuilder content: @escaping () -> TupleView<Views>) {
            self.content = content().getViews
        }
        
        var body: some View {
            PopoverReader { context in
                VStack(spacing: 0) {
                    ForEach(content.indices) { index in
                        content[index]
                            .environmentObject(MenuID(index)) /// pass down the index
                            .environmentObject(model) /// pass down the model
                    }
                    .border(
                        Color(
                            uiColor: .secondaryLabel.withAlphaComponent(0.25)
                        ), 
                        width: 0.3
                    )
                }
                .onPreferenceChange(DestinationDataKey.self) { preferences in
                    for p in preferences {
                        self.model.destinations[p.destination] = p.frame
                    }
                }
                .fixedSize()
                .padding(-1)
                .background(.regularMaterial)
                .cornerRadius(12)
                .popoverContainerShadow()
                .scaleEffect(
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
        
        func getScaleAnchor(attributes: Popover.Attributes) -> UnitPoint {
            if case let .absolute(_, popoverAnchor) = attributes.position {
                return popoverAnchor.unitPoint
            }
            
            return .center
        }
    }
    
    
    /// from https://stackoverflow.com/a/58901508/14351818
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
    
    struct AlertButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .padding()
                .background {
                    configuration.isPressed ? PopoverTemplates.buttonHighlightColor : Color.clear
                }
        }
    }
    
    struct VisualScaleEffect: GeometryEffect {
        var scale: CGFloat
        
        var animatableData: CGFloat {
            get { scale }
            set { scale = newValue }
        }
        
        func effectValue(size: CGSize) -> ProjectionTransform {
            let scaledWidth = size.width * scale
            let scaledHeight = size.height * scale
            
            return ProjectionTransform(
                CGAffineTransform(
                    translationX: -(scaledWidth - size.width) / 2,
                    y: -(scaledHeight - size.height) / 2
                )
                    .scaledBy(x: scale, y: scale)
            )
        }
    }
    
    struct VisualEffectView: UIViewRepresentable {
        var style: UIBlurEffect.Style
        init(_ style: UIBlurEffect.Style) {
            self.style = style
        }
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
            UIVisualEffectView()
        }
        func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { 
            uiView.effect = UIBlurEffect(style: style)
        }
    }
    
    struct ContainerShadow: ViewModifier {
        static var color = Color(uiColor: .label.withAlphaComponent(0.25))
        static var radius = CGFloat(40)
        static var x = CGFloat(0)
        static var y = CGFloat(4)
        
        func body(content: Content) -> some View {
            content
                .shadow(
                    color: ContainerShadow.color,
                    radius: ContainerShadow.radius,
                    x: ContainerShadow.x,
                    y: ContainerShadow.y
                )
        }
    }
    
    
    /// the side of the popover that the arrow should be placed on
    enum ArrowSide {
        case top
        case right
        case bottom
        case left
    }
    
    /// place the arrow on the left, middle, or right on the side
    enum ArrowAlignment {
        case mostCounterClockwise
        case centered
        case mostClockwise
    }
    
    struct Container<Content: View>: View {
        var arrowSide: ArrowSide?
        var arrowAlignment: ArrowAlignment?
        
        var cornerRadius = CGFloat(12)
        var backgroundColor = Color(uiColor: .systemBackground) 
        var padding = CGFloat(16)
        
        @ViewBuilder var view: Content
        
        var body: some View {
            PopoverReader { context in
                view
                    .padding(padding)
                    .background(
                        BackgroundWithArrow(
                            arrowSide: arrowSide ?? getArrowPosition(attributes: context.attributes).0,
                            arrowAlignment: arrowAlignment ?? getArrowPosition(attributes: context.attributes).1,
                            cornerRadius: cornerRadius
                        )
                            .fill(backgroundColor)
                            .shadow(
                                color: Color(uiColor: .label.withAlphaComponent(0.25)),
                                radius: 40,
                                x: 0,
                                y: 4
                            )
                    )
            }
        }
        
        /// which side of the popover should the arrow be on
        func getArrowPosition(attributes: Popover.Attributes) -> (ArrowSide, ArrowAlignment) {
            if case let .absolute(originAnchor, popoverAnchor) = attributes.position {
                
                /// X = popover
                switch originAnchor {
                case .topLeft:
                    /// X ------------
                    /// | source frame
                    /// | 
                    switch popoverAnchor {
                    case .topRight:
                        return (.right, .mostCounterClockwise)
                    case .right:
                        return (.right, .centered)
                    case .bottomLeft:
                        return (.bottom, .mostClockwise)
                    case .bottom:
                        return (.bottom, .centered)
                    default:
                        break
                    }
                case .top:
                    ///   ------X------
                    /// | source frame  |
                    /// |               |
                    switch popoverAnchor {
                    case .bottomRight:
                        return (.bottom, .mostCounterClockwise)
                    case .bottom:
                        return (.bottom, .centered)
                    case .bottomLeft:
                        return (.bottom, .mostClockwise)
                    default:
                        break
                    }
                case .topRight:
                    ///  ------------- X
                    ///   source frame |
                    ///                |  
                    switch popoverAnchor {
                    case .bottomRight:
                        return (.bottom, .mostCounterClockwise)
                    case .bottom:
                        return (.bottom, .centered)
                    case .left:
                        return (.left, .centered)
                    case .topLeft:
                        return (.left, .mostClockwise)
                    default:
                        break
                    }
                case .right:
                    ///  ------------- |
                    ///  source frame  X
                    ///  ______________|
                    switch popoverAnchor {
                    case .bottomLeft:
                        return (.left, .mostCounterClockwise)
                    case .left:
                        return (.left, .centered)
                    case .topLeft:
                        return (.left, .mostClockwise)
                    default:
                        break
                    }
                case .bottomRight:
                    ///                 |
                    ///  source frame   |
                    ///  ______________ X  
                    switch popoverAnchor {
                    case .bottomLeft:
                        return (.left, .mostCounterClockwise)
                    case .left:
                        return (.left, .centered)
                    case .top:
                        return (.top, .centered)
                    case .topRight:
                        return (.top, .mostClockwise)
                    default:
                        break
                    }
                case .bottom:
                    ///  |               |
                    ///  |  source frame |
                    ///  |_______X_______|   
                    switch popoverAnchor {
                    case .topRight:
                        return (.top, .mostCounterClockwise)
                    case .top:
                        return (.top, .centered)
                    case .topLeft:
                        return (.top, .mostClockwise)
                    default:
                        break
                    }
                case .bottomLeft:
                    ///  |              
                    ///  | source frame 
                    ///  X ______________  
                    switch popoverAnchor {
                    case .topLeft:
                        return (.top, .mostCounterClockwise)
                    case .top:
                        return (.top, .centered)
                    case .right:
                        return (.right, .centered)
                    case .bottomRight:
                        return (.top, .mostClockwise)
                    default:
                        break
                    }
                case .left:
                    ///  |--------------
                    ///  X  source frame  
                    ///  |______________ 
                    switch popoverAnchor {
                    case .topRight:
                        return (.right, .mostCounterClockwise)
                    case .right:
                        return (.right, .centered)
                    case .bottomRight:
                        return (.right, .mostClockwise)
                    default:
                        break
                    }
                case .center:
                    break
                }
            }
            
            /// no arrow
            return (.top, .centered)
        }
        
    }
    
    struct BackgroundWithArrow: Shape {
        var arrowSide: ArrowSide
        var arrowAlignment: ArrowAlignment
        var cornerRadius: CGFloat
        
        /// you can customize these
        static var width = CGFloat(48)
        static var height = CGFloat(12)
        static var tipCornerRadius = CGFloat(4)
        static var edgeCornerRadius = CGFloat(10)
        static var triangleSidePadding = CGFloat(28)
        
        func trianglePath() -> Path {
            let triangleHalfWidth = (BackgroundWithArrow.width / 2) * 0.6
            
            let trianglePath = Path { path in
                let triangleRect = CGRect(x: 0, y: 0, width: BackgroundWithArrow.width, height: BackgroundWithArrow.height)
                
                path.move(to: CGPoint(x: triangleRect.minX, y: triangleRect.maxY))
                path.addArc(
                    tangent1End: CGPoint(x: triangleRect.midX - triangleHalfWidth, y: triangleRect.maxY),
                    tangent2End: CGPoint(x: triangleRect.midX, y: triangleRect.minX),
                    radius: BackgroundWithArrow.edgeCornerRadius
                )
                path.addArc(
                    tangent1End: CGPoint(x: triangleRect.midX, y: triangleRect.minX),
                    tangent2End: CGPoint(x: triangleRect.midX + triangleHalfWidth, y: triangleRect.maxY),
                    radius: BackgroundWithArrow.tipCornerRadius
                )
                path.addArc(
                    tangent1End: CGPoint(x: triangleRect.midX + triangleHalfWidth, y: triangleRect.maxY),
                    tangent2End: CGPoint(x: triangleRect.maxX, y: triangleRect.maxY),
                    radius: BackgroundWithArrow.edgeCornerRadius
                )
                path.addLine(to: CGPoint(x: triangleRect.maxX, y: triangleRect.maxY))
            }
            return trianglePath
        }
        func path(in rect: CGRect) -> Path {
            
            var trianglePath = trianglePath()
            trianglePath = trianglePath.applying(
                .init(translationX: -(BackgroundWithArrow.width / 2), y: -(BackgroundWithArrow.height))
            )
            
            var path = Path()
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
            
            /// rotation transform to make the triangle hit a different side
            let triangleTransform: CGAffineTransform
            
            /// half of the rectangle's smallest side length, for the triangle's alignment
            let popoverRadius: CGFloat
            
            switch arrowSide {
            case .top:
                triangleTransform = .init(translationX: rect.midX, y: 0)
                popoverRadius = (rect.width / 2) - BackgroundWithArrow.triangleSidePadding
            case .right:
                triangleTransform = .init(rotationAngle: 90.degreesToRadians)
                    .translatedBy(x: rect.midY, y: -rect.maxX)
                popoverRadius = (rect.height / 2) - BackgroundWithArrow.triangleSidePadding
            case .bottom:           
                triangleTransform = .init(rotationAngle: 180.degreesToRadians)
                    .translatedBy(x: -rect.midX, y: -rect.maxY)
                popoverRadius = (rect.width / 2) - BackgroundWithArrow.triangleSidePadding
            case .left:
                triangleTransform = .init(rotationAngle: 270.degreesToRadians)
                    .translatedBy(x: -rect.midY, y: 0)
                popoverRadius = (rect.height / 2) - BackgroundWithArrow.triangleSidePadding
            }
            
            switch arrowAlignment {
            case .mostCounterClockwise:
                trianglePath = trianglePath.applying(
                    .init(translationX: -popoverRadius, y: 0)
                )
            case .centered:
                break
            case .mostClockwise:
                trianglePath = trianglePath.applying(
                    .init(translationX: popoverRadius, y: 0)
                )
            }

            path.addPath(trianglePath, transform: triangleTransform)
            
            return path
            
        }
    }
    
    struct CurveConnector: Shape {
        var start: CGPoint
        var end: CGPoint
        var steepness = CGFloat(0.3) 
        var direction = Direction.vertical
        
        enum Direction {
            case horizontal
            case vertical
        }
        
        /// from https://www.objc.io/blog/2020/03/10/swiftui-path-animations/
        var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
            get { AnimatablePair(start.animatableData, end.animatableData) }
            set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
        }
        
        func path(in rect: CGRect) -> Path {
            
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
    
}



