//
//  HomeView_Enhanced.swift
//  CocoPetParadise
//
//  Premium Home screen with sophisticated animations and mature UI/UX
//  Inspired by Instagram, Airbnb, and Apple design systems
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var chatManager: ChatManager
    @Binding var showChat: Bool
    @State private var animateBackground = false
    @State private var animateContent = false
    @State private var animateDecorations = false
    @State private var showBooking = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium animated background
                PremiumHomeBackground(isAnimating: $animateBackground, scrollOffset: 0)
                
                // Floating decorations
                PremiumFloatingDecorations(animate: $animateDecorations)
                
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero section
                        PremiumHeroSection(animateContent: $animateContent)
                        
                        // Quick stats
                        PremiumQuickStatsCard()
                            .padding(.horizontal, 20)
                            .padding(.top, -30)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateContent)
                        
                        // Quick actions
                        PremiumQuickActionsSection(showBooking: $showBooking, showChat: $showChat)
                            .padding(.top, 24)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateContent)
                        
                        // Featured pets
                        PremiumFeaturedPetsCarousel()
                            .padding(.top, 24)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: animateContent)
                        
                        // Book now CTA
                        PremiumBookNowCTASection(showBooking: $showBooking)
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: animateContent)
                        
                        Spacer(minLength: 120)
                    }
                }
            }
            .sheet(isPresented: $showBooking) {
                BookingView()
            }
        }
        .onAppear {
            animateBackground = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                animateContent = true
                animateDecorations = true
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Premium Hero Section
struct PremiumHeroSection: View {
    @Binding var animateContent: Bool
    @State private var logoFloat: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 55)
            
            HStack(spacing: 16) {
                // Elegant logo container
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .shadow(color: AppColors.primary700.opacity(0.12), radius: 15, x: 0, y: 6)
                    
                    LogoImage(name: "inner-logo", size: 64)
                        .clipShape(Circle())
                        .offset(y: logoFloat)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    // Greeting
                    Text(greetingText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text("Welcome Back!")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Your pets' home away from home")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 1)
                }
                
                Spacer()
                
                // Notification bell
                NotificationBellButton()
            }
            .padding(.horizontal, 20)
            .opacity(animateContent ? 1 : 0)
            .offset(x: animateContent ? 0 : -20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateContent)
            
            Spacer().frame(height: 55)
        }
        .frame(height: 190)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                logoFloat = -5
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning ☀️"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night 🌙"
        }
    }
}

// MARK: - Notification Bell Button
struct NotificationBellButton: View {
    @State private var hasNotifications = true
    @State private var bellRotation: Double = 0
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            // Shake animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                bellRotation = 15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                    bellRotation = -15
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    bellRotation = 0
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(color: AppColors.primary700.opacity(0.08), radius: 8, x: 0, y: 4)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textPrimary)
                    .rotationEffect(.degrees(bellRotation))
                
                // Notification dot
                if hasNotifications {
                    Circle()
                        .fill(AppColors.error)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 12, y: -12)
                }
            }
            .frame(width: 44, height: 44)
        }
    }
}

// MARK: - Premium Quick Stats Card
struct PremiumQuickStatsCard: View {
    @State private var catCount: Int = 0
    @State private var dogCount: Int = 0
    @State private var ratingValue: Double = 0
    
    var body: some View {
        HStack(spacing: 0) {
            PremiumStatItem(
                icon: "cat.fill",
                value: "\(catCount)",
                label: "Cats",
                color: AppColors.primary700
            )
            
            PremiumStatDivider()
            
            PremiumStatItem(
                icon: "dog.fill",
                value: "\(dogCount)",
                label: "Dogs",
                color: AppColors.primary600
            )
            
            PremiumStatDivider()
            
            PremiumStatItem(
                icon: "star.fill",
                value: String(format: "%.1f", ratingValue),
                label: "Rating",
                color: AppColors.warning
            )
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.1), radius: 20, x: 0, y: 8)
        )
        .onAppear {
            animateCounter(to: 13, duration: 0.6) { catCount = $0 }
            animateCounter(to: 11, duration: 0.6) { dogCount = $0 }
            animateRating(to: 5.0, duration: 0.8) { ratingValue = $0 }
        }
    }
    
    private func animateCounter(to target: Int, duration: Double, update: @escaping (Int) -> Void) {
        let steps = 15
        let stepDuration = duration / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                update(Int(Double(target) * Double(i) / Double(steps)))
            }
        }
    }
    
    private func animateRating(to target: Double, duration: Double, update: @escaping (Double) -> Void) {
        let steps = 20
        let stepDuration = duration / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                update(target * Double(i) / Double(steps))
            }
        }
    }
}

struct PremiumStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .monospacedDigit()
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PremiumStatDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.neutral200)
            .frame(width: 1, height: 45)
    }
}

// MARK: - Premium Quick Actions Section
struct PremiumQuickActionsSection: View {
    @Binding var showBooking: Bool
    @Binding var showChat: Bool
    @EnvironmentObject var chatManager: ChatManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                PremiumQuickActionCard(
                    icon: "calendar.badge.plus",
                    title: "Book Now",
                    subtitle: "Reserve a spot",
                    color: AppColors.primary700
                ) {
                    showBooking = true
                }
                
                PremiumQuickActionCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Chat with Us",
                    subtitle: chatManager.unreadCount > 0 ? "\(chatManager.unreadCount) new" : "Get help",
                    color: AppColors.info,
                    badge: chatManager.unreadCount
                ) {
                    showChat = true
                }
                
                NavigationLink(destination: PetsView()) {
                    PremiumQuickActionCardContent(
                        icon: "pawprint.fill",
                        title: "Our Pets",
                        subtitle: "Meet the family",
                        color: AppColors.primary600
                    )
                }
                
                NavigationLink(destination: ServicesView()) {
                    PremiumQuickActionCardContent(
                        icon: "sparkles",
                        title: "Services",
                        subtitle: "View prices",
                        color: AppColors.warning
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct PremiumQuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var badge: Int = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            action()
        }) {
            PremiumQuickActionCardContent(
                icon: icon,
                title: title,
                subtitle: subtitle,
                color: color,
                badge: badge
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PremiumQuickActionCardContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var badge: Int = 0
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }
                
                // Badge
                if badge > 0 {
                    ZStack {
                        Circle()
                            .fill(AppColors.error)
                            .frame(width: 20, height: 20)
                        
                        Text("\(min(badge, 9))\(badge > 9 ? "+" : "")")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: -4)
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(badge > 0 ? color : AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Premium Featured Pets Carousel
struct PremiumFeaturedPetsCarousel: View {
    @EnvironmentObject var petDataManager: PetDataManager
    
    var featuredPets: [Pet] {
        Array(petDataManager.pets.prefix(6))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Meet Our Furry Friends")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: PetsView()) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primary600)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(featuredPets.enumerated()), id: \.element.id) { index, pet in
                        NavigationLink(destination: PetsView()) {
                            PremiumFeaturedPetCard(pet: pet, index: index)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }
}

struct PremiumFeaturedPetCard: View {
    let pet: Pet
    let index: Int
    @State private var isPressed = false
    
    var cardGradient: LinearGradient {
        let colors: [[Color]] = [
            [Color(hex: "FFE5E5"), Color(hex: "FFF0F0")],
            [Color(hex: "E5F0FF"), Color(hex: "F0F5FF")],
            [Color(hex: "FFF5E5"), Color(hex: "FFFAF0")],
            [Color(hex: "E5FFE5"), Color(hex: "F0FFF0")],
            [Color(hex: "F5E5FF"), Color(hex: "FAF0FF")],
            [Color(hex: "FFE5F5"), Color(hex: "FFF0FA")]
        ]
        let colorSet = colors[index % colors.count]
        return LinearGradient(colors: colorSet, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Rectangle()
                        .fill(cardGradient)
                        .frame(width: 155, height: 155)
                    
                    if let uiImage = UIImage(named: pet.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 155, height: 155)
                            .clipped()
                    } else {
                        Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.primary400.opacity(0.5))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Pet type badge
                HStack(spacing: 4) {
                    Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                        .font(.system(size: 9, weight: .semibold))
                    Text(pet.type == .cat ? "Cat" : "Dog")
                        .font(.system(size: 9, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(pet.type == .cat ? AppColors.primary600 : Color(hex: "FF6B6B"))
                )
                .padding(8)
            }
            
            // Info section
            VStack(alignment: .leading, spacing: 6) {
                Text(pet.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(pet.breed)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
                // Personality tags
                HStack(spacing: 4) {
                    ForEach(pet.personality.prefix(2), id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(AppColors.primary700)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(AppColors.primary100)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .frame(width: 155)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 1.02 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Premium Book Now CTA Section
struct PremiumBookNowCTASection: View {
    @Binding var showBooking: Bool
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatingOffset: CGFloat = 0
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Main CTA button
            Button(action: {
                showBooking = true
                HapticManager.impact(.medium)
            }) {
                ZStack {
                    // Base gradient
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary600, AppColors.primary700, AppColors.primary800],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Subtle decorative elements
                    GeometryReader { geo in
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 120, height: 120)
                            .offset(x: geo.size.width - 40, y: -40)
                        
                        Circle()
                            .fill(Color.white.opacity(0.04))
                            .frame(width: 80, height: 80)
                            .offset(x: -25, y: geo.size.height - 25)
                    }
                    
                    // Content
                    HStack(spacing: 18) {
                        // Icon with subtle pulse
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                .frame(width: 58, height: 58)
                                .scaleEffect(pulseScale)
                                .opacity(2 - pulseScale)
                            
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: floatingOffset)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ready to Book?")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Reserve your pet's paradise stay")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        
                        Spacer()
                        
                        // Arrow
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(14)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .frame(height: 100)
                .shadow(color: AppColors.primary700.opacity(0.35), radius: 20, x: 0, y: 10)
                .scaleEffect(isPressed ? 0.98 : 1)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPressed = pressing
                }
            }, perform: {})
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                    pulseScale = 1.4
                }
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    floatingOffset = -4
                }
            }
            
            // Pricing info card
            PremiumPricingInfoCard()
        }
    }
}

struct PremiumPricingInfoCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                // Cat pricing
                PricingItem(
                    icon: "cat.fill",
                    iconColor: AppColors.primary600,
                    iconBgColor: AppColors.primary100,
                    label: "Cat Boarding",
                    price: "$25/night"
                )
                
                Spacer()
                
                Rectangle()
                    .fill(AppColors.neutral200)
                    .frame(width: 1, height: 40)
                
                Spacer()
                
                // Dog pricing
                PricingItem(
                    icon: "dog.fill",
                    iconColor: Color(hex: "FF6B6B"),
                    iconBgColor: Color(hex: "FFE5E5"),
                    label: "Dog Boarding",
                    price: "$40-60/night"
                )
            }
            .padding(.horizontal, 16)
            
            // Footer note
            Text("Price varies by size • Meals, playtime & daily updates included")
                .font(.system(size: 11))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
    }
}

struct PricingItem: View {
    let icon: String
    let iconColor: Color
    let iconBgColor: Color
    let label: String
    let price: String
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconBgColor)
                    .frame(width: 38, height: 38)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(price)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
    }
}

// MARK: - Premium Home Background
struct PremiumHomeBackground: View {
    @Binding var isAnimating: Bool
    var scrollOffset: CGFloat = 0  // Keep for compatibility but unused
    
    var body: some View {
        ZStack {
            // Base gradient - soft and elegant
            LinearGradient(
                colors: [
                    AppColors.primary100.opacity(0.6),
                    AppColors.primary50.opacity(0.3),
                    AppColors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle animated orbs
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.primary200.opacity(0.4),
                                AppColors.primary100.opacity(0)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(x: -80, y: -40 + (isAnimating ? 20 : 0))
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.primary300.opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 40)
                    .offset(x: geo.size.width - 100, y: 200 + (isAnimating ? -15 : 15))
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Premium Floating Decorations
struct PremiumFloatingDecorations: View {
    @Binding var animate: Bool
    @State private var floatOffset1: CGFloat = 0
    @State private var floatOffset2: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            DecorationImage(name: "left-decoration", fallbackIcon: "leaf.fill")
                .frame(width: 180, height: 180)
                .opacity(0.55)
                .rotationEffect(.degrees(-25))
                .offset(x: -40, y: -30 + floatOffset1)
            
            DecorationImage(name: "testimonials-decoration", fallbackIcon: "leaf.fill")
                .frame(width: 160, height: 160)
                .opacity(0.5)
                .offset(x: geo.size.width - 120, y: 20 + floatOffset2)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                floatOffset1 = 12
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(0.5)) {
                floatOffset2 = 10
            }
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showChat: .constant(false))
            .environmentObject(AppState())
            .environmentObject(PetDataManager())
            .environmentObject(BookingManager())
            .environmentObject(NotificationManager())
            .environmentObject(ChatManager())
    }
}
