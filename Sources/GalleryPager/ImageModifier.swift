import SwiftUI
import UIKit
import Kingfisher
import SwiftUIIntrospect

struct ImageModifier: ViewModifier {
    private var contentSize: CGSize
    private var min: CGFloat = 1.0
    private var max: CGFloat = 3.0
    @State var currentScale: CGFloat = 1.0
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
                .frame(
                    width: contentSize.width * currentScale,
                    height: contentSize.height * currentScale,
                    alignment: .center
                )
                .modifier(PinchToZoom(
                    minScale: min,
                    maxScale: max,
                    scale: $currentScale,
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

class PinchZoomView: UIView {
    let minScale: CGFloat
    let maxScale: CGFloat
    var isPinching: Bool = false
    var scale: CGFloat = 1.0
    var startScale: CGFloat = 1.0
    let scaleChange: (CGFloat) -> Void
    
    init(minScale: CGFloat,
         maxScale: CGFloat,
         currentScale: CGFloat,
         scaleChange: @escaping (CGFloat) -> Void) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.scale = currentScale
        self.scaleChange = scaleChange
        super.init(frame: .zero)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            startScale = scale // Capture the current scale at the start of the pinch
        case .changed, .ended:
            let adjustedScale = startScale * gesture.scale // Apply the pinch changes relative to the startScale
            if adjustedScale <= minScale {
                scale = minScale
            } else if adjustedScale >= maxScale {
                scale = maxScale
            } else {
                scale = adjustedScale
            }
            scaleChange(scale)
            if gesture.state == .ended {
                startScale = scale // Update the startScale at the end of the pinch
            }
        case .cancelled, .failed:
            isPinching = false
            scale = startScale // Reset to startScale, not to 1.0
        default:
            break
        }
    }
}

struct PinchZoom: UIViewRepresentable {
    let minScale: CGFloat
    let maxScale: CGFloat
    @Binding var scale: CGFloat
    @Binding var isPinching: Bool
    
    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView(
            minScale: minScale,
            maxScale: maxScale,
            currentScale: scale,
            scaleChange: {
                scale = $0
            }
        )
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: PinchZoomView, context: Context) {
        
    }
}

struct PinchToZoom: ViewModifier {
    let minScale: CGFloat
    let maxScale: CGFloat
    @Binding var scale: CGFloat
    let contentSize: CGSize
    @State var anchor: UnitPoint = .center
    @State var isPinching: Bool = false
    
    func body(content: Content) -> some View {
        content
            .animation(.spring(), value: isPinching)
            .overlay(PinchZoom(minScale: minScale, maxScale: maxScale, scale: $scale, isPinching: $isPinching))
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
