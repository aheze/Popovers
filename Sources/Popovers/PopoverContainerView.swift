//
//  PopoverContainerView.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct PopoverContainerView: View {
    @ObservedObject var popoverModel: PopoverModel
    @State var selectedPopover: Popover? = nil
    @State var selectedPopoverOffset: CGSize = .zero
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            ForEach(Array(zip(popoverModel.popovers.indices, popoverModel.popovers)), id: \.1.id) { (index, popover) in
                
                popover.background
                
                popover.view
                    .opacity(popover.context.size != nil ? 1 : 0)
                    .transition(
                        .asymmetric(
                            insertion: popover.attributes.presentation.transition ?? .opacity,
                            removal: popover.attributes.dismissal.transition ?? .opacity
                        )
                    ) 
                    .frameReader { rect in
                        if let transaction = popover.context.transaction {
                            
                            /// when `popover.context.size` is nil, the popover was just presented
                            if popover.context.size == nil {
                                popover.setSize(rect.size)
                                Popovers.refresh(with: transaction)
                            } else {
                                /// otherwise, the popover is *replacing* a previous popover, so animate it
                                withTransaction(transaction) {
                                    popover.setSize(rect.size)
                                    Popovers.refresh(with: transaction)
                                }
                            }
                            popover.context.transaction = nil
                        }
                    }
                    .offset(popoverOffset(for: popover))
                    .simultaneousGesture(
                        
                        /// 1 is enough to allow scroll views to scroll, if one is contained in the popover
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                
                                if selectedPopover == nil {
                                    DispatchQueue.main.async {
                                        selectedPopover = popover
                                    }
                                }
                                
                                applyDraggingOffset(popover: popover, translation: value.translation)
                                
                                popover.context.frame = CGRect(
                                    origin: popover.context.staticFrame.origin + CGPoint(
                                        x: selectedPopoverOffset.width,
                                        y: selectedPopoverOffset.height
                                    ), 
                                    size: popover.context.size ?? .zero
                                )
                            }
                            .onEnded { value in
                                
                                /// recalculate the positioning
                                let finalOrigin = CGPoint(
                                    x: popover.context.staticFrame.origin.x + value.predictedEndTranslation.width,
                                    y: popover.context.staticFrame.origin.y + value.predictedEndTranslation.height
                                )
                                
                                /// if there is a dismissal animation, use it. Otherwise the popover is not dismissed.
                                withAnimation(.spring()) {
                                    selectedPopoverOffset = .zero
                                    popover.positionChanged(to: finalOrigin)
                                    popover.context.frame = popover.context.staticFrame
                                }
                                self.selectedPopover = nil
                            }
                        , including: !popover.attributes.rubberBandingMode.isEmpty
                        ? (popoverModel.popoversDraggable ? .all : .subviews)
                        : .subviews /// stop gesture if dragging is not enabled
                    )
                    .padding(edgeInsets(for: popover))
            }
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    /// apply edge padding ONLY to bottom and right - top and left are set via the frame origin (in Popover.swift)
    func edgeInsets(for popover: Popover) -> EdgeInsets {
        let horizontalInsets = popover.attributes.screenEdgePadding.left + popover.attributes.screenEdgePadding.right
        let verticalInsets = popover.attributes.screenEdgePadding.top + popover.attributes.screenEdgePadding.bottom 
        
        return EdgeInsets(
            top: 0,
            leading: 0,
            bottom: verticalInsets,
            trailing: horizontalInsets
        )
    }
    
    /// get the offset of a popover in order to place it in its correct location
    func popoverOffset(for popover: Popover) -> CGSize {
        guard popover.context.size != nil else { return .zero }
        let frame = popover.context.staticFrame
        let offset = CGSize(
            width: frame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0),
            height: frame.origin.y + ((selectedPopover == popover) ? selectedPopoverOffset.height : 0)
        )
        return offset
    }
    
    
    // MARK: - Dragging
    func applyDraggingOffset(popover: Popover, translation: CGSize) {
        func applyVerticalOffset(dragDown: Bool) {
            let condition = dragDown ? translation.height <= 0 : translation.height >= 0 
            if condition {
                selectedPopoverOffset.height = getRubberBanding(translation: translation).height
            } else {
                selectedPopoverOffset.height = translation.height
            }
        }
        switch popover.attributes.position {
        case .absolute(_, _):
            if popover.attributes.dismissal.mode.contains(.dragDown) {
                applyVerticalOffset(dragDown: true)
            } else if popover.attributes.dismissal.mode.contains(.dragUp) {
                applyVerticalOffset(dragDown: false)
            } else {
                selectedPopoverOffset = applyRubberBanding(to: popover, translation: translation)
            }
        case .relative(let popoverAnchors):
            if popoverAnchors.count <= 1 {
                if popover.attributes.dismissal.mode.contains(.dragDown) {
                    applyVerticalOffset(dragDown: true)
                } else if popover.attributes.dismissal.mode.contains(.dragUp) {
                    applyVerticalOffset(dragDown: false)
                } else {
                    selectedPopoverOffset = applyRubberBanding(to: popover, translation: translation)
                }
            } else {
                selectedPopoverOffset = translation
            }
        }
    }
    
    /// make dragging offset a bit smaller
    func getRubberBanding(translation: CGSize) -> CGSize {
        var offset = CGSize.zero
        offset.width = pow(abs(translation.width), PopoverConstants.rubberBandingPower) * (translation.width > 0 ? 1 : -1)
        offset.height = pow(abs(translation.height), PopoverConstants.rubberBandingPower) * (translation.height > 0 ? 1 : -1)
        return offset
    }
    
    /// apply rubber banding to the selected popover's offset
    func applyRubberBanding(to popover: Popover, translation: CGSize) -> CGSize {
        let offset = getRubberBanding(translation: translation)
        var selectedPopoverOffset = CGSize.zero
        
        if popover.attributes.rubberBandingMode.contains(.xAxis) {
            selectedPopoverOffset.width = offset.width
        }
        if popover.attributes.rubberBandingMode.contains(.yAxis) {
            selectedPopoverOffset.height = offset.height
        }
        return selectedPopoverOffset
    }
}
