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
            .onChange(of: isPresented) { newValue in
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
            .onChange(of: selection) { [selection] newSelection in
                
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

extension View {
    
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

/// from https://stackoverflow.com/a/62523475/14351818
/// See `View.onChange(of: value, perform: action)` for more information
//struct ChangeObserver<Base: View, Value: Equatable>: View {
//    let base: Base
//    let value: Value
//    let action: (Value)->Void
//    
//    let model = Model()
//    
//    var body: some View {
//        if model.update(value: value) {
//            DispatchQueue.main.async { self.action(self.value) }
//        }
//        return base
//    }
//    
//    class Model {
//        private var savedValue: Value?
//        func update(value: Value) -> Bool {
//            guard value != savedValue else { return false }
//            savedValue = value
//            return true
//        }
//    }
//}
//
//extension View {
//    /// Adds a modifier for this view that fires an action when a specific value changes.
//    ///
//    /// You can use `onChange` to trigger a side effect as the result of a value changing, such as an Environment key or a Binding.
//    ///
//    /// `onChange` is called on the main thread. Avoid performing long-running tasks on the main thread. If you need to perform a long-running task in response to value changing, you should dispatch to a background queue.
//    ///
//    /// The new value is passed into the closure. The previous value may be captured by the closure to compare it to the new value. For example, in the following code example, PlayerView passes both the old and new values to the model.
//    ///
//    /// ```
//    /// struct PlayerView : View {
//    ///   var episode: Episode
//    ///   @State private var playState: PlayState
//    ///
//    ///   var body: some View {
//    ///     VStack {
//    ///       Text(episode.title)
//    ///       Text(episode.showTitle)
//    ///       PlayButton(playState: $playState)
//    ///     }
//    ///   }
//    ///   .onChange(of: playState) { [playState] newState in
//    ///     model.playStateDidChange(from: playState, to: newState)
//    ///   }
//    /// }
//    /// ```
//    ///
//    /// - Parameters:
//    ///   - value: The value to check against when determining whether to run the closure.
//    ///   - action: A closure to run when the value changes.
//    ///   - newValue: The new value that failed the comparison check.
//    /// - Returns: A modified version of this view
//    func onChange<Value: Equatable>(_ value: Value, perform action: @escaping (_ newValue: Value)->Void) -> ChangeObserver<Self, Value> {
//        ChangeObserver(base: self, value: value, action: action)
//    }
//}
