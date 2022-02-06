![Header Image](Assets/Header.png)

# Popovers
A library to present popovers.

- Present **any** view above your app's main content.
- Attach to source views or use picture-in-picture positioning.
- Display multiple popovers at the same time with smooth transitions.
- Supports SwiftUI, UIKit, and multitasking windows on iPadOS.
- Highly customizable API that's super simple — just add `.popover`.
- Drop-in replacement for iOS 14's `Menu` that works on iOS 13.
- SwiftUI-based core for a lightweight structure. 0 dependencies.
- It's 2022 — about time that popovers got interesting!

## Showroom


<table>

<tr>
<td>
Alert   
</td>
<td>
Color  
</td>
<td>
Menu   
</td>
<td>
Tip      
</td>
<td>
Standard 
</td>
</tr>

<tr>
</tr>
  
<tr>
<td>
<img src="Assets/GIFs/Alert.gif" alt="Alert">
</td>
<td>
<img src="Assets/GIFs/Color.gif" alt="Color">
</td>
<td>
<img src="Assets/GIFs/Menu.gif" alt="Menu">
</td>
<td>
<img src="Assets/GIFs/Tip.gif" alt="Tip">
</td>
<td>
<img src="Assets/GIFs/Standard.gif" alt="Standard">
</td>
</tr>

<tr>
</tr>
  
<tr>
<td colspan=2>
Tutorial
</td>
<td colspan=2>
Picture-in-Picture
</td>
<td>
Notification
</td>
</tr>
  
<tr>
</tr>
  
<tr>
<td colspan=2>
<img src="Assets/GIFs/Tutorial.gif" alt="Tutorial">
</td>
<td colspan=2>
<img src="Assets/GIFs/PIP.gif" alt="Picture in Picture">
</td>
<td>
<img src="Assets/GIFs/Notification.gif" alt="Notification">
</td>
</tr>

</table>

## Example
I wrote the example app with Swift Playgrounds 4, so you can run it right on your iPad. If you're using a Mac, download the Xcode version. [Download for Swift Playgrounds 4](https://github.com/aheze/Popovers/raw/main/Examples/PopoversPlaygroundsApp.swiftpm.zip) • [Download for Xcode](https://github.com/aheze/Popovers/raw/main/Examples/PopoversXcodeApp.zip)

![Example app](Assets/ExampleApp.png)

## Installation
Requires iOS 13+. Popovers can be installed through the [Swift Package Manager](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) (recommended) or [Cocoapods](https://cocoapods.org/).

<table>
<tr>
<td>
<strong>
Swift Package Manager
</strong>
<br>
Add the Package URL:
</td>
<td>
<strong>
Cocoapods
</strong>
<br>
Add this to your Podfile:
</td>
</tr>
  
<tr>
<td>
<br>

```
https://github.com/aheze/Popovers
```
</td>
<td>
<br>

```
pod 'Popovers'
```
</td>
</tr>
</table>



## Usage

To present a popover in SwiftUI, use the `.popover(present:attributes:view)` modifier. By default, the popover uses its parent view as the source frame.

```swift
import SwiftUI
import Popovers

struct ContentView: View {
    @State var present = false
    
    var body: some View {
        Button("Present popover!") {
            present = true
        }
        .popover(present: $present) { /// here!
            Text("Hi, I'm a popover.")
                .padding()
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(16)
        }
    }
}
```

In UIKit, create a `Popover` instance, then present with `UIViewController.present(_:)`. You should also set the source frame.

```swift
import SwiftUI
import Popovers

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonPressed(_ sender: Any) {
        var popover = Popover { PopoverView() }
        popover.attributes.sourceFrame = { [weak button] in
            button.windowFrame()
        }
        
        present(popover) /// here!
    }
}

struct PopoverView: View {
    var body: some View {
        Text("Hi, I'm a popover.")
            .padding()
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(16)
    }
}
```

<img src="Assets/UsagePopover.png" width=300 alt="Button 'Present popover!' with a popover underneath.">

<br>

## Customization
| [🔖](https://github.com/aheze/Popovers#tag--string)  | [💠](https://github.com/aheze/Popovers#position--position)  | [⬜](https://github.com/aheze/Popovers#source-frame-----cgrect)  | [🔲](https://github.com/aheze/Popovers#source-frame-inset--uiedgeinsets)  | [⏹](https://github.com/aheze/Popovers#screen-edge-padding--uiedgeinsets)  | [🟩](https://github.com/aheze/Popovers#presentation--presentation)  | [🟥](https://github.com/aheze/Popovers#dismissal--dismissal)  | [🎾](https://github.com/aheze/Popovers#rubber-banding-mode--rubberbandingmode)  | [🛑](https://github.com/aheze/Popovers#blocks-background-touches--bool)  | [👓](https://github.com/aheze/Popovers#accessibility--accessibility--v120)  | [👉](https://github.com/aheze/Popovers#on-tap-outside-----void)  | [🎈](https://github.com/aheze/Popovers#on-dismiss-----void)  | [🔰](https://github.com/aheze/Popovers#on-context-change--context---void)  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

Customize popovers through the `Attributes` struct. Pretty much everything is customizable, including positioning, animations, and dismissal behavior.

<table>
<tr>
<td>
<strong>
SwiftUI
</strong>
<br>
Configure in the <code>attributes</code> parameter.
</td>
<td>
<strong>
UIKit
</strong>
<br>
Modify the <code>attributes</code> property.
</td>
</tr>
  
<tr>
<td>
<br>

```swift
.popover(
    present: $present,
    attributes: {
        $0.position = .absolute(
            originAnchor: .bottom,
            popoverAnchor: .topLeft
        )
    }
) {
    Text("Hi, I'm a popover.")
}
```
</td>
<td>
<br>

```swift
var popover = Popover {
    Text("Hi, I'm a popover.")
}

popover.attributes.position = .absolute(
    originAnchor: .bottom,
    popoverAnchor: .topLeft
)

present(popover)
```
</td>
</tr>
</table>

### 🔖 Tag • `AnyHashable?`
Tag popovers to access them later from anywhere. This is useful for updating existing popovers.

```swift
/// Set the tag.
$0.tag = "Your Tag"

/// Access it later.
let popover = popover(tagged: "Your Tag") /// Where `self` is a `UIView` or `UIViewController`.

/// If inside a SwiftUI View, use a `WindowReader`:
WindowReader { window in
    let popover = window.popover(tagged: "Your Tag")
}
```

**Note:** When you use the `.popover(selection:tag:attributes:view:)` modifier, this `tag` is automatically set to what you provide in the parameter.

### 💠 Position • `Position`
The popover's position can either be `.absolute` (attached to a view) or `.relative` (picture-in-picture). The enum's associated value additionally configures which sides and corners are used.

- `Anchor`s represent sides and corners.
- For `.absolute`, provide the origin anchor and popover anchor.
- For `.relative`, provide the popover anchors. If there's multiple, the user will be able to drag between them like a PIP.

Anchor Reference | `.absolute(originAnchor: .bottom, popoverAnchor: .topLeft)` | `.relative(popoverAnchors: [.right])`
--- | --- | ---
![](Assets/Anchors.png) | ![](Assets/Absolute.png) | ![](Assets/Relative.png)

### ⬜ Source Frame • `(() -> CGRect)`
This is the frame that the popover attaches to or is placed within, depending on its position. This must be in global window coordinates. Because frames are can change so often, this property is a closure. Whenever the device rotates or some other bounds update happens, the closure will be called.


<table>
<tr>
<td>
<strong>
SwiftUI
</strong>
<br>
By default, the source frame is automatically set to the parent view. Setting this will override it.
</td>
<td>
<strong>
UIKit
</strong>
<br>
It's highly recommended to provide a source frame, otherwise the popover will appear in the top-left of the screen.
</td>
</tr>
  
<tr>
<td>
<br>

```swift
$0.sourceFrame = {
    /** some CGRect here */
}
```
</td>
<td>
<br>

```swift
 /// use `weak` to prevent a retain cycle
attributes.sourceFrame = { [weak button] in
    button.windowFrame()
}
```
</td>
</tr>
</table>

### 🔲 Source Frame Inset • `UIEdgeInsets`
Edge insets to apply to the source frame. Positive values inset the frame, negative values expand it.

Absolute | Relative
--- | ---
![Source view has padding around it, so the popover is offset down.](Assets/SourceFrameInsetAbsolute.png) | ![Source view is inset, so the popover is brought more towards the center of the screen.](Assets/SourceFrameInsetRelative.png)

### ⏹ Screen Edge Padding • `UIEdgeInsets`
Global insets for all popovers to prevent them from overflowing off the screen. Kind of like a safe area. Default value is `UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)`.

### 🟩 Presentation • `Presentation`
This property stores the animation and transition that's applied when the popover appears.

```swift
/// Default values:
$0.presentation.animation = .easeInOut
$0.presentation.transition = .opacity
```

### 🟥 Dismissal • `Dismissal`
This property stores the popover's dismissal behavior. There's a couple sub-properties here.

```swift
/// Same thing as `Presentation`.
$0.dismissal.animation = .easeInOut
$0.dismissal.transition = .opacity

/// Advanced stuff! Here's their default values:
$0.dismissal.mode = .tapOutside
$0.dismissal.tapOutsideIncludesOtherPopovers = false
$0.dismissal.excludedFrames = { [] }
$0.dismissal.dragMovesPopoverOffScreen = true
$0.dismissal.dragDismissalProximity = CGFloat(0.25)
```

**Mode:** Configure how the popover should auto-dismiss. You can have multiple at the same time!
- `.tapOutside` - dismiss the popover when the user taps outside it.
- `.dragDown` - dismiss the popover when the user drags it down.
- `.dragUp` - dismiss the popover when the user drags it up.
- `.none` - don't automatically dismiss the popover.

**Tap Outside Includes Other Popovers:** Only applies when `mode` is `.tapOutside`. If this is enabled, the popover will be dismissed when the user taps outside, **even when another presented popover is what's tapped**. Normally when you tap another popover that's presented, the current one will not dismiss.

**Excluded Frames:** Only applies when `mode` is `.tapOutside`. When the user taps outside the popover, but the tap lands on one of these frames, the popover will stay presented. If you want multiple popovers, you should set the source frames of your other popovers as the excluded frames.

```swift
/// Set one popover's source frame as the other's excluded frame.
/// This prevents the the current popover from being dismissed before animating to the other one.

let popover1 = Popover { Text("Hello") }
popover1.attributes.sourceFrame = { [weak button1] in button1.windowFrame() }
popover1.attributes.dismissal.excludedFrames = { [weak button2] in [ button2.windowFrame() ] }

let popover2 = Popover { Text("Hello") }
popover2.attributes.sourceFrame = { [weak button2] in button2.windowFrame() }
popover2.attributes.dismissal.excludedFrames = { [weak button1] in [ button1.windowFrame() ] }
```

**Drag Moves Popover Off Screen:** Only applies when `mode` is `.dragDown` or `.dragUp`. If this is enabled, the popover will continue moving off the screen after the user drags.

**Drag Dismissal Proximity:** Only applies when `mode` is `.dragDown` or `.dragUp`. Represents the point on the screen that the drag must reach in order to auto-dismiss. This property is multiplied by the screen's height.


<img src="Assets/DragDismissalProximity.png" width=300 alt="Diagram with the top 25% of the screen highlighted in blue.">


### 🎾 Rubber Banding Mode • `RubberBandingMode`
Configures which axes the popover can "rubber-band" on when dragged. The default is `[.xAxis, .yAxis]`.

- `.xAxis` - enable rubber banding on the x-axis.
- `.yAxis` - enable rubber banding on the y-axis.
- `.none` - disable rubber banding.

### 🛑 Blocks Background Touches • `Bool`
Set this to true to prevent underlying views from being pressed.

<img src="Assets/BlocksBackgroundTouches.png" width=300 alt="Popover overlaid over some buttons. Tapping on the buttons has no effect.">

### 👓 Accessibility • `Accessibility` • [*`v1.2.0`*](https://github.com/aheze/Popovers/releases/tag/1.2.0)
Popovers is fully accessible! The `Accessibility` struct provides additional options for how VoiceOver should read out content.

```swift
/// Default values:
$0.accessibility.shiftFocus = true
$0.accessibility.dismissButtonLabel = defaultDismissButtonLabel /// An X icon wrapped in `AnyView?`
```
**Shift Focus:** If enabled, VoiceOver will focus the popover as soon as it's presented.

**Dismiss Button Label:** A button next to the popover that appears when VoiceOver is on. By default, this is an <kbd>X</kbd> circle.

| <img src="Assets/Accessibility.png" width=300 alt="VoiceOver highlights the popover, which has a X button next to id."> |
| --- |

Tip: You can also use the accessibility escape gesture (a 2-fingered Z-shape swipe) to dismiss all popovers.

### 👉 On Tap Outside • `(() -> Void)?`
A closure that's called whenever the user taps outside the popover.

### 🎈 On Dismiss • `(() -> Void)?`
A closure that's called when the popover is dismissed.

### 🔰 On Context Change • `((Context) -> Void)?`
A closure that's called whenever the context changed. The context contains the popover's attributes, current frame, and other visible traits.

<br>

## Utilities
| [📘](https://github.com/aheze/Popovers#menus)  | [🧩](https://github.com/aheze/Popovers#animating-between-popovers)  | [🌃](https://github.com/aheze/Popovers#background)  | [📖](https://github.com/aheze/Popovers#popover-reader)  | [🏷](https://github.com/aheze/Popovers#frame-tags)  | [📄](https://github.com/aheze/Popovers#templates)  |
| --- | --- | --- | --- | --- | --- |

Popovers comes with some features to make your life easier.

### 📘 Menus
New in [v1.3.0](https://github.com/aheze/Popovers/releases/tag/1.3.0)! The template `Menu` looks and behaves pretty much exactly like the system menu, but also works on iOS 13. It's also extremely customizable with support for manual presentation and custom views.

| <img src="Assets/MenuComparison.gif" width=500 alt="The system menu and Popovers' custom menu, side by side"> |
| --- |

<details>
<summary>SwiftUI (Basic)</summary>

```swift
struct ContentView: View {
    var body: some View {
        Templates.Menu {
            Templates.MenuButton(title: "Button 1", systemImage: "1.circle.fill") { print("Button 1 pressed") }
            Templates.MenuButton(title: "Button 2", systemImage: "2.circle.fill") { print("Button 2 pressed") }
        } label: { fade in
            Text("Present Menu!")
                .opacity(fade ? 0.5 : 1)
        }
    }
}
```

</details>

<details>
<summary>SwiftUI (Customized)</summary>

```swift
Templates.Menu(
    configuration: {
        $0.width = 360
        $0.backgroundColor = .blue.opacity(0.2)
    }
) {
    Text("Hi, I'm a menu!")
        .padding()

    Templates.MenuDivider()

    Templates.MenuItem {
        print("Item tapped")
    } label: { fade in
        Color.clear.overlay(
            AsyncImage(url: URL(string: "https://getfind.app/image.png")) {
                $0.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.clear
            }
        )
        .frame(height: 180)
        .clipped()
        .opacity(fade ? 0.5 : 1)
    }

} label: { fade in
    Text("Present Menu!")
        .opacity(fade ? 0.5 : 1)
}
```

</details>

<details>
<summary>SwiftUI (Manual Presentation)</summary>

```swift
struct ContentView: View {
    @State var present = false
    var body: some View {
        VStack {
            Toggle("Activate", isOn: $present)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
                .padding()
            
            Templates.Menu(present: $present) {
                Templates.MenuButton(title: "Button 1", systemImage: "1.circle.fill") { print("Button 1 pressed") }
                Templates.MenuButton(title: "Button 2", systemImage: "2.circle.fill") { print("Button 2 pressed") }
            } label: { fade in
                Text("Present Menu!")
                    .opacity(fade ? 0.5 : 1)
            }
        }
    }
}
```

</details>

<details>
<summary>UIKit (Basic)</summary>

```swift
class ViewController: UIViewController {
    @IBOutlet var label: UILabel!

    lazy var menu = Templates.UIKitMenu(sourceView: label) {
        Templates.MenuButton(title: "Button 1", systemImage: "1.circle.fill") { print("Button 1 pressed") }
        Templates.MenuButton(title: "Button 2", systemImage: "2.circle.fill") { print("Button 2 pressed") }
    } fadeLabel: { [weak self] fade in
        self?.label.alpha = fade ? 0.5 : 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = menu /// Create the menu.
    }
}
```

</details>


<details>
<summary>UIKit (Customized)</summary>

```swift
class ViewController: UIViewController {
    @IBOutlet var label: UILabel!

    lazy var menu = Templates.UIKitMenu(
        sourceView: label,
        configuration: {
            $0.width = 360
            $0.backgroundColor = .blue.opacity(0.2)
        }
    ) {
        Text("Hi, I'm a menu!")
            .padding()

        Templates.MenuDivider()

        Templates.MenuItem {
            print("Item tapped")
        } label: { fade in
            Color.clear.overlay(
                AsyncImage(url: URL(string: "https://getfind.app/image.png")) {
                    $0.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.clear
                }
            )
            .frame(height: 180)
            .clipped()
            .opacity(fade ? 0.5 : 1)
        }
    } fadeLabel: { [weak self] fade in
        UIView.animate(withDuration: 0.15) {
            self?.label.alpha = fade ? 0.5 : 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = menu /// Create the menu.
    }
}

```

</details>

<details>
<summary>UIKit (Manual Presentation)</summary>

```swift
class ViewController: UIViewController {
    /// ...

    @IBAction func switchPressed(_ sender: UISwitch) {
        if menu.isPresented {
            menu.dismiss()
        } else {
            menu.present()
        }
    }
}
```

</details>


Basic | Customized | Manual Activation
--- | --- | ---
![Menu with 2 buttons](Assets/MenuBasic.png) | ![Menu with image and divider](Assets/MenuCustomized.png) | ![Manually activate the menu with a toggle switch](Assets/MenuManual.png)


### 🧩 Animating Between Popovers
As long as the view structure is the same, you can smoothly transition from one popover to another. 

<table>
<tr>
<td>
<strong>
SwiftUI
</strong>
<br>
Use the <code>.popover(selection:tag:attributes:view:)</code> modifier. 
</td>
<td>
<strong>
UIKit
</strong>
<br>
Get the existing popover using <code>UIResponder.popover(tagged:)</code>, then call <code>UIResponder.replace(_:with:)</code>.
</td>
</tr>
  
<tr>
<td>
<br>

```swift
struct ContentView: View {
    @State var selection: String?
    
    var body: some View {
        HStack {
            Button("Present First Popover") { selection = "1" }
            .popover(selection: $selection, tag: "1") {

                /// Will be presented when selection == "1".
                Text("Hi, I'm a popover.")
                    .background(.blue)
            }
            
            Button("Present Second Popover") { selection = "2" }
            .popover(selection: $selection, tag: "2") {

                /// Will be presented when selection == "2".
                Text("Hi, I'm a popover.")
                    .background(.green)
            }
        }
    }
}
```
</td>
<td>
<br>

```swift
@IBAction func button1Pressed(_ sender: Any) {
    var newPopover = Popover { Text("Hi, I'm a popover.").background(.blue) }
    newPopover.attributes.sourceFrame = { [weak button1] in button1.windowFrame() }
    newPopover.attributes.dismissal.excludedFrames = { [weak button2] in [button2.windowFrame()] }
    newPopover.attributes.tag = "Popover 1"
    
    if let oldPopover = popover(tagged: "Popover 2") {
        replace(oldPopover, with: newPopover)
    } else {
        present(newPopover) /// Present if the old popover doesn't exist.
    }
}
@IBAction func button2Pressed(_ sender: Any) {
    var newPopover = Popover { Text("Hi, I'm a popover.").background(.green) }
    newPopover.attributes.sourceFrame = { [weak button2] in button2.windowFrame() }
    newPopover.attributes.dismissal.excludedFrames = { [weak button1] in [button1.windowFrame()] }
    newPopover.attributes.tag = "Popover 2"
    
    if let oldPopover = popover(tagged: "Popover 1") {
        replace(oldPopover, with: newPopover)
    } else {
        present(newPopover)
    }
}
```
</td>
</tr>
</table>

| <img src="Assets/AnimatingBetweenPopovers.gif" width=300 alt="Smooth transition between popovers (from blue to green and back."> |
| --- |

### 🌃 Background
You can put anything in a popover's background.

<table>
<tr>
<td>
<strong>
SwiftUI
</strong>
<br>
Use the <code>.popover(present:attributes:view:background:)</code> modifier. 
</td>
<td>
<strong>
UIKit
</strong>
<br>
Use the <code>Popover(attributes:view:background:)</code> initializer. 
</td>
</tr>
  
<tr>
<td>
<br>

```swift
.popover(present: $present) {
    PopoverView()
} background: { /// here!
    Color.green.opacity(0.5)
}
```
</td>
<td>
<br>

```swift
var popover = Popover {
    PopoverView()
} background: { /// here!
    Color.green.opacity(0.5)
}
```
</td>
</tr>
</table>

<img src="Assets/PopoverBackground.png" width=200 alt="Green background over the entire screen, but underneath the popover">


### 📖 Popover Reader
This reads the popover's context, which contains its frame, window, attributes, and various other properties. It's kind of like [`GeometryReader`](https://www.hackingwithswift.com/quick-start/swiftui/how-to-provide-relative-sizes-using-geometryreader), but cooler. You can put it in the popover's view or its background.

```swift
.popover(present: $present) {
    PopoverView()
} background: {
    PopoverReader { context in
        Path {
            $0.move(to: context.frame.point(at: .bottom))
            $0.addLine(to: context.windowBounds.point(at: .bottom))
        }
        .stroke(Color.blue, lineWidth: 4)
    }
}
```

| <img src="Assets/PopoverReader.gif" width=200 alt="Line connects the bottom of the popover with the bottom of the screen"> |
| --- |

### 🏷 Frame Tags
Popovers includes a mechanism for tagging and reading SwiftUI view frames. You can use this to provide a popover's `sourceFrame` or `excludedFrames`. Also works great when combined with `PopoverReader`, for connecting lines with anchor views.

```swift
Text("This is a view")
    .frameTag("Your Tag Name") /// Adds a tag inside the window.

/// ...

WindowReader { window in
    Text("Click me!")
    .popover(
        present: $present,
        attributes: {
            $0.sourceFrame = window.frameTagged("Your Tag Name") /// Retrieves a tag from the window.
        }
    )
}
```


### 📄 Templates
Get started quickly with some templates. All of them are inside [`Templates`](Sources/Templates) with example usage in the example app.

- `AlertButtonStyle` - a button style resembling a system alert.
- `VisualEffectView` - lets you use UIKit blurs in SwiftUI.
- `Container` - a wrapper view for the `BackgroundWithArrow` shape.
- `Shadow` - an easier way to apply shadows.
- `BackgroundWithArrow` - a shape with an arrow that looks like the system popover.
- `CurveConnector` - an animatable shape with endpoints that you can set.
- `Menu` - the system menu, but built from scratch.

<br>

## Notes
### State Re-Rendering
If you directly pass a variable down to the popover's view, it might not update. Instead, move the view into its own struct and pass down a `Binding`.

<table>
<tr>
<td>
<strong>
Yes
</strong>
<br>
The popover's view is in a separate struct, with <code>$string</code> passed down.
</td>
<td>
<strong>
No
</strong>
<br>
The button is directly inside the <code>view</code> parameter and receives <code>string</code>.
</td>
</tr>
  
<tr>
<td>
<br>

```swift
struct ContentView: View {
    @State var present = false
    @State var string = "Hello, I'm a popover."

    var body: some View {
        Button("Present popover!") { present = true }
        .popover(present: $present) {
            PopoverView(string: $string) /// Pass down a Binding ($).
        }
    }
}

/// Create a separate view to ensure that the button updates.
struct PopoverView: View {
    @Binding var string: String

    var body: some View {
        Button(string) { string = "The string changed." }
        .background(.mint)
        .cornerRadius(16)
    }
}
```
</td>
<td>
<br>

```swift
struct ContentView: View {
    @State var present = false
    @State var string = "Hello, I'm a popover."

    var body: some View {
        Button("Present popover!") {
            present = true
        }
        .popover(present: $present) {

            /// Directly passing down the variable (without $) is unsupported.
            /// The button might not update.
            Button(string) { 
                string = "The string changed."
            }
            .background(.mint)
            .cornerRadius(16)
        }
    }
}
```
</td>
</tr>
</table>

### Supporting Multiple Screens • [*`v1.1.0`*](https://github.com/aheze/Popovers/releases/tag/1.1.0)
Popovers comes with built-in support for multiple screens, but retrieving frame tags requires a reference to the hosting window. You can get this via `WindowReader` or `PopoverReader`'s context.

```swift
WindowReader { window in 

}

/// If inside a popover's `view` or `background`, use `PopoverReader` instead.
PopoverReader { context in
    let window = context.window
}
```

### Popover Hierarchy
Manage a popover's z-axis level by attaching [`.zIndex(_:)`](https://developer.apple.com/documentation/swiftui/view/zindex(_:)) to its view. A higher index will bring it forwards.


## Community
### Author
Popovers is made by [aheze](https://github.com/aheze).

### Contributing
All contributions are welcome. Just [fork](https://github.com/aheze/Popovers/fork) the repo, then make a pull request.

### Need Help?
Open an [issue](https://github.com/aheze/Popovers/issues) or join the [Discord server](https://discord.com/invite/Pmq8fYcus2). You can also ping me on [Twitter](https://twitter.com/aheze0). Or read the source code — there's lots of comments.

## License

```
MIT License

Copyright (c) 2022 A. Zheng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
