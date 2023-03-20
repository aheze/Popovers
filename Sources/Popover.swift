//
//  Popover.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
#if os(iOS)
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
     Convenience accessor for the popover's ID.
     */
    public var id: UUID {
        get {
            context.id
        } set {
            context.id = newValue
        }
    }

    /// Convenience accessor for the popover's attributes.
    public var attributes: Attributes {
        get {
            context.attributes
        } set {
            context.attributes = newValue
        }
    }

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
}

extension Popover: Equatable {
    /// Conform to equatable.
    public static func == (lhs: Popover, rhs: Popover) -> Bool {
        return lhs.id == rhs.id
    }
}
#endif
