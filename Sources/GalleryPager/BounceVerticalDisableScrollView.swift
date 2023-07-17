import SwiftUI

struct BounceVerticalDisableScrollView<Content: View>: View {
    
    @State private var alwaysBounceVertical = false
    let content: Content
    let axes: Axis.Set
    let showsIndicators: Bool
    
    init(_ axes: Axis.Set, showsIndicators: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        axes = [.vertical]
        showsIndicators = true
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            GeometryReader { scrlViewGeometry in
                content
                    .background(
                        GeometryReader {
                            // calculate height by clear background
                            Color.clear.preference(key: SizePreferenceKey.self,
                                                   value: $0.frame(in: .local).size.height)
                        }.onPreferenceChange(SizePreferenceKey.self) {
                            self.alwaysBounceVertical = $0 < scrlViewGeometry.size.height
                        }
                    )
            }
            // disable scroll when content size is less than frame of scrollview
            .disabled(self.alwaysBounceVertical)
        }
    }
}
// return size
public struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = .zero
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
