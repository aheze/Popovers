import SwiftUI
import Combine 

struct PopoverModifier: ViewModifier {
    @Binding var isPresented: Bool
    let buildAttributes: ((inout Popover.Attributes) -> Void)
    let view: AnyView
    let background: AnyView

    @State var popover: Popover?
    @State var sourceFrame: CGRect?
    
    init<Content: View>(
        isPresented: Binding<Bool>,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        self.background = AnyView(Color.clear)
    }
    
    init<MainContent: View, BackgroundContent: View>(
        isPresented: Binding<Bool>,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) {
        self._isPresented = isPresented
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        self.background = AnyView(background())
    }
    
    func body(content: Content) -> some View {
        content
            .frameReader { rect in
                sourceFrame = rect
            }
            .onDataChange(of: isPresented) { (_, newValue) in
                
                if newValue {
                    var attributes = Popover.Attributes()
                    attributes.sourceFrame = {
                        if case .absolute(_, _) = attributes.position {
                            return sourceFrame ?? .zero
                        } else {
                            return Popovers.safeWindowFrame
                        }
                    }

                    buildAttributes(&attributes)
                    
                    let popover = Popover(
                        attributes: attributes,
                        view: { view },
                        background: { background }
                    )
                    
                    popover.context.dismissed = {
                        isPresented = false
                    }
                    
                    self.popover = popover
                    Popovers.present(popover)
                } else {
                    if let popover = popover {
                        Popovers.dismiss(popover)
                    }
                }
            }
    }
}

struct MultiPopoverModifier: ViewModifier {
    @Binding var selection: String?
    let tag: String
    let buildAttributes: ((inout Popover.Attributes) -> Void)
    let view: AnyView
    let background: AnyView
    
    @State var popover: Popover?
    @State var sourceFrame: CGRect?
    
    init<Content: View>(        
        selection: Binding<String?>,
        tag: String,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void),
        @ViewBuilder view: @escaping () -> Content
    ) {
        self._selection = selection
        self.tag = tag
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        self.background = AnyView(Color.clear)
    }
    
    init<MainContent: View, BackgroundContent: View>(
        selection: Binding<String?>,
        tag: String,
        buildAttributes: @escaping ((inout Popover.Attributes) -> Void),
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) {
        self._selection = selection
        self.tag = tag
        self.buildAttributes = buildAttributes
        self.view = AnyView(view())
        self.background = AnyView(background())
    }
    
    func body(content: Content) -> some View {
        content
            .frameReader { rect in
                Popovers.model.selectionFrameTags[tag] = rect
                sourceFrame = rect
            }
            .onDataChange(of: selection) { (selection, newSelection) in
                
                guard newSelection != nil else {
                    if let popover = popover {
                        Popovers.dismiss(popover)
                    }
                    return
                }
                
                /// new selection is this popover
                if newSelection == tag {
                    var attributes = Popover.Attributes()
                    attributes.tag = tag
                    attributes.dismissal.excludedFrames = { Array(Popovers.model.selectionFrameTags.values) }                    
                    attributes.sourceFrame = {
                        if case .absolute(_, _) = attributes.position {
                            return sourceFrame ?? .zero
                        } else {
                            return Popovers.safeWindowFrame
                        }
                    }
                    buildAttributes(&attributes)
                    
                    let popover = Popover(
                        attributes: attributes,
                        view: { view },
                        background: { background }
                    )
                    popover.context.dismissed = {
                        self.selection = nil
                    }
                    self.popover = popover
                    
                    /// old selection with same tag exists
                    if let oldSelection = selection, let oldPopover = Popovers.popover(tagged: oldSelection) {
                        Popovers.replace(oldPopover, with: popover)
                    } else {
                        Popovers.present(popover)
                    }
                    
                } else if selection == nil {
                    /// previously there was no selection - this current popover is the only one
                    if let oldPopover = popover {
                        Popovers.dismiss(oldPopover)
                    }
                } 
            }
    }
}

public extension View {
    
    /**
     Popover for SwiftUI
     */
    func popover<Content: View>(
        present: Binding<Bool>,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> Content
    ) -> some View {
        return self
            .modifier(
                PopoverModifier(
                    isPresented: present,
                    buildAttributes: buildAttributes,
                    view: view
                )
            )
    }
    
    /**
     Popover for SwiftUI with background
     */
    func popover<MainContent: View, BackgroundContent: View>(
        present: Binding<Bool>,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) -> some View {
        return self
            .modifier(
                PopoverModifier(
                    isPresented: present,
                    buildAttributes: buildAttributes,
                    view: view,
                    background: background
                )
            )
    }
    
    /**
     For presenting multiple popovers
     */
    func popover<Content: View>(
        selection: Binding<String?>,
        tag: String,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> Content
    ) -> some View {
        return self
            .modifier(
                MultiPopoverModifier(
                    selection: selection, 
                    tag: tag,
                    buildAttributes: buildAttributes, 
                    view: view
                )
            )
    }
    
    func popover<MainContent: View, BackgroundContent: View>(
        selection: Binding<String?>,
        tag: String,
        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
        @ViewBuilder view: @escaping () -> MainContent,
        @ViewBuilder background: @escaping () -> BackgroundContent
    ) -> some View {
        return self
            .modifier(
                MultiPopoverModifier(
                    selection: selection, 
                    tag: tag,
                    buildAttributes: buildAttributes, 
                    view: view,
                    background: background
                )
            )
    }
}

struct ChangeObserver<Content: View, Value: Equatable>: View {
    let content: Content
    let value: Value
    let action: (Value, Value) -> Void

    init(value: Value, action: @escaping (Value, Value) -> Void, content: @escaping () -> Content) {
        self.value = value
        self.action = action
        self.content = content()
        _oldValue = State(initialValue: value)
    }

    @State private var oldValue: Value

    var body: some View {
        if oldValue != value {
            DispatchQueue.main.async {
                self.action(oldValue, value)
                oldValue = value
            }
        }
        return content
    }
}

extension View {
    /// fallback of `.onChange` for iOS 13+
    public func onDataChange<Value: Equatable>(
        of value: Value,
        perform action: @escaping (_ oldValue: Value, _ newValue: Value) -> Void
    ) -> some View {
        ChangeObserver(value: value, action: action) {
            self
        }
    }
}
