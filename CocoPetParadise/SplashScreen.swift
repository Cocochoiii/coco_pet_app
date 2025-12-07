//
//  SplashScreen.swift
//  CocoPetParadise
//
//  Premium splash screen with custom illustration logo
//

import SwiftUI

// MARK: - Logo Image Component (可复用)
struct LogoImage: View {
    let name: String
    let size: CGFloat
    
    var body: some View {
        Group {
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Fallback - 如果图片不存在显示占位符
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary400, AppColors.primary600],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var showRing = false
    @State private var showText = false
    @State private var textOffset: CGFloat = 30
    @State private var floatingOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AppColors.primary100,
                    AppColors.background,
                    AppColors.primary50
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative background circles
            GeometryReader { geo in
                Circle()
                    .fill(AppColors.primary200.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -50, y: 100)
                
                Circle()
                    .fill(AppColors.primary300.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)
                    .offset(x: geo.size.width - 80, y: geo.size.height - 300)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Main logo area - 增大整体尺寸
                ZStack {
                    // Pulse rings - 增大
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(AppColors.primary300.opacity(0.3), lineWidth: 2)
                            .frame(width: 200 + CGFloat(index * 45), height: 200 + CGFloat(index * 45))
                            .scaleEffect(pulseScale)
                            .opacity(2.0 - pulseScale)
                            .animation(
                                .easeOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.4),
                                value: pulseScale
                            )
                    }
                    
                    // Rotating gradient ring - 增大
                    if showRing {
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        AppColors.primary300,
                                        AppColors.primary500,
                                        AppColors.primary700,
                                        AppColors.primary500,
                                        AppColors.primary300
                                    ],
                                    center: .center
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 190, height: 190)
                            .rotationEffect(.degrees(ringRotation))
                    }
                    
                    // White background circle for logo - 增大
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white, AppColors.primary50],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 175, height: 175)
                        .shadow(color: AppColors.primary700.opacity(0.25), radius: 25, x: 0, y: 12)
                    
                    // ⭐ 自定义插画Logo - 增大尺寸到160
                    LogoImage(name: "inner-logo", size: 160)
                        .clipShape(Circle())
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .offset(y: floatingOffset)
                }
                
                // App name and tagline
                VStack(spacing: 12) {
                    // "Paradise" text with gradient
                    Text("Coco's Pet Paradise")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primary600, AppColors.primary800],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Premium Pet Care")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .tracking(2)
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : textOffset)
                
                Spacer()
                
                // Loading indicator
                if showText {
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(AppColors.primary500)
                                .frame(width: 10, height: 10)
                                .scaleEffect(showText ? 1 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: showText
                                )
                        }
                    }
                    .padding(.bottom, 60)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Ring appearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.6)) {
                showRing = true
            }
            
            // Start ring rotation
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
        
        // Text appearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showText = true
            }
        }
        
        // Start floating animation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            floatingOffset = -8
        }
        
        // Start pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pulseScale = 1.5
        }
    }
}

// MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
