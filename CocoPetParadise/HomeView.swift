//
//  HomeView.swift
//  CocoPetParadise
//
//  Simplified Home screen with beautiful animations and custom illustration logo
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
                AnimatedHomeBackground(isAnimating: $animateBackground)
                FloatingDecorations(animate: $animateDecorations)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HomeHeroSection(animateContent: $animateContent)
                        
                        QuickStatsCard()
                            .padding(.horizontal, 20)
                            .padding(.top, -40)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: animateContent)
                        
                        QuickActionsSection(showBooking: $showBooking, showChat: $showChat)
                            .padding(.top, 30)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: animateContent)
                        
                        FeaturedPetsCarousel()
                            .padding(.top, 30)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: animateContent)
                        
                        BookNowCTASection(showBooking: $showBooking)
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6), value: animateContent)
                        
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateContent = true
                animateDecorations = true
            }
        }
    }
}

// MARK: - Home Hero Section (⭐ 使用inner-logo，tagline移到Welcome Back下面)
struct HomeHeroSection: View {
    @Binding var animateContent: Bool
    @State private var logoFloat: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)
            
            // Welcome message with animated logo
            HStack(spacing: 16) {
                // ⭐ 使用inner-logo
                ZStack {
                    Circle()
                        .fill(AppColors.primary100)
                        .frame(width: 80, height: 80)
                        .shadow(color: AppColors.primary700.opacity(0.2), radius: 15, x: 0, y: 8)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white, AppColors.primary50],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    LogoImage(name: "inner-logo", size: 65)
                        .clipShape(Circle())
                        .offset(y: logoFloat)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Welcome Back!")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    // ⭐ Tagline移到这里，紧跟在Welcome Back下面
                    Text("Your pets' home away from home")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .opacity(animateContent ? 1 : 0)
            .offset(x: animateContent ? 0 : -30)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateContent)
            
            Spacer().frame(height: 60)
        }
        .frame(height: 200)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                logoFloat = -5
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
}

// MARK: - Featured Pets Carousel
struct FeaturedPetsCarousel: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @State private var selectedIndex = 0
    
    var featuredPets: [Pet] {
        Array(petDataManager.pets.prefix(6))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Meet Our Furry Friends")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: PetsView()) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primary600)
                }
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(featuredPets.enumerated()), id: \.element.id) { index, pet in
                        NavigationLink(destination: PetsView()) {
                            FeaturedPetCard(pet: pet, index: index)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct FeaturedPetCard: View {
    let pet: Pet
    let index: Int
    @State private var isHovered = false
    
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
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(named: pet.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(cardGradient)
                        .frame(width: 160, height: 160)
                        .overlay(
                            Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.primary400.opacity(0.5))
                        )
                }
                
                HStack(spacing: 4) {
                    Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                        .font(.system(size: 10))
                    Text(pet.type == .cat ? "Cat" : "Dog")
                        .font(.system(size: 10, weight: .semibold))
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text(pet.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(pet.breed)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
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
            .padding(12)
        }
        .frame(width: 160)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: AppColors.primary700.opacity(0.1), radius: 12, x: 0, y: 6)
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }
}

// MARK: - Book Now CTA Section
struct BookNowCTASection: View {
    @Binding var showBooking: Bool
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Button(action: {
                showBooking = true
                HapticManager.impact(.medium)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary500, AppColors.primary600, AppColors.primary700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    GeometryReader { geo in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .offset(x: geo.size.width - 60, y: -50)
                        
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 100, height: 100)
                            .offset(x: -30, y: geo.size.height - 40)
                        
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: CGFloat(16 + index * 4)))
                                .foregroundColor(.white.opacity(0.15))
                                .offset(
                                    x: CGFloat(40 + index * 80),
                                    y: CGFloat(20 + index * 30) + (isAnimating ? -5 : 5)
                                )
                                .animation(
                                    .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                    value: isAnimating
                                )
                        }
                    }
                    
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 70, height: 70)
                                .scaleEffect(pulseScale)
                                .opacity(2 - pulseScale)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: floatingOffset)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Ready to Book?")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Reserve your pet's paradise stay today!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: isAnimating ? 3 : 0)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                .frame(height: 120)
                .shadow(color: AppColors.primary600.opacity(0.5), radius: 25, x: 0, y: 15)
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                isAnimating = true
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    pulseScale = 1.5
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    floatingOffset = -4
                }
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary100)
                                .frame(width: 40, height: 40)
                            Image(systemName: "cat.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.primary600)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cat Boarding")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            Text("$25/night")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(AppColors.neutral200)
                        .frame(width: 1, height: 40)
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FFE5E5"))
                                .frame(width: 40, height: 40)
                            Image(systemName: "dog.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "FF6B6B"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dog Boarding")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            Text("$40-60/night")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Text("Price varies by size • Includes meals, playtime & daily updates")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 5)
            )
        }
    }
}

// MARK: - Animated Home Background
struct AnimatedHomeBackground: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.primary200.opacity(0.6),
                    AppColors.primary100.opacity(0.4),
                    AppColors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.primary300.opacity(0.4), AppColors.primary200.opacity(0.1)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .offset(x: -80, y: isAnimating ? -50 : -80)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.primary400.opacity(0.3), AppColors.primary300.opacity(0.1)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 35)
                    .offset(x: geo.size.width - 100, y: isAnimating ? 200 : 180)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.primary200.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 180
                        )
                    )
                    .frame(width: 350, height: 350)
                    .blur(radius: 50)
                    .offset(x: geo.size.width / 2 - 175, y: geo.size.height - 200 + (isAnimating ? -30 : 0))
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Floating Decorations
struct FloatingDecorations: View {
    @Binding var animate: Bool
    @State private var floatOffset1: CGFloat = 0
    @State private var floatOffset2: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            DecorationImage(name: "left-decoration", fallbackIcon: "leaf.fill")
                .frame(width: 220, height: 220)
                .opacity(0.75)
                .rotationEffect(.degrees(-25))
                .offset(x: -30, y: -20 + floatOffset1)
            
            DecorationImage(name: "testimonials-decoration", fallbackIcon: "leaf.fill")
                .frame(width: 200, height: 200)
                .opacity(0.7)
                .offset(x: geo.size.width - 140, y: 10 + floatOffset2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatOffset1 = 15
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.5)) {
                floatOffset2 = 12
            }
        }
    }
}

// MARK: - Quick Stats Card
struct QuickStatsCard: View {
    @State private var animateStats = false
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(icon: "cat.fill", value: "13", label: "Cats", color: AppColors.primary700)
            
            Divider()
                .frame(height: 40)
                .background(AppColors.neutral200)
            
            StatItem(icon: "dog.fill", value: "11", label: "Dogs", color: AppColors.primary600)
            
            Divider()
                .frame(height: 40)
                .background(AppColors.neutral200)
            
            StatItem(icon: "star.fill", value: "5.0", label: "Rating", color: AppColors.warning)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    @Binding var showBooking: Bool
    @Binding var showChat: Bool
    @EnvironmentObject var chatManager: ChatManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 24)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                QuickActionCard(
                    icon: "calendar.badge.plus",
                    title: "Book Now",
                    subtitle: "Reserve a spot",
                    color: AppColors.primary700
                ) {
                    showBooking = true
                }
                
                QuickActionCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Chat with Us",
                    subtitle: chatManager.unreadCount > 0 ? "\(chatManager.unreadCount) new" : "Get help",
                    color: AppColors.info,
                    badge: chatManager.unreadCount
                ) {
                    showChat = true
                }
                
                NavigationLink(destination: PetsView()) {
                    QuickActionCardContent(
                        icon: "pawprint.fill",
                        title: "Our Pets",
                        subtitle: "Meet the family",
                        color: AppColors.primary600
                    )
                }
                
                NavigationLink(destination: ServicesView()) {
                    QuickActionCardContent(
                        icon: "sparkles",
                        title: "Services",
                        subtitle: "Click to see prices",
                        color: AppColors.primary500
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var badge: Int = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            QuickActionCardContent(icon: icon, title: title, subtitle: subtitle, color: color, badge: badge)
        }
    }
}

struct QuickActionCardContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var badge: Int = 0
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                if badge > 0 {
                    ZStack {
                        Circle()
                            .fill(AppColors.error)
                            .frame(width: 20, height: 20)
                        
                        Text("\(min(badge, 9))\(badge > 9 ? "+" : "")")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 5, y: -5)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(badge > 0 ? color : AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: color.opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .scaleEffect(isPressed ? 0.95 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
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
