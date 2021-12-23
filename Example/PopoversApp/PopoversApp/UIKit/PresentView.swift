import SwiftUI
import Popovers

struct PresentView: View {
    @State var present = false
    
    var body: some View {
        Button {
            present = true
        } label: {
            ExampleUIKitRow(color: UIColor(hex: 0x007EEF)) {
                HStack {
                    ExampleImage("rectangle.portrait", color: UIColor(hex: 0x007EEF))
                    
                    Text("Present")
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
            PresentViewControllerRepresentable()
                .cornerRadius(16)
                .popoverContainerShadow()
                .frame(maxWidth: 600, maxHeight: 300)
        }
    }
}

class PresentViewController: UIViewController {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = """
            Everything is the same as in SwiftUI, except:
        
            1. You need to manually present the popover
                >    Popovers.present(popover)
            2. You need to supply a source frame
                >    attributes.sourceFrame = { yourView.windowFrame() }
        """
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present Popover", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
        
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
    
    @objc func buttonPressed() {
        var attributes = Popover.Attributes()
        attributes.rubberBandingMode = .yAxis
        attributes.sourceFrame = { [weak self] in
            self?.button.windowFrame() ?? .zero
        }
        
        let popover = Popover(attributes: attributes) {
            PresentViewPopoverRepresentable()
                .frame(maxWidth: 200, maxHeight: 100)
        }
        
        Popovers.present(popover)
    }
}

class PresentViewPopover: UIView {
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
        backgroundColor = .systemBlue
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
struct PresentViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PresentViewController {
        return PresentViewController()
    }
    
    func updateUIViewController(_ uiViewController: PresentViewController, context: Context) {
        
    }
}
struct PresentViewPopoverRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> PresentViewPopover {
        return PresentViewPopover()
    }
    
    func updateUIView(_ uiView: PresentViewPopover, context: Context) {
        
    }
}
