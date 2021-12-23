import SwiftUI
import Popovers

class ColorViewModel: ObservableObject {
    @Published var selectedColor: UIColor = UIColor(hex: 0x00aeef)
    @Published var alpha: CGFloat = 1
}

struct ColorViewConstants {
    static var sliderHeight = CGFloat(40)
    static var cornerRadius = CGFloat(12)
    
    /// padding outside all items
    static var padding = CGFloat(12)
    
    /// space between items
    static var spacing = CGFloat(10)
}

struct ColorView: View {
    @State var present = false
    @StateObject var model = ColorViewModel()
    
    var body: some View {
        Button {
            present = true
        } label: {
            ExampleShowroomRow(color: model.selectedColor.withAlphaComponent(model.alpha)) {
                HStack {
                    ExampleImage("eyedropper", color: model.selectedColor)
                        .opacity(model.alpha)
                    
                    Text("Color Picker")
                        .fontWeight(.medium)
                }
            }
        }
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset.bottom = -8
                $0.position = .absolute(
                    originAnchor: .bottom,
                    popoverAnchor: .top
                )
            }
        ) {
            ColorViewPopover(model: model)
        }
    }
}


struct ColorViewPopover: View {
    @ObservedObject var model: ColorViewModel
    
    var body: some View {
        VStack {
            Text("Choose a color")
                .foregroundColor(.white)
            
            PaletteView(selectedColor: $model.selectedColor)
                .cornerRadius(ColorViewConstants.cornerRadius)
            
            OpacitySlider(value: $model.alpha, color: model.selectedColor)
                .frame(height: ColorViewConstants.sliderHeight)
                .cornerRadius(ColorViewConstants.cornerRadius)
        }
        .padding(12)
        .frame(width: 200)
        .background(
            ZStack {
                PopoverTemplates.VisualEffectView(.systemUltraThinMaterialDark)
                UIColor(hex: 0x0070a3).color.opacity(0.5)
            }
        )
        .cornerRadius(16)
        
    }
}

struct PaletteView: View {
    @Binding var selectedColor: UIColor
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                PaletteButton(color: UIColor(hex: 0xFF0000), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xFFB100), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xFFE600), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x39DD00), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x00AEEF), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x0036FF), selectedColor: $selectedColor)
            }
            .aspectRatio(6, contentMode: .fit)
            
            HStack(spacing: 0) {
                PaletteButton(color: UIColor(hex: 0xFF7700), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xFFD200), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xE4FF43), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x00FF93), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x0091FF), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x7A00FF), selectedColor: $selectedColor)
            }
            .aspectRatio(6, contentMode: .fit)
        }
    }
}

struct PaletteButton: View {
    let color: UIColor
    @Binding var selectedColor: UIColor
    var body: some View {
        Button {
            withAnimation {
                selectedColor = color
            }
        } label: {
            color.color
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1)
                        .opacity(color == selectedColor ? 1 : 0)
                )
        }
    }
}

struct OpacitySlider: View {
    @Binding var value: CGFloat
    let color: UIColor
    
    var body: some View {
        
        GeometryReader { proxy in
            Color(UIColor.systemBackground).overlay(
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<6) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<30) { column in
                                    
                                    let offset = row % 2 == 0 ? 1 : 0
                                    if (offset + column) % 2 == 0 {
                                        Color.clear
                                    } else {
                                        UIColor.label.color.opacity(0.15)
                                    }
                                }
                            }
                            .aspectRatio(30, contentMode: .fill)
                        }
                    }
                    
                    LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing)
                        .colorMultiply(color.color)
                }
            )
            
            /// slider thumb
                .overlay(
                    Color.clear.overlay(
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(UIColor.systemBackground.color)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(color.withAlphaComponent(value).color)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(Color.white, lineWidth: 2)
                        }
                            .padding(6)
                            .frame(width: ColorViewConstants.sliderHeight, height: ColorViewConstants.sliderHeight)
                        
                        /// pin thumb to right of stretching `clear` container
                        , alignment: .trailing
                    )
                    /// set frame of stretching `clear` container
                        .frame(
                            width: ColorViewConstants.sliderHeight + value * (proxy.size.width - ColorViewConstants.sliderHeight)
                        )
                    , alignment: .leading)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            self.value = min(max(0, CGFloat(value.location.x / proxy.size.width)), 1)
                            Popovers.draggingEnabled = false
                        }
                        .onEnded { _ in 
                            Popovers.draggingEnabled = true 
                            
                        }
                )
        }
        .drawingGroup() /// prevent thumb from disappearing when offset to show words
    }
}

