//
//  ResponsiveHelpers.swift
//  CocoPetParadise
//
//  Responsive layout helpers for all iPhone screen sizes
//  Add this file to your project to enable responsive utilities
//

import SwiftUI

// MARK: - Device Screen Size Categories
enum DeviceSize {
    case small      // iPhone SE, 8 (< 375 width or < 700 height)
    case medium     // iPhone 12, 13, 14, 15 (375-430 width)
    case large      // iPhone Pro Max models (> 430 width)
    
    static var current: DeviceSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        if width < 375 || height < 700 {
            return .small
        } else if width > 430 || height > 900 {
            return .large
        } else {
            return .medium
        }
    }
}

// MARK: - Responsive Values
struct ResponsiveValue {
    let small: CGFloat
    let medium: CGFloat
    let large: CGFloat
    
    var value: CGFloat {
        switch DeviceSize.current {
        case .small: return small
        case .medium: return medium
        case .large: return large
        }
    }
    
    init(_ small: CGFloat, _ medium: CGFloat, _ large: CGFloat) {
        self.small = small
        self.medium = medium
        self.large = large
    }
    
    // Convenience initializer with just two values (small and default)
    init(small: CGFloat, default defaultValue: CGFloat) {
        self.small = small
        self.medium = defaultValue
        self.large = defaultValue
    }
}

// MARK: - Responsive Font Sizes
struct ResponsiveFonts {
    static let largeTitle = ResponsiveValue(28, 32, 36).value
    static let title = ResponsiveValue(24, 28, 32).value
    static let title2 = ResponsiveValue(20, 22, 24).value
    static let title3 = ResponsiveValue(18, 20, 22).value
    static let headline = ResponsiveValue(15, 17, 18).value
    static let body = ResponsiveValue(14, 15, 16).value
    static let bodySmall = ResponsiveValue(12, 13, 14).value
    static let caption = ResponsiveValue(11, 12, 13).value
    static let captionSmall = ResponsiveValue(10, 11, 12).value
}

// MARK: - Responsive Spacing
struct ResponsiveSpacing {
    static let small = ResponsiveValue(4, 6, 8).value
    static let medium = ResponsiveValue(8, 12, 16).value
    static let large = ResponsiveValue(16, 20, 24).value
    static let xlarge = ResponsiveValue(20, 28, 32).value
    
    static let horizontalPadding = ResponsiveValue(16, 20, 24).value
    static let verticalPadding = ResponsiveValue(12, 16, 20).value
    static let cardPadding = ResponsiveValue(12, 16, 20).value
}

// MARK: - Responsive Icon Sizes
struct ResponsiveIconSizes {
    static let small = ResponsiveValue(16, 20, 24).value
    static let medium = ResponsiveValue(24, 28, 32).value
    static let large = ResponsiveValue(40, 50, 60).value
    static let xlarge = ResponsiveValue(60, 70, 80).value
}

// MARK: - View Extensions for Responsive Layout
extension View {
    /// Apply minimum scale factor to prevent text truncation
    func preventTruncation(minScale: CGFloat = 0.8, lineLimit: Int = 1) -> some View {
        self
            .lineLimit(lineLimit)
            .minimumScaleFactor(minScale)
    }
    
    /// Apply responsive font size
    func responsiveFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        let adjustedSize: CGFloat
        switch DeviceSize.current {
        case .small: adjustedSize = size * 0.9
        case .medium: adjustedSize = size
        case .large: adjustedSize = size * 1.05
        }
        return self.font(.system(size: adjustedSize, weight: weight, design: design))
    }
    
    /// Apply responsive padding
    func responsivePadding(_ edges: Edge.Set = .all, baseAmount: CGFloat = 16) -> some View {
        let amount: CGFloat
        switch DeviceSize.current {
        case .small: amount = baseAmount * 0.8
        case .medium: amount = baseAmount
        case .large: amount = baseAmount * 1.15
        }
        return self.padding(edges, amount)
    }
    
    /// Apply responsive frame with dynamic sizing
    func responsiveFrame(
        minWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        idealHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> some View {
        let multiplier: CGFloat
        switch DeviceSize.current {
        case .small: multiplier = 0.85
        case .medium: multiplier = 1.0
        case .large: multiplier = 1.1
        }
        
        return self.frame(
            minWidth: minWidth.map { $0 * multiplier },
            idealWidth: idealWidth.map { $0 * multiplier },
            maxWidth: maxWidth.map { $0 * multiplier },
            minHeight: minHeight.map { $0 * multiplier },
            idealHeight: idealHeight.map { $0 * multiplier },
            maxHeight: maxHeight.map { $0 * multiplier }
        )
    }
    
    /// Conditional modifier based on device size
    @ViewBuilder
    func ifSmallDevice<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        if DeviceSize.current == .small {
            transform(self)
        } else {
            self
        }
    }
    
    /// Conditional modifier based on device size
    @ViewBuilder
    func ifLargeDevice<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        if DeviceSize.current == .large {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Responsive Grid Columns
struct ResponsiveGridColumns {
    static func adaptive(minWidth: CGFloat) -> [GridItem] {
        let adjustedMin: CGFloat
        switch DeviceSize.current {
        case .small: adjustedMin = minWidth * 0.85
        case .medium: adjustedMin = minWidth
        case .large: adjustedMin = minWidth * 1.1
        }
        return [GridItem(.adaptive(minimum: adjustedMin))]
    }
    
    static func fixed(count: Int, spacing: CGFloat = 16) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
    
    static var twoColumn: [GridItem] {
        [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    }
    
    static var threeColumn: [GridItem] {
        [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    }
}

// MARK: - Screen Size Reader
struct ScreenSizeReader: View {
    @Binding var screenSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    screenSize = geometry.size
                }
                .onChange(of: geometry.size) { _, newValue in
                    screenSize = newValue
                }
        }
    }
}

// MARK: - Safe Area Reader
struct SafeAreaReader: View {
    @Binding var safeAreaInsets: EdgeInsets
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    safeAreaInsets = EdgeInsets(
                        top: geometry.safeAreaInsets.top,
                        leading: geometry.safeAreaInsets.leading,
                        bottom: geometry.safeAreaInsets.bottom,
                        trailing: geometry.safeAreaInsets.trailing
                    )
                }
        }
    }
}

// MARK: - Dynamic Type Support
extension Font {
    static func responsiveSystem(
        _ style: TextStyle,
        weight: Weight = .regular,
        design: Design = .default
    ) -> Font {
        return .system(style, design: design, weight: weight)
    }
}

// MARK: - Text Extension for Accessibility
extension Text {
    func accessibleText(minimumScale: CGFloat = 0.8) -> some View {
        self
            .lineLimit(nil)
            .minimumScaleFactor(minimumScale)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Preview Helper
struct ResponsivePreview<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        TabView {
            content
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
            
            content
                .previewDevice("iPhone 14")
                .previewDisplayName("iPhone 14")
            
            content
                .previewDevice("iPhone 15 Pro Max")
                .previewDisplayName("iPhone 15 Pro Max")
        }
    }
}

// MARK: - Example Usage
/*
 
 // Example 1: Responsive Text
 Text("Welcome to Coco's Pet Paradise")
     .responsiveFont(size: 24, weight: .bold)
     .preventTruncation()
 
 // Example 2: Responsive Padding
 VStack {
     // content
 }
 .responsivePadding(.horizontal, baseAmount: 20)
 
 // Example 3: Conditional Modifier
 Image(systemName: "star")
     .ifSmallDevice { view in
         view.font(.system(size: 16))
     }
 
 // Example 4: Responsive Grid
 LazyVGrid(columns: ResponsiveGridColumns.twoColumn) {
     // items
 }
 
 // Example 5: Using ResponsiveValue
 let iconSize = ResponsiveValue(40, 50, 60).value
 
 */
