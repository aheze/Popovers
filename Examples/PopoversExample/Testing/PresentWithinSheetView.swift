import Popovers
import SwiftUI
import UIKit

struct PresentWithinSheetView: View {
    @State var present = false

    var body: some View {
        NavigationLink(destination: PresentWithinSheetDestinationView()) {
            ExampleTestingRow(
                image: "rectangle.stack",
                title: "Popover From Sheet",
                color: 0xff0071
            )
        }
    }
}

struct PresentWithinSheetDestinationView: View {
    @State var present = false
    var body: some View {
        Button {
            present = true
        } label: {
            Text("Present Sheet")
        }
        .sheet(isPresented: $present) {
            NavigationView {
                PresentWithinSheetDestinationSheetView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PresentWithinSheetDestinationSheetView: View {
    @State var isPopoverPresented = false

    var body: some View {
        VStack {
            Text("Popovers can be shown from view controllers presented as sheets.")
            Button {
                isPopoverPresented = true
            } label: {
                Text("Present Popover")
            }
        }
        .navigationTitle("Popovers inside presented sheet")
        .navigationBarTitleDisplayMode(.inline)
        .popover(
            present: $isPopoverPresented,
            attributes: {
                $0.sourceFrameInset.bottom = -20
            }
        ) {
            Templates.Container {
                VStack(spacing: 16) {
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
