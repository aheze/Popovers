//
//  PopoverContainerViewController.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 The View Controller that hosts `PopoverContainerView`. This is automatically managed.
 */
public class PopoverContainerViewController: UIViewController {
    
    /// The popover model to pass down to `PopoverContainerView`.
    public var popoverModel: PopoverModel
    
    /// The window scene to pass down to `PopoverContainerView`.
    public let windowScene: UIWindowScene?
    
    /**
     Create a new `PopoverContainerViewController`. This is automatically managed.
     */
    public init(popoverModel: PopoverModel, windowScene: UIWindowScene?) {
        self.popoverModel = popoverModel
        self.windowScene = windowScene
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Orientation or screen bounds changed. Update popover frames.
        Popovers.updateFrames()
    }
    
    public override func loadView() {
    
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        
        /// Embed `PopoverContainerView` in a view controller.
        let popoverContainerView = PopoverContainerView(
            popoverModel: popoverModel,
            windowScene: windowScene
        )
        let hostingController = UIHostingController(rootView: popoverContainerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
