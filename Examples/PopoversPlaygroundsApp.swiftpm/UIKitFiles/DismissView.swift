//
//  DismissView.swift
//  PopoversXcodeApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct DismissView: View {
    @State var present = false

    var body: some View {
        Button {
            present = true
        } label: {
            ExampleUIKitRow(color: UIColor(hex: 0x6900EF)) {
                HStack {
                    ExampleImage("xmark", color: UIColor(hex: 0x6900EF))

                    Text("Dismiss")
                        .fontWeight(.medium)
                }
            }
        }
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset.top = -8
                $0.position = .relative(
                    popoverAnchors: [
                        .center,
                    ]
                )
            }
        ) {
            DismissViewControllerRepresentable()
                .cornerRadius(16)
                .popoverContainerShadow()
                .frame(maxWidth: 600, maxHeight: 300)
        }
    }
}

class DismissViewController: UIViewController {
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = """
            Super simple.
                >    self.dismiss(popover)
        """
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    lazy var presentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present Popover", for: .normal)
        button.addTarget(self, action: #selector(presentButtonPressed), for: .touchUpInside)
        return button
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss Popover", for: .normal)
        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        return button
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16

        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 16
        horizontalStackView.addArrangedSubview(presentButton)
        horizontalStackView.addArrangedSubview(dismissButton)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(horizontalStackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return stackView
    }()

    override func loadView() {
        super.loadView()

        view = UIView()
        view.backgroundColor = .systemBackground
        _ = stackView
    }

    @objc func presentButtonPressed() {
        var attributes = Popover.Attributes()
        attributes.tag = "Dismissal Popover"
        attributes.sourceFrame = { [weak presentButton] in
            presentButton.windowFrame()
        }

        let popover = Popover(attributes: attributes) {
            DismissViewPopoverRepresentable()
                .frame(maxWidth: 200, maxHeight: 100)
        }

        present(popover)
    }

    @objc func dismissButtonPressed() {
        if let popover = popover(tagged: "Dismissal Popover") {
            dismiss(popover)
        }
    }
}

class DismissViewPopover: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    func commonInit() {
        backgroundColor = .systemRed
        layer.cornerRadius = 16

        let label = UILabel()
        label.textColor = .white
        label.text = "Hello! I'm a popover."
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

struct DismissViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> DismissViewController {
        return DismissViewController()
    }

    func updateUIViewController(_: DismissViewController, context _: Context) {}
}

struct DismissViewPopoverRepresentable: UIViewRepresentable {
    func makeUIView(context _: Context) -> DismissViewPopover {
        return DismissViewPopover()
    }

    func updateUIView(_: DismissViewPopover, context _: Context) {}
}
