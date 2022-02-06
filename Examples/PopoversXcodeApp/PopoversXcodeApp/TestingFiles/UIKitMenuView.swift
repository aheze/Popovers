//
//  UIKitMenuView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 2/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class UIKitMenuViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .blue
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
