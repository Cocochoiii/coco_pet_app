//
//  AuthView.swift
//  CocoPetParadise
//
//  Premium Sign In and Sign Up screens with photo upload
//

import SwiftUI
import PhotosUI

// MARK: - Main Auth View
struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSignIn = true
    @State private var animateBackground = false
    @State private var animateContent = false
    @State private var showSuccessOverlay = false
    @State private var userName = ""
    
    var body: some View {
        ZStack {
            // Animated background
            AuthBackground(isAnimating: $animateBackground)
            
            // Main content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    AuthHeader(animate: $animateContent, isSignIn: isSignIn)
                        .padding(.top, 50)
                    
                    // Auth card
                    VStack(spacing: 0) {
                        // Tab switcher
                        AuthTabSwitcher(isSignIn: $isSignIn)
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                        
                        // Form
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
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 30, x: 0, y: 15)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    
                    // Social login
                    SocialLoginSection(
                        showSuccessOverlay: $showSuccessOverlay,
                        userName: $userName
                    )
                    .padding(.top, 30)
                    .opacity(animateContent ? 1 : 0)
                    
                    Spacer(minLength: 50)
                }
            }
            .blur(radius: showSuccessOverlay ? 10 : 0)
            
            // Success overlay
            if showSuccessOverlay {
                AuthSuccessOverlay(userName: userName)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    .zIndex(100)
            }
        }
        .onAppear {
            animateBackground = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateContent = true
                }
            }
        }
        .onChange(of: showSuccessOverlay) { newValue in
            if newValue {
                // Navigate to home after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                        appState.isAuthenticated = true
                    }
                }
            }
        }
    }
}

// MARK: - Auth Success Overlay (⭐ 使用inner-logo)
struct AuthSuccessOverlay: View {
    let userName: String
    @State private var showCheck = false
    @State private var showText = false
    @State private var showLogo = false
    @State private var logoOffset: CGFloat = 0
    @State private var circleScale: CGFloat = 0
    @State private var ringScale: CGFloat = 0
    @State private var confettiTrigger = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Confetti particles
            if confettiTrigger {
                ConfettiView()
            }
            
            // Main content
            VStack(spacing: 24) {
                // Animated check mark with logo
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primary300, AppColors.primary500],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)
                    
                    // Inner circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary400, AppColors.primary600],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(circleScale)
                        .shadow(color: AppColors.primary500.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    // ⭐ Logo (使用inner-logo替代pawprint)
                    if showLogo {
                        LogoImage(name: "inner-logo", size: 80)
                            .clipShape(Circle())
                            .offset(y: logoOffset)
                    }
                    
                    // Check mark
                    if showCheck {
                        Image(systemName: "checkmark")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Welcome text
                if showText {
                    VStack(spacing: 8) {
                        Text("Welcome!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(userName.isEmpty ? "Let's find your pet's paradise" : "Hello, \(userName)!")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Loading dots
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(.white)
                                    .frame(width: 8, height: 8)
                                    .opacity(0.7)
                                    .scaleEffect(showText ? 1 : 0.5)
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .repeatForever()
                                            .delay(Double(index) * 0.15),
                                        value: showText
                                    )
                            }
                        }
                        .padding(.top, 16)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            animateSequence()
        }
    }
    
    private func animateSequence() {
        // Step 1: Ring appears
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            ringScale = 1
        }
        
        // Step 2: Circle scales up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                circleScale = 1
            }
        }
        
        // Step 3: Logo appears and bounces
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showLogo = true
            logoOffset = -10
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                logoOffset = 0
            }
        }
        
        // Step 4: Logo transforms to check
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showLogo = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    showCheck = true
                }
                HapticManager.notification(.success)
                confettiTrigger = true
            }
        }
        
        // Step 5: Text appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showText = true
            }
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
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
            AppColors.warning, AppColors.success, .white, AppColors.primary200
        ]
        
        particles = (0..<40).map { _ in
            ConfettiParticle(
                position: CGPoint(x: size.width / 2, y: size.height / 2 - 50),
                color: colors.randomElement() ?? AppColors.primary500,
                size: CGFloat.random(in: 6...14),
                velocity: CGPoint(
                    x: CGFloat.random(in: -200...200),
                    y: CGFloat.random(in: -400...(-100))
                ),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeOut(duration: 2.0)) {
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.x
                particles[i].position.y += particles[i].velocity.y + 400
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
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
            LinearGradient(
                colors: [AppColors.primary100, AppColors.background, AppColors.primary50],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(AppColors.primary200.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -50, y: isAnimating ? 100 : 120)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(AppColors.primary300.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)
                    .offset(x: geo.size.width - 100, y: isAnimating ? 200 : 180)
                    .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(AppColors.primary100.opacity(0.4))
                    .frame(width: 100, height: 100)
                    .blur(radius: 40)
                    .offset(x: geo.size.width / 2, y: geo.size.height - 200)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Floating paw prints
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: CGFloat.random(in: 20...40)))
                        .foregroundColor(AppColors.primary300.opacity(0.15))
                        .rotationEffect(.degrees(Double.random(in: -30...30)))
                        .offset(
                            x: CGFloat(index) * 80 + CGFloat.random(in: -20...20),
                            y: CGFloat(index % 2 == 0 ? 150 : 400) + (isAnimating ? 0 : 20)
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...5))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.3),
                            value: isAnimating
                        )
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Auth Header (⭐ 使用inner-logo)
struct AuthHeader: View {
    @Binding var animate: Bool
    let isSignIn: Bool
    @State private var logoFloat: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Logo - 使用inner-logo
            ZStack {
                // Glow effect
                Circle()
                    .fill(AppColors.primary200.opacity(0.5))
                    .frame(width: 110, height: 110)
                    .blur(radius: 15)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white, AppColors.primary50],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 95, height: 95)
                    .shadow(color: AppColors.primary700.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // ⭐ 使用inner-logo替换pawprint
                LogoImage(name: "inner-logo", size: 85)
                    .clipShape(Circle())
            }
            .offset(y: logoFloat)
            .scaleEffect(animate ? 1 : 0.8)
            .opacity(animate ? 1 : 0)
            
            // Title
            VStack(spacing: 8) {
                Text("Coco's Pet Paradise")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(isSignIn ? "Welcome back! Sign in to continue" : "Create your account")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .opacity(animate ? 1 : 0)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                logoFloat = -8
            }
        }
    }
}

// MARK: - Tab Switcher
struct AuthTabSwitcher: View {
    @Binding var isSignIn: Bool
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            AuthTab(title: "Sign In", isSelected: isSignIn, namespace: animation) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    isSignIn = true
                }
            }
            
            AuthTab(title: "Sign Up", isSelected: !isSignIn, namespace: animation) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    isSignIn = false
                }
            }
        }
        .padding(4)
        .background(AppColors.neutral100)
        .cornerRadius(16)
    }
}

struct AuthTab: View {
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
                                    colors: [AppColors.primary600, AppColors.primary700],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "tab", in: namespace)
                            .shadow(color: AppColors.primary600.opacity(0.3), radius: 8, x: 0, y: 4)
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
    @FocusState private var focusedField: Field?
    
    enum Field { case email, password }
    
    var isValidForm: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Email
            EnhancedInputField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                isFocused: focusedField == .email,
                keyboardType: .emailAddress
            )
            .focused($focusedField, equals: .email)
            .onTapGesture { focusedField = .email }
            
            // Password
            EnhancedInputField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                isFocused: focusedField == .password,
                isSecure: true
            )
            .focused($focusedField, equals: .password)
            .onTapGesture { focusedField = .password }
            
            // Remember me & Forgot password
            HStack {
                Button(action: {
                    HapticManager.impact(.light)
                    rememberMe.toggle()
                }) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(rememberMe ? AppColors.primary600 : AppColors.neutral300, lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                            
                            if rememberMe {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppColors.primary600)
                                    .frame(width: 22, height: 22)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("Remember me")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                Button("Forgot Password?") {
                    HapticManager.impact(.light)
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.primary600)
            }
            .padding(.top, 4)
            
            // Error message
            if showError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Sign in button
            GradientButton(
                title: "Sign In",
                icon: "arrow.right",
                isLoading: isLoading,
                isEnabled: isValidForm
            ) {
                signIn()
            }
            .padding(.top, 8)
        }
        .padding(.top, 24)
    }
    
    private func signIn() {
        focusedField = nil
        isLoading = true
        HapticManager.impact(.medium)
        
        // Extract name from email for demo
        let name = email.components(separatedBy: "@").first?.capitalized ?? "Friend"
        userName = name
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSuccessOverlay = true
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
    
    // Photo states
    @State private var profileImage: UIImage?
    @State private var petImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var imagePickerType: ImagePickerType = .profile
    
    enum ImagePickerType {
        case profile
        case pet
    }
    
    var isStep1Valid: Bool {
        !name.isEmpty && !email.isEmpty && email.contains("@") && !password.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Step indicator
            AuthStepIndicator(currentStep: currentStep, totalSteps: 2)
                .padding(.top, 8)
            
            if currentStep == 1 {
                // Step 1: Basic Info
                step1View
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                // Step 2: Photos (Optional)
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
    
    // MARK: Step 1 - Basic Info
    private var step1View: some View {
        VStack(spacing: 16) {
            EnhancedInputField(
                icon: "person.fill",
                placeholder: "Full name",
                text: $name,
                isFocused: false
            )
            
            EnhancedInputField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                isFocused: false,
                keyboardType: .emailAddress
            )
            
            EnhancedInputField(
                icon: "phone.fill",
                placeholder: "Phone number (optional)",
                text: $phone,
                isFocused: false,
                keyboardType: .phonePad
            )
            
            EnhancedInputField(
                icon: "lock.fill",
                placeholder: "Password (min 6 characters)",
                text: $password,
                isFocused: false,
                isSecure: true
            )
            
            EnhancedInputField(
                icon: "lock.shield.fill",
                placeholder: "Confirm password",
                text: $confirmPassword,
                isFocused: false,
                isSecure: true
            )
            
            // Password match indicator
            if !password.isEmpty && !confirmPassword.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(password == confirmPassword ? AppColors.success : .red)
                    Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                        .font(.system(size: 13))
                        .foregroundColor(password == confirmPassword ? AppColors.success : .red)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            
            // Next button
            GradientButton(
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
    
    // MARK: Step 2 - Photos
    private var step2View: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 6) {
                Text("Add Photos")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Optional: Add your profile picture and pet photos")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Profile Photo Section
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
                                    .foregroundColor(AppColors.primary600)
                                    .background(Circle().fill(.white).padding(4))
                                    .offset(x: 35, y: 35)
                            )
                    } else {
                        ProfilePhotoPlaceholder()
                    }
                }
            }
            
            // Pet Photos Section
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
                
                // Pet photos grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    // Add button
                    if petImages.count < 6 {
                        Button {
                            imagePickerType = .pet
                            showImagePicker = true
                            HapticManager.impact(.light)
                        } label: {
                            PetPhotoAddButton()
                        }
                    }
                    
                    // Existing photos
                    ForEach(Array(petImages.enumerated()), id: \.offset) { index, image in
                        PetPhotoCell(image: image) {
                            withAnimation {
                                petImages.remove(at: index)
                            }
                            HapticManager.impact(.light)
                        }
                    }
                }
            }
            
            // Terms
            Button(action: {
                HapticManager.impact(.light)
                agreeToTerms.toggle()
            }) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(agreeToTerms ? AppColors.primary600 : AppColors.neutral300, lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                        
                        if agreeToTerms {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppColors.primary600)
                                .frame(width: 22, height: 22)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Group {
                        Text("I agree to the ")
                            .foregroundColor(AppColors.textSecondary)
                        + Text("Terms of Service")
                            .foregroundColor(AppColors.primary600)
                            .fontWeight(.medium)
                        + Text(" and ")
                            .foregroundColor(AppColors.textSecondary)
                        + Text("Privacy Policy")
                            .foregroundColor(AppColors.primary600)
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 13))
                    .multilineTextAlignment(.leading)
                }
            }
            
            // Buttons
            HStack(spacing: 12) {
                // Back button
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
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.neutral100)
                    .cornerRadius(14)
                }
                
                // Create account button
                GradientButton(
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

// MARK: - Step Indicator
struct AuthStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: 8) {
                    // Step circle
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? AppColors.primary600 : AppColors.neutral200)
                            .frame(width: 28, height: 28)
                        
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
                    
                    // Step label
                    Text(step == 1 ? "Basic Info" : "Photos")
                        .font(.system(size: 13, weight: step <= currentStep ? .semibold : .regular))
                        .foregroundColor(step <= currentStep ? AppColors.textPrimary : AppColors.textSecondary)
                    
                    // Connector line
                    if step < totalSteps {
                        Rectangle()
                            .fill(step < currentStep ? AppColors.primary600 : AppColors.neutral200)
                            .frame(height: 2)
                            .frame(maxWidth: 30)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Profile Photo Placeholder
struct ProfilePhotoPlaceholder: View {
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
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .foregroundColor(AppColors.primary400)
                .frame(width: 100, height: 100)
            
            VStack(spacing: 6) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primary500)
                
                Text("Add")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.primary600)
            }
        }
    }
}

// MARK: - Pet Photo Add Button
struct PetPhotoAddButton: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [AppColors.primary100, AppColors.primary50],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [6, 3])
                )
                .foregroundColor(AppColors.primary400)
            
            VStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppColors.primary500)
                
                Text("Add Pet")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.primary600)
            }
        }
        .frame(height: 90)
    }
}

// MARK: - Pet Photo Cell
struct PetPhotoCell: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .padding(2)
                    )
            }
            .offset(x: 6, y: -6)
        }
    }
}

// MARK: - Enhanced Input Field
struct EnhancedInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    @State private var showPassword = false
    @State private var isActive = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(isActive ? AppColors.primary100 : AppColors.neutral100)
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isActive ? AppColors.primary600 : AppColors.neutral400)
            }
            
            // Text field
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .onTapGesture { isActive = true }
            } else {
                TextField(placeholder, text: $text) { editing in
                    isActive = editing
                }
                .font(.system(size: 15))
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
            }
            
            // Password toggle
            if isSecure {
                Button(action: {
                    showPassword.toggle()
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.neutral400)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(color: isActive ? AppColors.primary300.opacity(0.3) : Color.black.opacity(0.04), radius: isActive ? 8 : 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isActive ? AppColors.primary400 : AppColors.neutral200, lineWidth: isActive ? 1.5 : 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Gradient Button
struct GradientButton: View {
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
                LinearGradient(
                    colors: isEnabled ?
                        [AppColors.primary500, AppColors.primary700] :
                        [AppColors.neutral300, AppColors.neutral400],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: isEnabled ? AppColors.primary600.opacity(isPressed ? 0.2 : 0.4) : Color.clear,
                radius: isPressed ? 5 : 15,
                x: 0,
                y: isPressed ? 2 : 8
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

// MARK: - Social Login Section
struct SocialLoginSection: View {
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
                
                Text("or continue with")
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
            .padding(.horizontal, 30)
            
            // Social buttons
            HStack(spacing: 16) {
                SocialLoginButton(icon: "apple.logo", name: "Apple", iconColor: .black) {
                    socialLogin(name: "Apple User")
                }
                
                SocialLoginButton(icon: "g.circle.fill", name: "Google", iconColor: Color(hex: "EA4335")) {
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

struct SocialLoginButton: View {
    let icon: String
    let name: String
    var iconColor: Color = AppColors.textPrimary
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
                
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.neutral200, lineWidth: 1)
            )
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

// MARK: - Deprecated (Keep for compatibility)
struct AuthInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        EnhancedInputField(
            icon: icon,
            placeholder: placeholder,
            text: $text,
            isFocused: isFocused,
            keyboardType: keyboardType,
            isSecure: isSecure
        )
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        GradientButton(
            title: title,
            icon: icon,
            isLoading: isLoading,
            action: action
        )
    }
}
