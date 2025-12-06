//
//  SplashScreen.swift
//  CocoPetParadise
//
//  Elegant loading screen with custom logo support
//

import SwiftUI

struct SplashScreen: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var showPulse = false
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Elegant gradient background
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
            
            // Subtle floating shapes
            GeometryReader { geo in
                Circle()
                    .fill(AppColors.primary200.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -50, y: floatingOffset + 50)
                
                Circle()
                    .fill(AppColors.primary300.opacity(0.2))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(x: geo.size.width - 120, y: geo.size.height - 300 - floatingOffset)
            }
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Logo container
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(AppColors.primary300.opacity(0.2), lineWidth: 1)
                        .frame(width: 160, height: 160)
                        .scaleEffect(showPulse ? 1.4 : 1)
                        .opacity(showPulse ? 0 : 0.6)
                    
                    // Inner ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primary400, AppColors.primary200],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 130, height: 130)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                    
                    // Logo glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.primary200.opacity(0.5), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .opacity(logoOpacity)
                    
                    // Logo Image - Add "app-logo" to Assets.xcassets
                    LogoImage(name: "app-logo", size: 80)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
                .offset(y: floatingOffset * 0.3)
                
                Spacer().frame(height: 40)
                
                // App name
                VStack(spacing: 8) {
                    Text("Coco's Pet Paradise")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Premium Pet Care")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .tracking(1)
                }
                .opacity(textOpacity)
                .offset(y: textOpacity == 1 ? 0 : 15)
                
                Spacer()
                
                // Elegant loading dots
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(AppColors.primary500)
                            .frame(width: 8, height: 8)
                            .opacity(textOpacity)
                            .scaleEffect(showPulse ? 1 : 0.6)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                                value: showPulse
                            )
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            logoScale = 1
            logoOpacity = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                ringScale = 1
                ringOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.5)) {
                textOpacity = 1
            }
            showPulse = true
        }
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            floatingOffset = 15
        }
    }
}

// MARK: - Logo Image Component
struct LogoImage: View {
    let name: String
    let size: CGFloat
    
    var body: some View {
        Group {
            if UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback - shows when "app-logo" not in Assets
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary700, AppColors.primary600],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: size * 0.45))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
