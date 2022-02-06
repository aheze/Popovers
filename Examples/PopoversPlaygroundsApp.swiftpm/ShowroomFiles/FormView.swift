import Popovers
import SwiftUI

struct FormView: View {
    @State var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0xCE0061)) {
                HStack {
                    ExampleImage("pencil", color: UIColor(hex: 0xCE0061))

                    Text("Form Validation")
                        .fontWeight(.medium)
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            FormPopoversExample()
        }
    }
}

private struct FormPopoversExample: View {
    @State var isPopoverPresented = false
    @State var username: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Username", text: $username, prompt: Text("Username"))
                        .warningAccessory($username, warning: "Username must be more than 6 characters")
                } footer: {
                    Text("Use popovers to warn of transient validation problems while allowing the control to maintain focus.")
                }
            }
            .navigationTitle("Form Validation Popover")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

public extension View {
    func warningAccessory(_ text: Binding<String>, warning: String) -> some View {
        modifier(WarningAccessoryModifier(text: text, warning: warning))
    }
}

private struct WarningAccessoryModifier: ViewModifier {
    @Binding var text: String
    let warning: String
    @State var present = false

    func body(content: Content) -> some View {
        HStack {
            content
                .popover(
                    present: $present,
                    attributes: {
                        $0.accessibility.shiftFocus = false
                        $0.sourceFrameInset.bottom = -26
                    }
                ) {
                    if let warning = warning {
                        Templates.Container {
                            Text(warning)
                                .font(.caption)
                        }
                    }
                }

            if text.count < 6 {
                Button {
                    present = true
                } label: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: text) { _ in
            if text.count < 6 {
                present = true
            } else {
                present = false
            }
        }
    }
}
