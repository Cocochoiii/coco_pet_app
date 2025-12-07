//
//  SplashScreen_Enhanced.swift
//  CocoPetParadise
//
//  Premium cinematic splash screen with sophisticated animations
//

import SwiftUI

// MARK: - Logo Image Component (Reusable)
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

// MARK: - Floating Particle
struct FloatingParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
    var delay: Double
}

// MARK: - Particle System View
struct ParticleSystemView: View {
    @State private var particles: [FloatingParticle] = []
    @State private var animate = false
    let particleCount: Int
    
    init(particleCount: Int = 20) {
        self.particleCount = particleCount
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.primary400.opacity(particle.opacity),
                                    AppColors.primary300.opacity(particle.opacity * 0.5)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size / 2
                            )
                        )
                        .frame(width: particle.size, height: particle.size)
                        .blur(radius: particle.size * 0.15)
                        .position(
                            x: particle.x,
                            y: animate ? particle.y - 100 : particle.y + 100
                        )
                        .animation(
                            .easeInOut(duration: particle.speed)
                            .repeatForever(autoreverses: true)
                            .delay(particle.delay),
                            value: animate
                        )
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
                animate = true
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            FloatingParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 20...80),
                opacity: Double.random(in: 0.1...0.3),
                speed: Double.random(in: 4...8),
                delay: Double.random(in: 0...2)
            )
        }
    }
}

// MARK: - Animated Gradient Ring
struct AnimatedGradientRing: View {
    let size: CGFloat
    let lineWidth: CGFloat
    @State private var rotation: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        ZStack {
            // Base ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            AppColors.primary200,
                            AppColors.primary400,
                            AppColors.primary600,
                            AppColors.primary400,
                            AppColors.primary200
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
            
            // Shimmer overlay
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: lineWidth
                )
                .frame(width: size, height: size)
                .mask(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 60)
                        .offset(x: shimmerOffset)
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
    }
}

// MARK: - Glassmorphism Card
struct GlassmorphismCard: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(.ultraThinMaterial)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: AppColors.primary700.opacity(0.1), radius: 30, x: 0, y: 15)
    }
}

// MARK: - Enhanced Splash Screen
struct SplashScreen: View {
    var onComplete: (() -> Void)? = nil
    
    @State private var isActive = false
    @State private var phase = 0
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var logoRotation: Double = -10
    @State private var showRings = false
    @State private var showText = false
    @State private var textOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var floatingOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @State private var currentPawPhase: Int = 0
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let pawTimer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Layered gradient background
            backgroundView
            
            // Particle system
            ParticleSystemView(particleCount: 15)
                .opacity(0.8)
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Logo section
                logoSection
                    .padding(.bottom, 40)
                
                // Text section
                textSection
                
                Spacer()
                
                // Loading section
                loadingSection
            }
        }
        .onAppear {
            impactFeedback.prepare()
            startAnimationSequence()
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    AppColors.primary50,
                    AppColors.background,
                    AppColors.primary100.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Mesh gradient effect
            GeometryReader { geo in
                ZStack {
                    // Top left orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.primary200.opacity(0.6),
                                    AppColors.primary100.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(x: -100, y: -50)
                        .blur(radius: 40)
                    
                    // Bottom right orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.primary300.opacity(0.5),
                                    AppColors.primary200.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 250, height: 250)
                        .offset(x: geo.size.width - 100, y: geo.size.height - 250)
                        .blur(radius: 30)
                    
                    // Center subtle orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.primary100.opacity(0.4),
                                    AppColors.primary50.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.4)
                        .blur(radius: 50)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(AppColors.primary300.opacity(0.3 * glowOpacity))
                .frame(width: 250, height: 250)
                .blur(radius: 40)
            
            // Animated rings
            if showRings {
                // Ring 1
                AnimatedGradientRing(size: 220, lineWidth: 3)
                    .opacity(0.6)
                
                // Ring 2
                AnimatedGradientRing(size: 200, lineWidth: 2)
                    .opacity(0.4)
                    .rotationEffect(.degrees(180))
            }
            
            // Glassmorphism container
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.9),
                                AppColors.primary50.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 175, height: 175)
                
                // Inner white border
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.8),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 175, height: 175)
            }
            .shadow(color: AppColors.primary700.opacity(0.2), radius: 30, x: 0, y: 15)
            
            // Logo
            LogoImage(name: "inner-logo", size: 160)
                .clipShape(Circle())
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .rotationEffect(.degrees(logoRotation))
                .offset(y: floatingOffset)
        }
    }
    
    // MARK: - Text Section
    private var textSection: some View {
        VStack(spacing: 16) {
            // Main title
            Text("Coco's Pet Paradise")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.primary700, AppColors.primary800],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(textOpacity)
                .scaleEffect(showText ? 1 : 0.9)
            
            // Tagline with letter spacing
            Text("PREMIUM PET CARE")
                .font(.system(size: 14, weight: .semibold))
                .tracking(4)
                .foregroundColor(AppColors.textSecondary)
                .opacity(taglineOpacity)
                .offset(y: taglineOpacity == 1 ? 0 : 10)
        }
    }
    
    // MARK: - Loading Section
    private var loadingSection: some View {
        VStack(spacing: 20) {
            // Animated paw prints in a pill container
            HStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { index in
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary600)
                        .opacity(pawPrintOpacity(for: index))
                        .scaleEffect(pawPrintScale(for: index))
                        .offset(y: pawPrintOffset(for: index))
                        .animation(.easeInOut(duration: 0.3), value: currentPawPhase)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: AppColors.primary700.opacity(0.12), radius: 15, x: 0, y: 6)
            )
            .opacity(taglineOpacity)
            
            // Elegant loading text
            Text("Preparing your paradise...")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .opacity(taglineOpacity * 0.9)
        }
        .padding(.bottom, 100)
        .onReceive(pawTimer) { _ in
            if showText {
                currentPawPhase = (currentPawPhase + 1) % 4
            }
        }
    }
    
    // Paw print animation helpers
    private func pawPrintOpacity(for index: Int) -> Double {
        let phase = (currentPawPhase - index + 4) % 4
        switch phase {
        case 0: return 1.0
        case 1: return 0.6
        case 2: return 0.35
        default: return 0.2
        }
    }
    
    private func pawPrintScale(for index: Int) -> CGFloat {
        let phase = (currentPawPhase - index + 4) % 4
        switch phase {
        case 0: return 1.15
        case 1: return 1.0
        default: return 0.85
        }
    }
    
    private func pawPrintOffset(for index: Int) -> CGFloat {
        let phase = (currentPawPhase - index + 4) % 4
        return phase == 0 ? -5 : 0
    }
    
    // MARK: - Animation Sequence
    private func startAnimationSequence() {
        // Phase 1: Logo entrance with spring
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
            logoScale = 1.0
            logoOpacity = 1.0
            logoRotation = 0
        }
        
        // Haptic feedback on logo appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            impactFeedback.impactOccurred()
        }
        
        // Phase 2: Rings appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                showRings = true
                glowOpacity = 1.0
            }
        }
        
        // Phase 3: Text reveals
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showText = true
                textOpacity = 1.0
            }
        }
        
        // Phase 4: Tagline and loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                taglineOpacity = 1.0
            }
        }
        
        // Continuous floating animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                floatingOffset = -10
            }
        }
        
        // Complete after all animations finish (3.5 seconds total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onComplete?()
        }
    }
}

// MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
