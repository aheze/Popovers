import SwiftUI
import Popovers

struct Playground: View {
    var body: some View {
        Section(
            header:
                Text("Playground")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        ) {
            Group {
                BasicView()
                CustomizedView()
                AbsolutePositioningView()
                RelativePositioningView()
                LifecycleView()
            }
            Group {
                DismissalView1()
                DismissalView2()
                FrameTaggedView()
                BackgroundView()
                PopoverReaderView()
            }
            
            Group {
                NestedView()
                SelectionView()
            }
        }
    }
}
