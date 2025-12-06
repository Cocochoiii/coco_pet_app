//
//  AppColors.swift
//  CocoPetParadise
//
//  Theme colors matching the website's cream-pink aesthetic
//

import SwiftUI

struct AppColors {
    // MARK: - Primary Colors (Rose Milk Tea)
    static let primary = Color(hex: "D4A5A5")
    static let primary50 = Color(hex: "FDFCFB")
    static let primary100 = Color(hex: "FAF7F5")
    static let primary200 = Color(hex: "F5EDE8")
    static let primary300 = Color(hex: "EEE1DB") // Main light cream pink
    static let primary400 = Color(hex: "E6D0C7")
    static let primary500 = Color(hex: "D4A5A5") // Medium rose milk tea
    static let primary600 = Color(hex: "C08B8B")
    static let primary700 = Color(hex: "A67373") // Deep rose brown
    static let primary800 = Color(hex: "8B5E5E")
    static let primary900 = Color(hex: "704949")
    static let primary950 = Color(hex: "553636")
    
    // MARK: - Neutral Colors (Warm Gray-Brown)
    static let neutral = Color(hex: "8B7E78")
    static let neutral50 = Color(hex: "FAFAF9")
    static let neutral100 = Color(hex: "F5F4F3")
    static let neutral150 = Color(hex: "EFEDEB")
    static let neutral200 = Color(hex: "E8E5E2")
    static let neutral300 = Color(hex: "D6D2CE")
    static let neutral400 = Color(hex: "B0A9A4")
    static let neutral500 = Color(hex: "8B7E78")
    static let neutral600 = Color(hex: "6B5D57")
    static let neutral700 = Color(hex: "524641")
    static let neutral800 = Color(hex: "3A3330")
    static let neutral900 = Color(hex: "2A2522")
    static let neutral950 = Color(hex: "1A1614")
    
    // MARK: - Functional Colors
    static let success = Color(hex: "7A9A82")
    static let warning = Color(hex: "D4A574")
    static let error = Color(hex: "C17B7B")
    static let info = Color(hex: "8FA5B8")
    
    // MARK: - Background Colors
    static let background = Color.white
    static let backgroundSecondary = Color(hex: "FAFAF9")
    static let backgroundTertiary = Color(hex: "F5F4F3")
    
    // MARK: - Border Colors
    static let border = Color(hex: "E8E5E2")
    static let borderLight = Color(hex: "F5F4F3")
    static let borderDark = Color(hex: "D6D2CE")
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "2A2522")
    static let textSecondary = Color(hex: "6B5D57")
    static let textTertiary = Color(hex: "8B7E78")
    static let textOnPrimary = Color.white
    
    // MARK: - Gradient
    static let subtleGradient = LinearGradient(
        colors: [primary300, primary500],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [background, neutral50],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [primary100, primary200],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Fonts
struct AppFonts {
    static func display(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    
    static func body(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    // Predefined sizes
    static let largeTitle = display(34, weight: .bold)
    static let title = display(28, weight: .bold)
    static let title2 = display(22, weight: .semibold)
    static let title3 = display(20, weight: .semibold)
    static let headline = body(17, weight: .semibold)
    static let bodyLarge = body(17)
    static let bodyMedium = body(15)
    static let bodySmall = body(13)
    static let caption = body(12)
    static let captionSmall = body(11)
}

// MARK: - App Shadows
struct AppShadows {
    static let soft = Color.black.opacity(0.05)
    static let medium = Color.black.opacity(0.1)
    static let strong = Color.black.opacity(0.15)
    
    static func cardShadow() -> some View {
        EmptyView()
    }
}

// MARK: - Custom View Modifiers
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: AppShadows.soft, radius: 10, x: 0, y: 4)
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                isDisabled ? AppColors.neutral400 : AppColors.primary700
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.headline)
            .foregroundColor(AppColors.primary700)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(AppColors.primary100)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.headline)
            .foregroundColor(AppColors.primary700)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.primary700, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
    
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}
