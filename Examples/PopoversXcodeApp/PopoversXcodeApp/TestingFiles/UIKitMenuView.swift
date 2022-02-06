//
//  UIKitMenuView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 2/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

class UIKitMenuViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Present Menu"
        return label
    }()

    lazy var labelMenu = Templates.UIKitMenu(sourceView: label) {
        Templates.MenuButton(title: "Change Icon To List", systemImage: "list.bullet") {
//                iconName = "list.bullet"
        }
        Templates.MenuButton(title: "Change Icon To Keyboard", systemImage: "keyboard") {
//                iconName = "keyboard"
        }
        Templates.MenuButton(title: "Change Icon To Bag", systemImage: "bag") {
//                iconName = "bag"
        }
    }

    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        _ = labelMenu
//        self.labelMenu = labelMenu
    }
}

struct UIKitMenuView: View {
    var body: some View {
        NavigationLink(
            destination: UIKitMenuViewRepresentable()
                .navigationBarTitleDisplayMode(.inline)
        ) {
            ExampleTestingRow(
                image: "contextualmenu.and.cursorarrow",
                title: "UIKit Menu",
                color: 0xff4000
            )
        }
    }
}

struct UIKitMenuViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitMenuViewController {
        let viewController = UIKitMenuViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIKitMenuViewController, context: Context) {}
}
