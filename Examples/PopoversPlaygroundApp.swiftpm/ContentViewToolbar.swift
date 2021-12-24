//
//  ContentViewToolbar.swift
//  PopoversPlaygroundApp
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI
import Popovers
import WebKit

struct ContentViewToolbar: ViewModifier {
    @State var presentInfo = false
    @State var presentDocumentation = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        presentInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .popover(
                        present: $presentInfo,
                        attributes: {
                            $0.position = .absolute(
                                originAnchor: .bottomRight,
                                popoverAnchor: .topRight
                            )
                            $0.sourceFrameInset.bottom = -12
                            $0.dismissal.mode = [.dragDown, .tapOutside]
                        }
                    ) {
                        PopoverTemplates.Container(cornerRadius: 20) {
                            InfoView()
                        }
                        .frame(maxWidth: 400)
                    }
                    
                    Button {
                        presentDocumentation = true
                    } label: {
                        Image(systemName: "book.closed")
                    }
                    .popover(
                        present: $presentDocumentation,
                        attributes: {
                            $0.position = .relative(
                                popoverAnchors: [
                                    .center
                                ]
                            )
                            $0.dismissal.mode = [.tapOutside]
                            $0.presentation.transition = .move(edge: .bottom)
                            $0.dismissal.transition = .move(edge: .bottom).combined(with: .opacity)
                            $0.rubberBandingMode = .none
                        }
                    ) {
                        DocumentationView(present: $presentDocumentation)
                            .frame(maxWidth: 600, maxHeight: 700)
                    }
                }
            }
    }
}

struct ContentViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, world!")
            .modifier(ContentViewToolbar())
    }
}


struct InfoView: View {
    let uiColor = UIColor(hex: 0x007EEF)
    let color = Color(uiColor: UIColor(hex: 0x007EEF))
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome to Popovers!")
                .font(.title2.bold())
                .padding(.top, 8)
            
            Text("Popovers is a library that presents popovers. Check it out in this demo playground!")
                .multilineTextAlignment(.center)
            
            InfoRowContainer(color: UIColor(hex: 0x007EEF)) {
                InfoRow(
                    title: "Incredibly Easy",
                    description: "Just add `.popover` and you're done.",
                    image: "checkmark"
                )
                InfoRow(
                    title: "Fast and Powerful",
                    description: "You can present any SwiftUI view and the package is under 200kb.",
                    image: "bolt.fill"
                )
                InfoRow(
                    title: "Customize Everything",
                    description: "Popovers was designed with advanced usage in mind.",
                    image: "slider.horizontal.3"
                )
                
                InfoRow(
                    title: "Need Help?",
                    description: "Open an issue on [GitHub](https://github.com/aheze/Popovers/issues) or join the [Discord server](https://discord.com/invite/Pmq8fYcus2).",
                    image: "questionmark"
                )
            }
        }
    }
}

struct InfoRowContainer<Content: View>: View {
    var color: UIColor = .systemBlue
    @ViewBuilder var view: Content
    
    var body: some View {
        VStack(spacing: 16) {
            view
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(10)
                .shadow(
                    color: Color(uiColor: .label.withAlphaComponent(0.25)),
                    radius: 10,
                    x: 0,
                    y: 3
                )
        }
        .padding()
        .background(
            Color(uiColor: .systemBackground)
                .overlay(alignment: .bottomTrailing) {
                    LinearGradient(
                        colors: [
                            Color(uiColor: color.offset(by: 0.2)),
                            Color(uiColor: color)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                        .aspectRatio(contentMode: .fill)
                }
        )
        .cornerRadius(16)
        .foregroundColor(.primary)
    }
}

struct InfoRow: View {
    var title: String
    var description: String
    var image: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bold()
            
            Text(.init(description))
        }
        .padding(.trailing, 36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            InfoImage(image: image, color: UIColor(hex: 0x007EEF))
        }
    }
}

struct InfoImage: View {
    var image: String
    var color: UIColor
    
    var body: some View {
        Image(systemName: image)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .medium))
            .padding(8)
            .background {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(uiColor: color.offset(by: 0.2)),
                                Color(uiColor: color)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
    }
}


struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}

struct DocumentationView: View {
    @Binding var present: Bool
    @State var ready = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Documentation")
                    .fontWeight(.medium)
                
                Link(destination: URL(string: "https://github.com/aheze/popovers")!) {
                    Image(systemName: "arrow.up.right.square")
                }
                
                Spacer()
                
                Button {
                    present = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            
            Divider()
            
            WebView(ready: $ready, url: URL(string: "https://github.com/aheze/Popovers")!)
        }
        .opacity(ready ? 1 : 0)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: .secondaryLabel))
                .overlay {
                    ProgressView()
                        .opacity(ready ? 0 : 1)
                }
        }
    }
}

/// from https://developer.apple.com/forums/thread/126986?answerId=398582022#398582022
struct WebView: UIViewRepresentable {
    @Binding var ready: Bool
    var url: URL
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: url))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            withAnimation {
                parent.ready = true
            }
        }
    }
}

struct DocumentationView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentationView(present: .constant(true))
    }
}
