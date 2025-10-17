import SwiftUI
import Kingfisher
import SwiftUIIntrospect

struct ImageModifier: ViewModifier {
    private var contentSize: CGSize
    private var min: CGFloat = 1.0
    private var max: CGFloat = 3.0
    @State var currentScale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State private var alwaysBounceVertical = false

    init(contentSize: CGSize) {
        self.contentSize = contentSize
    }

    var doubleTapGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            if currentScale <= min {
                currentScale = max
            } else if currentScale >= max {
                currentScale = min
            } else {
                currentScale = ((max - min) * 0.5 + min) < currentScale ? max : min
            }
        }
    }

    func body(content: Content) -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            content
                .modifier(PinchToZoom(
                    minScale: min,
                    maxScale: max,
                    scale: $currentScale,
                    anchor: $anchor,
                    contentSize: contentSize
                ))
        }
        .gesture(doubleTapGesture)
        .animation(.easeInOut, value: currentScale)
        .introspect(.scrollView, on: .iOS(.v14, .v15, .v16, .v17)) { scrollView in
            scrollView.alwaysBounceVertical = false
        }
    }
}

struct PinchToZoom: ViewModifier {
    let minScale: CGFloat
    let maxScale: CGFloat
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    let contentSize: CGSize

    @State private var startScale: CGFloat = 1.0
    @GestureState private var magnifyBy: CGFloat = 1.0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(width: contentSize.width, height: contentSize.height)
                .scaleEffect(scale, anchor: anchor)
                .frame(
                    width: contentSize.width * scale,
                    height: contentSize.height * scale
                )
                .gesture(
                    MagnificationGesture()
                        .updating($magnifyBy) { currentState, gestureState, _ in
                            gestureState = currentState
                        }
                        .onChanged { value in
                            let delta = value / magnifyBy
                            let newScale = scale * delta

                            if newScale >= minScale && newScale <= maxScale {
                                scale = newScale
                            } else if newScale < minScale {
                                scale = minScale
                            } else if newScale > maxScale {
                                scale = maxScale
                            }
                        }
                        .simultaneously(with: DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Calculate anchor point from touch location
                                let x = value.location.x / geometry.size.width
                                let y = value.location.y / geometry.size.height
                                anchor = UnitPoint(x: x, y: y)
                            }
                        )
                )
        }
    }
}

extension KFImage {
    @ViewBuilder
    func gesturesHandler(contentSize: CGSize) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .modifier(ImageModifier(contentSize: contentSize))
    }
}
