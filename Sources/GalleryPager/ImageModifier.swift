import SwiftUI
import UIKit
import Kingfisher

// MARK: - ZoomableScrollView
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var currentScale: CGFloat
    let minScale: CGFloat
    let maxScale: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.bouncesZoom = true
        scrollView.backgroundColor = .clear

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        context.coordinator.hostingController = hostingController
        context.coordinator.scrollView = scrollView

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale

        // Update zoom scale if changed externally (e.g., double tap)
        if abs(scrollView.zoomScale - currentScale) > 0.01 {
            scrollView.setZoomScale(currentScale, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentScale: $currentScale)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding var currentScale: CGFloat
        var hostingController: UIHostingController<Content>?
        weak var scrollView: UIScrollView?

        init(currentScale: Binding<CGFloat>) {
            self._currentScale = currentScale
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController?.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                self?.currentScale = scrollView.zoomScale
            }

            // Center the content when it's smaller than the scroll view
            guard let hostedView = hostingController?.view else { return }

            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)

            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }
    }
}

// MARK: - ImageModifier
struct ImageModifier: ViewModifier {
    private var contentSize: CGSize
    private var containerSize: CGSize
    private var min: CGFloat = 1.0
    private var max: CGFloat = 3.0
    @State var currentScale: CGFloat = 1.0

    init(contentSize: CGSize, containerSize: CGSize) {
        self.contentSize = contentSize
        self.containerSize = containerSize
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
        ZoomableScrollView(
            content: content
                .frame(width: contentSize.width, height: contentSize.height),
            currentScale: $currentScale,
            minScale: min,
            maxScale: max
        )
        .frame(width: containerSize.width, height: containerSize.height)
        .gesture(doubleTapGesture)
    }
}

// MARK: - KFImage Extension
extension KFImage {
    @ViewBuilder
    func gesturesHandler(contentSize: CGSize, containerSize: CGSize) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .modifier(ImageModifier(contentSize: contentSize, containerSize: containerSize))
    }
}
