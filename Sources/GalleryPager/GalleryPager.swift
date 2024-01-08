import SwiftUI
import Kingfisher

public struct ActionableItem: Identifiable {
    public var id: UUID = UUID()
    public var title: String?
    public var systemImage: String
    public var action: (URL, Int) -> Void
    
    public init(title: String? = nil, systemImage: String, action: @escaping (URL, Int) -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
}

public struct GalleryPagerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var currentImage: Int = 0
    @State private var imageSize: CGSize = .zero
    private var actionableItems: [ActionableItem] = []
    private let imagesUrl: [URL]
    private var startIndex: Int = 0
    
    public init(imagesUrl: [String], startIndex: Int = 0, actions: [ActionableItem] = []) {
        let urls = imagesUrl.compactMap({ URL(string: $0) })
        self.init(imagesUrl: urls, startIndex: startIndex, actions: actions)
    }
    
    public init(imagesUrl: [URL], startIndex: Int = 0, actions: [ActionableItem] = []) {
        self.imagesUrl = imagesUrl
        self.startIndex = startIndex
        self.actionableItems = actions
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
        HStack(alignment: .center, spacing: 8) {
            ForEach(0..<actionableItems.count, id: \.self) { index in
                let actionableItem = actionableItems[index]
                
                Button {
                    actionableItem.action(imagesUrl[currentImage], currentImage)
                } label: {
                    HStack {
                        Spacer()
                        
                        if let title = actionableItem.title {
                            Text(title)
                                .font(.system(size: 14).bold())
                        }
                        
                        Image(systemName: actionableItem.systemImage)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(width: 35, height: 35, alignment: .center)
                            .padding(0)
                        
                        Spacer()
                    }
                }
                
                if index < (actionableItems.count - 1) {
                    Spacer()
                    
                    Divider()
                        .background(Color.white)
                        .padding(.vertical, 8)
                    
                    Spacer()
                }
            }
        }
        .foregroundColor(.white)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(
            Rectangle()
                .fill(.black.opacity(0.8))
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
