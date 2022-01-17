import Popovers
import SwiftUI

struct FormPopovers: View {
    
    @State var isPresented = false
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            ExampleShowroomRow(color: UIColor(hex: 0x252525)) {
                HStack {
                    ExampleImage("pencil.circle.fill", color: UIColor(hex: 0x252525))

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
    @State var usernameWarning: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Username", text: $username, prompt: Text("Username"))
                        .onChange(of: username) { newValue in
                            usernameWarning = username.isEmpty ? "Username cannot be empty" : nil
                        }
                        .warningAccessory($usernameWarning)
                } footer: {
                    Text("Use popovers to warn of transient validation problems while allowing the control to maintain focus.")
                }
            }
            .navigationTitle("Form Validation Popover")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

extension View {
    
    public func warningAccessory(_ warning: Binding<String?>) -> some View {
        ModifiedContent(content: self, modifier: WarningAccessoryModifier(warning: warning))
    }
    
}

private struct WarningAccessoryModifier: ViewModifier {
    
    @Binding var warning: String?
    @FocusState var isContentFocused
    @State var isPopoverPresented = false
    
    func body(content: Content) -> some View {
        HStack {
            if warning != nil {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Spacer()
            }
            
            content
                .focused($isContentFocused)
                .onChange(of: isContentFocused) { isContentFocused in
                    isPopoverPresented = isContentFocused && warning != nil
                }
                .popover(present: $isPopoverPresented) { (attributes) in
                    attributes.accessibility.shiftFocus = false
                } view: {
                    if let warning = warning {
                        PopoverTemplates.Container {
                            SwiftUI.Text(verbatim: warning)
                                .font(.caption)
                        }
                    }
            }
        }
        .onChange(of: warning) { newValue in
            isPopoverPresented = newValue != nil
        }
    }
    
}
