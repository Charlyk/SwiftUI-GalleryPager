import SwiftUI
import Kingfisher

public struct GalleryPagerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var currentImage: Int = 0
    @State private var imageSize: CGSize = .zero
    private let imagesUrl: [URL]
    private var startIndex: Int = 0
    
    public init(imagesUrl: [String], startIndex: Int = 0) {
        let urls = imagesUrl.compactMap({ URL(string: $0) })
        self.imagesUrl = urls
        self.startIndex = startIndex
    }
    
    public init(imagesUrl: [URL], startIndex: Int = 0) {
        self.imagesUrl = imagesUrl
        self.startIndex = startIndex
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                TabView(selection: $currentImage) {
                    ForEach(0..<imagesUrl.count, id: \.self) { imageIndex in
                        KFImage(imagesUrl[imageIndex])
                            .onSuccess({ result in
                                imageSize = result.image.size
                            })
                            .gesturesHandler(
                                contentSize: .init(
                                    width: calculateSize(frameSize: geometry.size).width,
                                    height: calculateSize(frameSize: geometry.size).height
                                )
                            )
                            .tag(imageIndex)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
        .overlay(closeImageButton, alignment: .topLeading)
        .overlay(actionsContainer, alignment: .bottom)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            if imagesUrl.count > startIndex {
                self.currentImage = startIndex
            } else {
                self.currentImage = 0
            }
        }
    }
    
    @ViewBuilder
    private var actionsContainer: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 35, height: 35, alignment: .center)
                    .padding(0)
            }
            
            Divider()
            
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 35, height: 35, alignment: .center)
                    .padding(0)
            }
        }
        .foregroundColor(.white)
        .frame(height: 50)
        .background(
            Rectangle()
                .fill(.black.opacity(0.6))
                .edgesIgnoringSafeArea(.bottom)
        )
    }
    
    @ViewBuilder
    private var closeImageButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .padding(8)
                .frame(width: 35, height: 35, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 17)
                        .fill(.black.opacity(0.6))
                )
                .padding(.horizontal)
                .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
    
    private func calculateSize(frameSize: CGSize) -> CGSize {
        if imageSize == .zero {
            return .zero
        }
        
        let widthRatio = frameSize.width / imageSize.width
        let heightRatio = frameSize.height / imageSize.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
        
        return scaledSize
    }
}

extension View {
    @ViewBuilder
    public func measure(_ size: Binding<CGSize>) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    size.wrappedValue = proxy.size
                }
            }
        )
    }
}
