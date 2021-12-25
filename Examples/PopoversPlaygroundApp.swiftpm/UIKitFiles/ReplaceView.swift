//
//  ReplaceView.swift
//  PopoversPlaygroundApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI
import Popovers

struct ReplaceView: View {
    @State var present = false
    
    var body: some View {
        Button {
            present = true
        } label: {
            ExampleUIKitRow(color: UIColor(hex: 0x0018EF)) {
                HStack {
                    ExampleImage("arrow.triangle.2.circlepath", color: UIColor(hex: 0x0018EF))
                    
                    Text("Replace")
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
                        .center
                    ]
                )
            }
        ) {
            ReplaceViewControllerRepresentable()
                .cornerRadius(16)
                .popoverContainerShadow()
                .frame(maxWidth: 600, maxHeight: 300)
        }
    }
}

class ReplaceViewController: UIViewController {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = """
            This is what the "$selection + tag" popover in SwiftUI uses under the hood.
        
            1. Get the currently presented popover
                >    if let oldPopover = Popovers.popover(tagged: "A Popover") {
            2. Replace it
                >    Popovers.replace(oldPopover, with: newPopover)
        """
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    lazy var button1: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present Popover 1", for: .normal)
        button.addTarget(self, action: #selector(button1Pressed), for: .touchUpInside)
        return button
    }()
    lazy var button2: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present Popover 2", for: .normal)
        button.addTarget(self, action: #selector(button2Pressed), for: .touchUpInside)
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
        horizontalStackView.addArrangedSubview(button1)
        horizontalStackView.addArrangedSubview(button2)
        
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
    
    @objc func button1Pressed() {
        var attributes = Popover.Attributes()
        attributes.tag = "A Popover"
        attributes.sourceFrame = { [weak self] in
            let button1 = self?.button1
            return button1.windowFrame()
        }
        
        let newPopover = Popover(attributes: attributes) {
            ReplaceViewPopoverRepresentable()
                .frame(maxWidth: 200, maxHeight: 100)
        }
        if let oldPopover = Popovers.popover(tagged: "A Popover") {
            /// popover exists, replace it
            Popovers.replace(oldPopover, with: newPopover)
        } else {
            /// popover doesn't exist, present
            Popovers.present(newPopover)
        }
    }
    
    @objc func button2Pressed() {
        var attributes = Popover.Attributes()
        attributes.tag = "A Popover"
        attributes.sourceFrame = { [weak self] in
            let button2 = self?.button2
            return button2.windowFrame()
        }
        
        let newPopover = Popover(attributes: attributes) {
            ReplaceViewPopoverRepresentable()
                .frame(maxWidth: 200, maxHeight: 100)
        }
        if let oldPopover = Popovers.popover(tagged: "A Popover") {
            /// popover exists, replace it
            Popovers.replace(oldPopover, with: newPopover)
        } else {
            /// popover doesn't exist, present
            Popovers.present(newPopover)
        }
    }
}

class ReplaceViewPopover: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func commonInit() {
        backgroundColor = .systemGreen
        layer.cornerRadius = 16
        
        let label = UILabel()
        label.textColor = .white
        label.text = "Hello! I'm a popover."
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
struct ReplaceViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ReplaceViewController {
        return ReplaceViewController()
    }
    
    func updateUIViewController(_ uiViewController: ReplaceViewController, context: Context) {
        
    }
}
struct ReplaceViewPopoverRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ReplaceViewPopover {
        return ReplaceViewPopover()
    }
    
    func updateUIView(_ uiView: ReplaceViewPopover, context: Context) {
        
    }
}

