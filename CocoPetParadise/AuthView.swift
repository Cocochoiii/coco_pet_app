//
//  AuthView_Enhanced.swift
//  CocoPetParadise
//
//  Premium authentication screens with modern UI/UX patterns
//  Inspired by Instagram, Tinder, and Airbnb design systems
//

import SwiftUI
import PhotosUI
import LocalAuthentication

// MARK: - Main Auth View
struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSignIn = true
    @State private var animateBackground = false
    @State private var animateContent = false
    @State private var showSuccessOverlay = false
    @State private var userName = ""
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Animated background
            AuthBackground(isAnimating: $animateBackground)
            
            // Main content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with logo
                    AuthHeader(animate: $animateContent, isSignIn: isSignIn)
                        .padding(.top, 40)
                    
                    // Auth card with glass effect
                    VStack(spacing: 0) {
                        // Premium tab switcher
                        PremiumTabSwitcher(isSignIn: $isSignIn)
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                        
                        // Form content
                        if isSignIn {
                            SignInForm(
                                showSuccessOverlay: $showSuccessOverlay,
                                userName: $userName
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                        } else {
                            SignUpForm(
                                showSuccessOverlay: $showSuccessOverlay,
                                userName: $userName
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .background(
                        ZStack {
                            // Glass effect
                            RoundedRectangle(cornerRadius: 32)
                                .fill(.ultraThinMaterial)
                            
                            // White overlay for readability
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white.opacity(0.85))
                            
                            // Border
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: AppColors.primary700.opacity(0.08), radius: 40, x: 0, y: 20)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 40)
                    
                    // Social login
                    PremiumSocialLoginSection(
                        showSuccessOverlay: $showSuccessOverlay,
                        userName: $userName
                    )
                    .padding(.top, 28)
                    .opacity(animateContent ? 1 : 0)
                    
                    // Footer
                    footerView
                        .padding(.top, 24)
                        .opacity(animateContent ? 1 : 0)
                    
                    Spacer(minLength: 40)
                }
                .padding(.bottom, keyboardHeight)
            }
            .blur(radius: showSuccessOverlay ? 10 : 0)
            
            // Success overlay
            if showSuccessOverlay {
                PremiumSuccessOverlay(userName: userName)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(100)
            }
        }
        .onAppear {
            animateBackground = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    animateContent = true
                }
            }
        }
        .onChange(of: showSuccessOverlay) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                        appState.isAuthenticated = true
                    }
                }
            }
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 8) {
            Text("By continuing, you agree to our")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textTertiary)
            
            HStack(spacing: 4) {
                Button("Terms of Service") {}
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.primary600)
                
                Text("and")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
                
                Button("Privacy Policy") {}
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.primary600)
            }
        }
    }
}

// MARK: - Premium Success Overlay
struct PremiumSuccessOverlay: View {
    let userName: String
    @State private var showContent = false
    @State private var circleScale: CGFloat = 0
    @State private var iconScale: CGFloat = 0
    @State private var particlesActive = false
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {}
            
            // Celebration particles
            if particlesActive {
                CelebrationParticles()
            }
            
            // Main card
            VStack(spacing: 28) {
                // Success icon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(AppColors.success.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .blur(radius: 30)
                        .scaleEffect(circleScale)
                    
                    // Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.success.opacity(0.5), AppColors.success],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(circleScale)
                    
                    // Inner circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.success, AppColors.success.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(circleScale)
                        .shadow(color: AppColors.success.opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(iconScale)
                }
                
                // Text content
                VStack(spacing: 12) {
                    Text("Welcome!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(userName.isEmpty ? "Your pet paradise awaits" : "Hello, \(userName)!")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    
                    // Animated progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                                .scaleEffect(showContent ? 1 : 0.5)
                                .opacity(showContent ? 1 : 0.4)
                                .animation(
                                    .easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.15),
                                    value: showContent
                                )
                        }
                    }
                    .padding(.top, 16)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            .padding(40)
        }
        .onAppear {
            animateSuccess()
        }
    }
    
    private func animateSuccess() {
        // Circle scales up
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            circleScale = 1
        }
        
        // Icon bounces in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                iconScale = 1
            }
            HapticManager.notification(.success)
            particlesActive = true
        }
        
        // Text appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
}

// MARK: - Celebration Particles
struct CelebrationParticles: View {
    @State private var particles: [CelebrationParticle] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
                animateParticles()
            }
        }
        .ignoresSafeArea()
    }
    
    private func createParticles(in size: CGSize) {
        let colors: [Color] = [
            AppColors.primary300, AppColors.primary500, AppColors.primary700,
            AppColors.success, AppColors.warning, .white
        ]
        
        particles = (0..<50).map { _ in
            CelebrationParticle(
                position: CGPoint(x: size.width / 2, y: size.height / 2),
                color: colors.randomElement() ?? AppColors.primary500,
                size: CGFloat.random(in: 4...12),
                velocity: CGPoint(
                    x: CGFloat.random(in: -250...250),
                    y: CGFloat.random(in: -500...(-150))
                ),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeOut(duration: 2.5)) {
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.x
                particles[i].position.y += particles[i].velocity.y + 500
                particles[i].opacity = 0
            }
        }
    }
}

struct CelebrationParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let velocity: CGPoint
    var opacity: Double
}

// MARK: - Auth Background
struct AuthBackground: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    AppColors.primary50,
                    AppColors.background,
                    AppColors.primary100.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated orbs
            GeometryReader { geo in
                // Top orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.primary200.opacity(0.5),
                                AppColors.primary100.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 50)
                    .offset(x: -60, y: isAnimating ? 80 : 120)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Right orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.primary300.opacity(0.4),
                                AppColors.primary200.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: geo.size.width - 80, y: isAnimating ? 180 : 220)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                
                // Bottom orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.primary100.opacity(0.6),
                                AppColors.primary50.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 35)
                    .offset(x: geo.size.width * 0.3, y: geo.size.height - 200)
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: isAnimating)
                
                // Floating paw prints
                ForEach(0..<4, id: \.self) { index in
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: CGFloat.random(in: 18...32)))
                        .foregroundColor(AppColors.primary300.opacity(0.12))
                        .rotationEffect(.degrees(Double.random(in: -25...25)))
                        .offset(
                            x: CGFloat(index * 90) + 20,
                            y: CGFloat(index % 2 == 0 ? 180 : 450) + (isAnimating ? -15 : 15)
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 4...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.4),
                            value: isAnimating
                        )
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Auth Header
struct AuthHeader: View {
    @Binding var animate: Bool
    let isSignIn: Bool
    @State private var logoFloat: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Logo container
            ZStack {
                // Glow
                Circle()
                    .fill(AppColors.primary200.opacity(0.4))
                    .frame(width: 110, height: 110)
                    .blur(radius: 20)
                
                // Glass container
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white, AppColors.primary50],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 95, height: 95)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: AppColors.primary700.opacity(0.15), radius: 20, x: 0, y: 10)
                
                // Logo
                LogoImage(name: "inner-logo", size: 85)
                    .clipShape(Circle())
            }
            .offset(y: logoFloat)
            .scaleEffect(animate ? 1 : 0.7)
            .opacity(animate ? 1 : 0)
            
            // Title section
            VStack(spacing: 8) {
                Text("Coco's Pet Paradise")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(isSignIn ? "Welcome back! We missed you 🐾" : "Join our pet-loving community")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 10)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: animate)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                logoFloat = -8
            }
        }
    }
}

// MARK: - Premium Tab Switcher
struct PremiumTabSwitcher: View {
    @Binding var isSignIn: Bool
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            PremiumTab(title: "Sign In", isSelected: isSignIn, namespace: animation) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isSignIn = true
                }
            }
            
            PremiumTab(title: "Sign Up", isSelected: !isSignIn, namespace: animation) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isSignIn = false
                }
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.neutral100)
        )
    }
}

struct PremiumTab: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            action()
        }) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary500, AppColors.primary700],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "activeTab", in: namespace)
                            .shadow(color: AppColors.primary600.opacity(0.35), radius: 10, x: 0, y: 5)
                    }
                }
        }
    }
}

// MARK: - Sign In Form
struct SignInForm: View {
    @EnvironmentObject var appState: AppState
    @Binding var showSuccessOverlay: Bool
    @Binding var userName: String
    
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showBiometricOption = false
    @FocusState private var focusedField: Field?
    
    enum Field { case email, password }
    
    var isValidForm: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Email field
            PremiumTextField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                keyboardType: .emailAddress
            )
            .focused($focusedField, equals: .email)
            
            // Password field
            PremiumTextField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                isSecure: true
            )
            .focused($focusedField, equals: .password)
            
            // Options row
            HStack {
                // Remember me
                Button(action: {
                    HapticManager.impact(.light)
                    rememberMe.toggle()
                }) {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(rememberMe ? AppColors.primary500 : AppColors.neutral300, lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                            
                            if rememberMe {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppColors.primary500)
                                    .frame(width: 20, height: 20)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rememberMe)
                        
                        Text("Remember me")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                Button("Forgot Password?") {
                    HapticManager.impact(.light)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primary600)
            }
            .padding(.top, 4)
            
            // Error message
            if showError {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.error)
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.error)
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.error.opacity(0.1))
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Sign in button
            PremiumButton(
                title: "Sign In",
                icon: "arrow.right",
                isLoading: isLoading,
                isEnabled: isValidForm
            ) {
                signIn()
            }
            .padding(.top, 8)
            
            // Biometric option
            if canUseBiometrics() {
                Button(action: authenticateWithBiometrics) {
                    HStack(spacing: 10) {
                        Image(systemName: biometricType() == .faceID ? "faceid" : "touchid")
                            .font(.system(size: 20))
                        Text("Use \(biometricType() == .faceID ? "Face ID" : "Touch ID")")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(AppColors.primary600)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppColors.primary400, lineWidth: 1.5)
                    )
                }
            }
        }
        .padding(.top, 24)
    }
    
    private func signIn() {
        focusedField = nil
        isLoading = true
        HapticManager.impact(.medium)
        
        let name = email.components(separatedBy: "@").first?.capitalized ?? "Friend"
        userName = name
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSuccessOverlay = true
            }
        }
    }
    
    private func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private func biometricType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign in to Coco's Pet Paradise") { success, error in
            DispatchQueue.main.async {
                if success {
                    userName = "Pet Lover"
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showSuccessOverlay = true
                    }
                }
            }
        }
    }
}

// MARK: - Sign Up Form
struct SignUpForm: View {
    @EnvironmentObject var appState: AppState
    @Binding var showSuccessOverlay: Bool
    @Binding var userName: String
    
    @State private var currentStep = 1
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var isLoading = false
    
    @State private var profileImage: UIImage?
    @State private var petImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var imagePickerType: ImagePickerType = .profile
    
    enum ImagePickerType { case profile, pet }
    
    var passwordStrength: PasswordStrength {
        PasswordStrength.evaluate(password)
    }
    
    var isStep1Valid: Bool {
        !name.isEmpty && !email.isEmpty && email.contains("@") &&
        !password.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Step indicator
            PremiumStepIndicator(currentStep: currentStep, totalSteps: 2)
                .padding(.top, 8)
            
            if currentStep == 1 {
                step1View
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                step2View
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .padding(.top, 16)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                image: imagePickerType == .profile ? $profileImage : .constant(nil),
                images: imagePickerType == .pet ? $petImages : .constant([]),
                selectionLimit: imagePickerType == .profile ? 1 : max(0, 6 - petImages.count),
                isMultiple: imagePickerType == .pet
            )
        }
    }
    
    // MARK: Step 1
    private var step1View: some View {
        VStack(spacing: 16) {
            PremiumTextField(
                icon: "person.fill",
                placeholder: "Full name",
                text: $name
            )
            
            PremiumTextField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                keyboardType: .emailAddress
            )
            
            PremiumTextField(
                icon: "phone.fill",
                placeholder: "Phone number (optional)",
                text: $phone,
                keyboardType: .phonePad
            )
            
            PremiumTextField(
                icon: "lock.fill",
                placeholder: "Password (min 6 characters)",
                text: $password,
                isSecure: true
            )
            
            // Password strength indicator
            if !password.isEmpty {
                PasswordStrengthView(strength: passwordStrength)
            }
            
            PremiumTextField(
                icon: "lock.shield.fill",
                placeholder: "Confirm password",
                text: $confirmPassword,
                isSecure: true
            )
            
            // Password match indicator
            if !password.isEmpty && !confirmPassword.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(password == confirmPassword ? AppColors.success : AppColors.error)
                    Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(password == confirmPassword ? AppColors.success : AppColors.error)
                    Spacer()
                }
                .padding(.horizontal, 4)
                .transition(.opacity)
            }
            
            PremiumButton(
                title: "Continue",
                icon: "arrow.right",
                isEnabled: isStep1Valid
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentStep = 2
                }
                HapticManager.impact(.medium)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: Step 2
    private var step2View: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 6) {
                Text("Add Photos")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Optional: Personalize your profile")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Profile photo
            VStack(spacing: 12) {
                Text("Profile Photo")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    imagePickerType = .profile
                    showImagePicker = true
                    HapticManager.impact(.light)
                } label: {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppColors.primary400, lineWidth: 3)
                            )
                            .overlay(
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white, AppColors.primary600)
                                    .offset(x: 35, y: 35)
                            )
                    } else {
                        PremiumProfilePlaceholder()
                    }
                }
            }
            
            // Pet photos
            VStack(spacing: 12) {
                HStack {
                    Text("Pet Photos")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(petImages.count)/6")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.neutral100)
                        .cornerRadius(8)
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    if petImages.count < 6 {
                        Button {
                            imagePickerType = .pet
                            showImagePicker = true
                            HapticManager.impact(.light)
                        } label: {
                            PremiumPetAddButton()
                        }
                    }
                    
                    ForEach(Array(petImages.enumerated()), id: \.offset) { index, image in
                        PremiumPetPhotoCell(image: image) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                petImages.remove(at: index)
                            }
                            HapticManager.impact(.light)
                        }
                    }
                }
            }
            
            // Terms checkbox
            Button(action: {
                HapticManager.impact(.light)
                agreeToTerms.toggle()
            }) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(agreeToTerms ? AppColors.primary500 : AppColors.neutral300, lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                        
                        if agreeToTerms {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppColors.primary500)
                                .frame(width: 22, height: 22)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: agreeToTerms)
                    
                    Group {
                        Text("I agree to the ")
                            .foregroundColor(AppColors.textSecondary)
                        + Text("Terms & Privacy Policy")
                            .foregroundColor(AppColors.primary600)
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 13))
                    .multilineTextAlignment(.leading)
                }
            }
            
            // Buttons
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentStep = 1
                    }
                    HapticManager.impact(.light)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.neutral100)
                    .cornerRadius(14)
                }
                
                PremiumButton(
                    title: "Create Account",
                    icon: "checkmark",
                    isLoading: isLoading,
                    isEnabled: agreeToTerms
                ) {
                    signUp()
                }
            }
        }
    }
    
    private func signUp() {
        isLoading = true
        HapticManager.impact(.medium)
        userName = name
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSuccessOverlay = true
            }
        }
    }
}

// MARK: - Password Strength
enum PasswordStrength: Int {
    case weak = 1
    case fair = 2
    case good = 3
    case strong = 4
    
    var color: Color {
        switch self {
        case .weak: return AppColors.error
        case .fair: return AppColors.warning
        case .good: return AppColors.info
        case .strong: return AppColors.success
        }
    }
    
    var label: String {
        switch self {
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }
    
    static func evaluate(_ password: String) -> PasswordStrength {
        var score = 0
        if password.count >= 6 { score += 1 }
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil { score += 1 }
        
        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        default: return .strong
        }
    }
}

struct PasswordStrengthView: View {
    let strength: PasswordStrength
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Progress bars
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(level <= strength.rawValue ? strength.color : AppColors.neutral200)
                        .frame(height: 4)
                }
            }
            
            // Label
            HStack {
                Image(systemName: strength == .strong ? "checkmark.shield.fill" : "shield.fill")
                    .font(.system(size: 12))
                    .foregroundColor(strength.color)
                Text(strength.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(strength.color)
                Spacer()
            }
        }
        .padding(.horizontal, 4)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: strength)
    }
}

// MARK: - Premium Step Indicator
struct PremiumStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: 8) {
                    // Circle
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? AppColors.primary500 : AppColors.neutral200)
                            .frame(width: 30, height: 30)
                        
                        if step < currentStep {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(step)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(step <= currentStep ? .white : AppColors.textSecondary)
                        }
                    }
                    
                    // Label
                    Text(step == 1 ? "Details" : "Photos")
                        .font(.system(size: 13, weight: step <= currentStep ? .semibold : .regular))
                        .foregroundColor(step <= currentStep ? AppColors.textPrimary : AppColors.textTertiary)
                    
                    // Connector
                    if step < totalSteps {
                        Rectangle()
                            .fill(step < currentStep ? AppColors.primary500 : AppColors.neutral200)
                            .frame(height: 2)
                            .frame(maxWidth: 40)
                    }
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
    }
}

// MARK: - Premium Text Field
struct PremiumTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    @State private var showPassword = false
    @State private var isFocused = false
    @FocusState private var fieldFocus: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(isFocused ? AppColors.primary100 : AppColors.neutral100)
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isFocused ? AppColors.primary600 : AppColors.neutral400)
            }
            
            // Field
            Group {
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                        .focused($fieldFocus)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($fieldFocus)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .font(.system(size: 15))
            
            // Password toggle
            if isSecure && !text.isEmpty {
                Button(action: {
                    showPassword.toggle()
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.neutral400)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(
                    color: isFocused ? AppColors.primary300.opacity(0.3) : Color.black.opacity(0.04),
                    radius: isFocused ? 12 : 6,
                    x: 0,
                    y: isFocused ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? AppColors.primary400 : AppColors.neutral200,
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isFocused)
        .onChange(of: fieldFocus) { focused in
            isFocused = focused
        }
    }
}

// MARK: - Premium Button
struct PremiumButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if !isLoading && isEnabled {
                HapticManager.impact(.medium)
                action()
            }
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.85)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                    
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [AppColors.primary500, AppColors.primary700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            colors: [AppColors.neutral300, AppColors.neutral400],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .cornerRadius(16)
            .shadow(
                color: isEnabled ? AppColors.primary600.opacity(isPressed ? 0.2 : 0.4) : Color.clear,
                radius: isPressed ? 6 : 16,
                x: 0,
                y: isPressed ? 3 : 8
            )
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Premium Social Login
struct PremiumSocialLoginSection: View {
    @Binding var showSuccessOverlay: Bool
    @Binding var userName: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Divider
            HStack(spacing: 16) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, AppColors.neutral300],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                
                Text("or")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.neutral300, Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
            }
            .padding(.horizontal, 40)
            
            // Social buttons
            HStack(spacing: 16) {
                PremiumSocialButton(
                    icon: "apple.logo",
                    name: "Apple",
                    bgColor: .black,
                    fgColor: .white
                ) {
                    socialLogin(name: "Apple User")
                }
                
                PremiumSocialButton(
                    icon: "g.circle.fill",
                    name: "Google",
                    bgColor: .white,
                    fgColor: Color(hex: "EA4335")
                ) {
                    socialLogin(name: "Google User")
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func socialLogin(name: String) {
        HapticManager.impact(.medium)
        userName = name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSuccessOverlay = true
            }
        }
    }
}

struct PremiumSocialButton: View {
    let icon: String
    let name: String
    let bgColor: Color
    let fgColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(fgColor)
                
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(bgColor == .white ? AppColors.textPrimary : .white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(bgColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(bgColor == .white ? AppColors.neutral200 : Color.clear, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Photo Components
struct PremiumProfilePlaceholder: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.primary100, AppColors.primary50],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Circle()
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                )
                .foregroundColor(AppColors.primary400)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(animate ? 360 : 0))
            
            VStack(spacing: 6) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primary500)
                
                Text("Add Photo")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.primary600)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

struct PremiumPetAddButton: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [AppColors.primary100, AppColors.primary50],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
                .foregroundColor(AppColors.primary400)
            
            VStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppColors.primary500)
                    .scaleEffect(animate ? 1.1 : 1)
                
                Text("Add Pet")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.primary600)
            }
        }
        .frame(height: 90)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct PremiumPetPhotoCell: View {
    let image: UIImage
    let onDelete: () -> Void
    
    @State private var showDelete = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppColors.primary200, lineWidth: 1)
                )
            
            Button(action: onDelete) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 26, height: 26)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(x: 8, y: -8)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var images: [UIImage]
    var selectionLimit: Int = 1
    var isMultiple: Bool = false
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = isMultiple ? selectionLimit : 1
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            if self.parent.isMultiple {
                                self.parent.images.append(image)
                            } else {
                                self.parent.image = image
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AppState())
    }
}
