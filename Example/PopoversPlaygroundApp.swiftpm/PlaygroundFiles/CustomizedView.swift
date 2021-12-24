import SwiftUI
import Popovers

struct CustomizedView: View {
    @State var present = false
    
    var body: some View {
        ExampleRow(
            image: "slider.horizontal.3",
            title: "Customized",
            color: 0x285FF5
        ) {
            present.toggle()
        }
        .popover(
            present: $present,
            attributes: {
                $0.rubberBandingMode = .yAxis
            }
        ) {
            VStack(alignment: .leading) {
                Text("You can customize popovers by providing attributes.")
                
                HStack {
                    ExampleImage("hand.draw", color: 0x285FF5)
                    Text("For this popover, rubber banding is only enabled on the y-axis.")
                }
            }
                .padding()
                .background(.background)
                .cornerRadius(12)
                .shadow(radius: 1)
                .frame(maxWidth: 300)
        }
    }
}
