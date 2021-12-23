import SwiftUI
import Popovers

struct NestedView: View {
    @State var present = false
    
    var body: some View {
        ExampleRow(
            image: "pip",
            title: "Nested",
            color: 0x0081E8
        ) {
            present.toggle()
        }
        .popover(present: $present) {
            NestedViewPopover()
        }
    }
}

struct NestedViewPopover: View {
    @State var present = false
    
    var body: some View {
        Button {
            present = true
        } label: {
            Text("You can stack popovers! Press me.")
                .foregroundColor(Color(uiColor: UIColor(hex: 0x0081E8)))
                .padding()
                .background(.background)
                .cornerRadius(12)
                .shadow(radius: 1)
                .popover(
                    present: $present,
                    attributes: {
                        $0.sourceFrameInset = UIEdgeInsets(top: 0, left: 0, bottom: -12, right: -12)
                    }
                ) {
                    NestedViewPopover()
                }
        }
        
    }
}
