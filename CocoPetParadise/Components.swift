//
//  Components.swift
//  CocoPetParadise
//
//  Reusable UI components
//

import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(AppColors.primary200, lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(AppColors.primary700, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text(message)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var buttonAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.neutral300)
            
            Text(title)
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            Text(message)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let buttonTitle = buttonTitle, let action = buttonAction {
                Button(action: action) {
                    Text(buttonTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let text: String
    var color: Color = AppColors.primary700
    var size: BadgeSize = .medium
    
    enum BadgeSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return AppFonts.captionSmall
            case .medium: return AppFonts.caption
            case .large: return AppFonts.bodySmall
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(size.font)
            .foregroundColor(.white)
            .padding(size.padding)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - Icon Badge
struct IconBadge: View {
    let icon: String
    var color: Color = AppColors.primary700
    var size: CGFloat = 44
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.45))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.1))
            .cornerRadius(size * 0.27)
    }
}

// MARK: - Divider with Text
struct DividerWithText: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(AppColors.border)
                .frame(height: 1)
            
            Text(text)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textTertiary)
            
            Rectangle()
                .fill(AppColors.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Info Banner
struct InfoBanner: View {
    let icon: String
    let message: String
    var type: BannerType = .info
    
    enum BannerType {
        case info, success, warning, error
        
        var color: Color {
            switch self {
            case .info: return AppColors.info
            case .success: return AppColors.success
            case .warning: return AppColors.warning
            case .error: return AppColors.error
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(type.color)
            
            Text(message)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
        .padding()
        .background(type.color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Animated Check
struct AnimatedCheck: View {
    @State private var isChecked = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.success.opacity(0.2))
                .frame(width: 80, height: 80)
            
            Circle()
                .fill(AppColors.success)
                .frame(width: 60, height: 60)
            
            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(isChecked ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2)) {
                isChecked = true
            }
        }
    }
}

// MARK: - Rating Stars
struct RatingStars: View {
    let rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 16
    var color: Color = AppColors.warning
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - Interactive Rating
struct InteractiveRating: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        rating = index
                    }
                }) {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: size))
                        .foregroundColor(AppColors.warning)
                        .scaleEffect(index <= rating ? 1.1 : 1)
                }
            }
        }
    }
}

// MARK: - Pulsing Dot
struct PulsingDot: View {
    @State private var isPulsing = false
    var color: Color = AppColors.success
    var size: CGFloat = 8
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: size * 2, height: size * 2)
                .scaleEffect(isPulsing ? 1.5 : 1)
                .opacity(isPulsing ? 0 : 1)
            
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.5),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2) * phase)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Skeleton Loading
struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 20
    var cornerRadius: CGFloat = 8
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColors.neutral200)
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Pet Card Skeleton
struct PetCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(height: 140, cornerRadius: 12)
            
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(width: 100, height: 16)
                SkeletonView(width: 80, height: 12)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    var color: Color = AppColors.primary700
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Snackbar
struct Snackbar: View {
    let message: String
    var icon: String?
    var type: SnackbarType = .info
    
    enum SnackbarType {
        case info, success, error
        
        var color: Color {
            switch self {
            case .info: return AppColors.neutral800
            case .success: return AppColors.success
            case .error: return AppColors.error
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            
            Text(message)
                .font(AppFonts.bodySmall)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(type.color)
        .cornerRadius(12)
        .shadow(color: AppShadows.medium, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: 4) {
                    Circle()
                        .fill(step <= currentStep ? AppColors.primary700 : AppColors.neutral300)
                        .frame(width: step == currentStep ? 12 : 8, height: step == currentStep ? 12 : 8)
                    
                    if step < totalSteps {
                        Rectangle()
                            .fill(step < currentStep ? AppColors.primary700 : AppColors.neutral300)
                            .frame(height: 2)
                    }
                }
            }
        }
    }
}

// MARK: - Countdown Timer
struct CountdownTimer: View {
    let targetDate: Date
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 16) {
            TimeComponent(value: days, label: "Days")
            TimeComponent(value: hours, label: "Hours")
            TimeComponent(value: minutes, label: "Min")
            TimeComponent(value: seconds, label: "Sec")
        }
        .onReceive(timer) { _ in
            timeRemaining = targetDate.timeIntervalSince(Date())
        }
    }
    
    var days: Int { Int(timeRemaining) / 86400 }
    var hours: Int { (Int(timeRemaining) % 86400) / 3600 }
    var minutes: Int { (Int(timeRemaining) % 3600) / 60 }
    var seconds: Int { Int(timeRemaining) % 60 }
}

struct TimeComponent: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", max(0, value)))
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
                .monospacedDigit()
            
            Text(label)
                .font(AppFonts.captionSmall)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(width: 50)
        .padding(.vertical, 8)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(8)
    }
}

// MARK: - Haptic Feedback
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Preview
struct Components_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                LoadingView()
                
                BadgeView(text: "Popular")
                
                IconBadge(icon: "star.fill")
                
                DividerWithText(text: "OR")
                
                InfoBanner(icon: "info.circle", message: "This is an info message")
                
                AnimatedCheck()
                
                RatingStars(rating: 4)
                
                PulsingDot()
                
                StepIndicator(currentStep: 2, totalSteps: 4)
                
                Snackbar(message: "Booking confirmed!", icon: "checkmark.circle.fill", type: .success)
            }
            .padding()
        }
    }
}

// MARK: - Decoration Image (Shared SVG/Image Component)
struct DecorationImage: View {
    let name: String
    let fallbackIcon: String
    
    var body: some View {
        Group {
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback to a subtle icon if SVG not found
                Image(systemName: fallbackIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(AppColors.primary300)
            }
        }
    }
}

// MARK: - Rounded Corner Shape (for partial corner radius)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - View Extension for Corner Radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Paw Shape
struct PawShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Main pad (bottom large oval)
        let mainPadCenter = CGPoint(x: w * 0.5, y: h * 0.65)
        path.addEllipse(in: CGRect(
            x: mainPadCenter.x - w * 0.3,
            y: mainPadCenter.y - h * 0.22,
            width: w * 0.6,
            height: h * 0.4
        ))
        
        // Top left toe
        path.addEllipse(in: CGRect(
            x: w * 0.12, y: h * 0.25,
            width: w * 0.22, height: h * 0.28
        ))
        
        // Top right toe
        path.addEllipse(in: CGRect(
            x: w * 0.66, y: h * 0.25,
            width: w * 0.22, height: h * 0.28
        ))
        
        // Middle left toe
        path.addEllipse(in: CGRect(
            x: w * 0.25, y: h * 0.08,
            width: w * 0.2, height: h * 0.26
        ))
        
        // Middle right toe
        path.addEllipse(in: CGRect(
            x: w * 0.55, y: h * 0.08,
            width: w * 0.2, height: h * 0.26
        ))
        
        return path
    }
}
