import Popovers
import SwiftUI
import UIKit

struct PresentWithinSheet: View {
    @State var present = false

    var body: some View {
        Button {
            present = true
        } label: {
            ExampleUIKitRow(color: UIColor(hex: 0x6900EF)) {
                HStack {
                    ExampleImage("rectangle.stack", color: UIColor(hex: 0x7106AD))

                    Text("Popover from Sheet")
                        .fontWeight(.medium)
                }
            }
        }
        .sheet(isPresented: $present) {
            NavigationView {
                PresentWithinSheetView()
            }
        }
    }

    struct PresentWithinSheetView: View {
        @State var isPopoverPresented = false

        var body: some View {
            VStack {
                Text("Popovers can even be shown from view controllers presented as sheets.")
                Button {
                    isPopoverPresented = true
                } label: {
                    Text("Present Popover")
                }
            }
            .navigationTitle("Popovers inside presented sheet")
            .navigationBarTitleDisplayMode(.inline)
            .popover(present: $isPopoverPresented) {
                Templates.Container {
                    VStack {
                        Text("Popover inside a sheet!")

                        Button {
                            isPopoverPresented = false
                        } label: {
                            Text("Tap to dismiss")
                        }
                    }
                }
            }
        }
    }
}
