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

    lazy var labelMenu = Templates.UIKitMenu(
        sourceView: label,
        configuration: {
            var configuration = Templates.MenuConfiguration()
            configuration.excludedFrames = { [weak self] in
                guard let self = self else { return [] }
                return [
                    self.activateButton.windowFrame(),
                ]
            }
            return configuration
        }()
    ) {
        Templates.MenuButton(title: "Change Icon To List", systemImage: "list.bullet") { [weak self] in
            self?.label.text = "Present Menu (List)"
        }
        Templates.MenuButton(title: "Change Icon To Keyboard", systemImage: "keyboard") { [weak self] in
            self?.label.text = "Present Menu (Keyboard)"
        }
        Templates.MenuButton(title: "Change Icon To Bag", systemImage: "bag") { [weak self] in
            self?.label.text = "Present Menu (Bag)"
        }
    }

    lazy var barButtonMenu = Templates.UIKitMenu(
        sourceView: barButton,
        configuration: {
            var configuration = Templates.MenuConfiguration()
            configuration.scaleAnchor = .topRight
            return configuration
        }()
    ) {
        Templates.MenuButton(title: "Change Icon To List", systemImage: "list.bullet") { [weak self] in
            self?.label.text = "Present Menu (List)"
        }
        Templates.MenuButton(title: "Change Icon To Keyboard", systemImage: "keyboard") { [weak self] in
            self?.label.text = "Present Menu (Keyboard)"
        }
        Templates.MenuButton(title: "Change Icon To Bag", systemImage: "bag") { [weak self] in
            self?.label.text = "Present Menu (Bag)"
        }
    }

    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Present Menu"
        return label
    }()

    lazy var activateButton: UIButton = {
        let activateButton = UIButton(type: .system)
        activateButton.setTitle("Activate", for: .normal)
        activateButton.addTarget(self, action: #selector(activateButtonTapped), for: .touchUpInside)
        return activateButton
    }()

    lazy var barButton: UIButton = {
        let barButton = UIButton(type: .system)
        barButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        barButton.addTarget(self, action: #selector(barButtonTapped), for: .touchUpInside)
        return barButton
    }()

    lazy var barButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(customView: barButton)
        navigationItem.rightBarButtonItem = barButtonItem
        return barButtonItem
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.isUserInteractionEnabled = true
        stackView.addArrangedSubview(activateButton)
        stackView.addArrangedSubview(label)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return stackView
    }()

    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .systemBackground

        _ = labelMenu
        _ = barButtonMenu
        _ = stackView
        _ = barButtonItem
    }

    @objc func activateButtonTapped() {
        if labelMenu.isPresented {
            labelMenu.dismiss()
        } else {
            labelMenu.present()
        }
    }

    @objc func barButtonTapped() {
        if barButtonMenu.isPresented {
            barButtonMenu.dismiss()
        } else {
            barButtonMenu.present()
        }
    }
}

struct UIKitMenuView: View {
    var body: some View {
        NavigationLink(
            destination: UIKitMenuViewRepresentable()
                .cornerRadius(10)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
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
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = UIKitMenuViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
