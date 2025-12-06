//
//  HomeView.swift
//  CocoPetParadise
//
//  Simplified Home screen with beautiful animations
//  Clean design with quick actions and rich decorations
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
                // Animated background
                AnimatedHomeBackground(isAnimating: $animateBackground)
                
                // Floating SVG decorations
                FloatingDecorations(animate: $animateDecorations)
                
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Section
                        HomeHeroSection(animateContent: $animateContent)
                        
                        // Quick Stats Card
                        QuickStatsCard()
                            .padding(.horizontal, 20)
                            .padding(.top, -40)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: animateContent)
                        
                        // Quick Actions Grid
                        QuickActionsSection(showBooking: $showBooking, showChat: $showChat)
                            .padding(.top, 30)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: animateContent)
                        
                        // Featured Pets Carousel (NEW!)
                        FeaturedPetsCarousel()
                            .padding(.top, 30)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: animateContent)
                        
                        // Strong CTA Section
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

// MARK: - Featured Pets Carousel
struct FeaturedPetsCarousel: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @State private var selectedIndex = 0
    
    var featuredPets: [Pet] {
        Array(petDataManager.pets.prefix(6))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
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
            
            // Carousel
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
            // Pet Image
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
                
                // Type badge
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
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(pet.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(pet.breed)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
                // Personality
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
            // Main CTA Card - Premium Design
            Button(action: {
                showBooking = true
                HapticManager.impact(.medium)
            }) {
                ZStack {
                    // Background with multiple layers
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.primary500,
                                    AppColors.primary600,
                                    AppColors.primary700
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Decorative shapes
                    GeometryReader { geo in
                        // Top right circle
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .offset(x: geo.size.width - 60, y: -50)
                        
                        // Bottom left circle
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 100, height: 100)
                            .offset(x: -30, y: geo.size.height - 40)
                        
                        // Floating paw prints
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
                    
                    // Content
                    HStack(spacing: 16) {
                        // Left side - Icon with glow
                        ZStack {
                            // Pulse ring
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 70, height: 70)
                                .scaleEffect(pulseScale)
                                .opacity(2 - pulseScale)
                            
                            // Main circle
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            
                            // Icon
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: floatingOffset)
                        }
                        
                        // Text content
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
                        
                        // Arrow with animation
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
                
                // Pulse animation
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    pulseScale = 1.5
                }
                
                // Floating animation
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    floatingOffset = -4
                }
            }
            
            // Pricing info card
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Cat pricing
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
                    
                    // Divider
                    Rectangle()
                        .fill(AppColors.neutral200)
                        .frame(width: 1, height: 40)
                    
                    Spacer()
                    
                    // Dog pricing
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
                
                // Note
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

struct TrustBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

struct HighlightTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : AppColors.primary700)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.primary700 : AppColors.primary100)
            )
        }
    }
}

// MARK: - Pet Data for Love Card
struct LovePet: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String      // Asset folder name (e.g., "bibi")
    let breed: String
    let color: Color
    let type: PetType
    let status: PetStatus
    let personality: [String]
    
    enum PetType {
        case cat, dog
        
        var icon: String {
            switch self {
            case .cat: return "cat.fill"
            case .dog: return "dog.fill"
            }
        }
    }
    
    enum PetStatus {
        case resident, boarding
    }
}

// MARK: - Interactive Pet Love Card (点击互动)
struct InteractivePetLoveCard: View {
    @State private var hearts: [HeartParticle] = []
    @State private var petScale: CGFloat = 1.0
    @State private var petRotation: Double = 0
    @State private var showMessage = false
    @State private var tapCount = 0
    @State private var currentPet = 0
    @State private var currentImageIndex = 0
    
    // All 24 pets with their real data from assets
    let pets: [LovePet] = [
        // === CATS (13) ===
        LovePet(
            name: "Bibi",
            imageName: "bibi",
            breed: "Munchkin Silver Shaded",
            color: Color(red: 0.85, green: 0.75, blue: 0.80),
            type: .cat,
            status: .resident,
            personality: ["Playful", "Curious", "Affectionate"]
        ),
        LovePet(
            name: "Dudu",
            imageName: "dudu",
            breed: "British Shorthair Golden",
            color: Color(red: 0.90, green: 0.80, blue: 0.65),
            type: .cat,
            status: .resident,
            personality: ["Gentle", "Calm", "Friendly"]
        ),
        LovePet(
            name: "Fifi",
            imageName: "fifi",
            breed: "Golden British Shorthair",
            color: Color(red: 0.95, green: 0.85, blue: 0.70),
            type: .cat,
            status: .boarding,
            personality: ["Energetic", "Playful", "Adorable"]
        ),
        LovePet(
            name: "Nova",
            imageName: "nova",
            breed: "Golden Retriever",
            color: Color(red: 0.93, green: 0.82, blue: 0.65),
            type: .dog,
            status: .boarding,
            personality: ["Friendly", "Patient", "Loving"]
        ),
        LovePet(
            name: "Loki",
            imageName: "loki",
            breed: "Greyhound",
            color: Color(red: 0.75, green: 0.78, blue: 0.82),
            type: .dog,
            status: .boarding,
            personality: ["Fast", "Gentle", "Calm"]
        ),
        LovePet(
            name: "Nana",
            imageName: "nana",
            breed: "Border Collie",
            color: Color(red: 0.20, green: 0.20, blue: 0.25),
            type: .dog,
            status: .boarding,
            personality: ["Intelligent", "Active", "Loyal"]
        ),
        LovePet(
            name: "Mia",
            imageName: "mia-cat",
            breed: "Ragdoll",
            color: Color(red: 0.90, green: 0.85, blue: 0.88),
            type: .cat,
            status: .boarding,
            personality: ["Affectionate", "Quiet", "Sweet"]
        ),
        LovePet(
            name: "Tutu",
            imageName: "tutu",
            breed: "Siamese",
            color: Color(red: 0.82, green: 0.78, blue: 0.85),
            type: .cat,
            status: .boarding,
            personality: ["Vocal", "Active", "Intelligent"]
        ),
        LovePet(
            name: "Xianbei",
            imageName: "xianbei",
            breed: "Silver Shaded",
            color: Color(red: 0.80, green: 0.82, blue: 0.85),
            type: .cat,
            status: .boarding,
            personality: ["Calm", "Dignified", "Observant"]
        ),
        LovePet(
            name: "Chacha",
            imageName: "chacha",
            breed: "Silver Shaded",
            color: Color(red: 0.82, green: 0.80, blue: 0.78),
            type: .cat,
            status: .boarding,
            personality: ["Friendly", "Curious", "Adaptable"]
        ),
        LovePet(
            name: "Yaya",
            imageName: "yaya",
            breed: "Black Cat",
            color: Color(red: 0.35, green: 0.35, blue: 0.40),
            type: .cat,
            status: .boarding,
            personality: ["Mysterious", "Playful", "Loyal"]
        ),
        LovePet(
            name: "Er Gou",
            imageName: "ergou",
            breed: "Tuxedo Cat",
            color: Color(red: 0.45, green: 0.45, blue: 0.50),
            type: .cat,
            status: .boarding,
            personality: ["Mischievous", "Energetic", "Loving"]
        ),
        LovePet(
            name: "Chouchou",
            imageName: "chouchou",
            breed: "Orange Tabby",
            color: Color(red: 0.95, green: 0.75, blue: 0.55),
            type: .cat,
            status: .boarding,
            personality: ["Laid-back", "Food-loving", "Cuddly"]
        ),
        
        // === DOGS (11) ===
        LovePet(
            name: "Oscar",
            imageName: "oscar",
            breed: "Golden Retriever",
            color: Color(red: 0.92, green: 0.78, blue: 0.55),
            type: .dog,
            status: .boarding,
            personality: ["Puppy Energy", "Friendly", "Eager to Learn"]
        ),
        LovePet(
            name: "Loki",
            imageName: "loki",
            breed: "Greyhound",
            color: Color(red: 0.70, green: 0.68, blue: 0.65),
            type: .dog,
            status: .boarding,
            personality: ["Fast", "Gentle", "Calm Indoors"]
        ),
        LovePet(
            name: "Nana",
            imageName: "nana",
            breed: "Border Collie",
            color: Color(red: 0.40, green: 0.45, blue: 0.50),
            type: .dog,
            status: .boarding,
            personality: ["Intelligent", "Active", "Herding Instinct"]
        ),
        LovePet(
            name: "Richard",
            imageName: "richard",
            breed: "Border Collie",
            color: Color(red: 0.45, green: 0.48, blue: 0.52),
            type: .dog,
            status: .boarding,
            personality: ["Smart", "Energetic", "Focused"]
        ),
        LovePet(
            name: "Tata",
            imageName: "tata",
            breed: "Border Collie",
            color: Color(red: 0.42, green: 0.46, blue: 0.50),
            type: .dog,
            status: .boarding,
            personality: ["Playful", "Alert", "Loyal"]
        ),
        LovePet(
            name: "Caicai",
            imageName: "caicai",
            breed: "Shiba Inu",
            color: Color(red: 0.95, green: 0.75, blue: 0.50),
            type: .dog,
            status: .boarding,
            personality: ["Independent", "Alert", "Spirited"]
        ),
        LovePet(
            name: "Mia",
            imageName: "mia-dog",
            breed: "American Cocker Spaniel",
            color: Color(red: 0.85, green: 0.70, blue: 0.55),
            type: .dog,
            status: .boarding,
            personality: ["Gentle", "Happy", "Affectionate"]
        ),
        LovePet(
            name: "Nova",
            imageName: "nova",
            breed: "Golden Retriever",
            color: Color(red: 0.95, green: 0.82, blue: 0.60),
            type: .dog,
            status: .boarding,
            personality: ["Friendly", "Patient", "Loving"]
        ),
        LovePet(
            name: "Haha",
            imageName: "haha",
            breed: "Samoyed",
            color: Color(red: 0.98, green: 0.98, blue: 0.95),
            type: .dog,
            status: .boarding,
            personality: ["Cheerful", "Friendly", "Fluffy"]
        ),
        LovePet(
            name: "Jiujiu",
            imageName: "jiujiu",
            breed: "Samoyed",
            color: Color(red: 0.96, green: 0.96, blue: 0.92),
            type: .dog,
            status: .boarding,
            personality: ["Gentle", "Playful", "Sweet"]
        ),
        LovePet(
            name: "Toast",
            imageName: "toast",
            breed: "Standard Poodle",
            color: Color(red: 0.75, green: 0.60, blue: 0.50),
            type: .dog,
            status: .boarding,
            personality: ["Intelligent", "Elegant", "Active"]
        )
    ]
    
    var currentPetImageName: String {
        "\(pets[currentPet].imageName)-\(currentImageIndex + 1)"
    }
    
    // Count cats and dogs
    var catCount: Int { pets.filter { $0.type == .cat }.count }
    var dogCount: Int { pets.filter { $0.type == .dog }.count }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Text("Send Love to Our Pets")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary500)
                }
                
                Spacer()
                
                // Pet type and count indicator
                HStack(spacing: 6) {
                    Image(systemName: pets[currentPet].type.icon)
                        .font(.system(size: 12))
                    Text("\(currentPet + 1)/\(pets.count)")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(AppColors.primary700)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppColors.primary100)
                .cornerRadius(12)
            }
            
            // Interactive Pet Area
            ZStack {
                // Background gradient based on pet's color
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [pets[currentPet].color.opacity(0.4), pets[currentPet].color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Floating hearts
                ForEach(hearts) { heart in
                    HeartView(particle: heart)
                }
                
                // Pet display with real image
                VStack(spacing: 6) {
                    // Pet Image
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(pets[currentPet].color.opacity(0.4))
                            .frame(width: 95, height: 95)
                            .blur(radius: 12)
                        
                        // Pet image
                        Image(currentPetImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white, pets[currentPet].color],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: pets[currentPet].color.opacity(0.5), radius: 10, x: 0, y: 5)
                            .scaleEffect(petScale)
                            .rotationEffect(.degrees(petRotation))
                    }
                    
                    // Pet name with type icon and status badge
                    HStack(spacing: 6) {
                        Image(systemName: pets[currentPet].type.icon)
                            .font(.system(size: 13))
                            .foregroundColor(pets[currentPet].color)
                        
                        Text(pets[currentPet].name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        // Resident badge for Bibi & Dudu
                        if pets[currentPet].status == .resident {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.warning)
                        }
                    }
                    
                    // Breed
                    Text(pets[currentPet].breed)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                    
                    // Personality tags
                    HStack(spacing: 4) {
                        ForEach(pets[currentPet].personality.prefix(2), id: \.self) { trait in
                            Text(trait)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(AppColors.primary700)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.primary100)
                                .cornerRadius(6)
                        }
                    }
                    
                    // Tap feedback message
                    if showMessage {
                        Text(tapMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(pets[currentPet].color.opacity(0.8))
                            .cornerRadius(10)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture { location in
                handleTap(at: location)
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // Swipe left - next pet
                            nextPet()
                        } else if value.translation.width > 0 {
                            // Swipe right - previous pet
                            previousPet()
                        }
                    }
            )
            
            // Navigation & Instructions
            HStack {
                // Previous button
                Button(action: previousPet) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primary700)
                        .padding(8)
                        .background(AppColors.primary100)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Instructions
                HStack(spacing: 4) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 11))
                    Text("Tap to send love!")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppColors.textTertiary)
                
                Spacer()
                
                // Next button
                Button(action: nextPet) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primary700)
                        .padding(8)
                        .background(AppColors.primary100)
                        .clipShape(Circle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
    
    private var tapMessage: String {
        let petName = pets[currentPet].name
        let isCat = pets[currentPet].type == .cat
        switch tapCount {
        case 1...3: return "\(petName) feels loved!"
        case 4...7: return isCat ? "\(petName) is purring~" : "\(petName) is wagging!"
        case 8...12: return "So much love!"
        default: return "\(petName) loves you too!"
        }
    }
    
    private func nextPet() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentPet = (currentPet + 1) % pets.count
            currentImageIndex = 0
            tapCount = 0
            showMessage = false
        }
    }
    
    private func previousPet() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentPet = currentPet == 0 ? pets.count - 1 : currentPet - 1
            currentImageIndex = 0
            tapCount = 0
            showMessage = false
        }
    }
    
    private func handleTap(at location: CGPoint) {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Animate pet with bounce and slight rotation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            petScale = 1.15
            petRotation = Double.random(in: -5...5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                petScale = 1.0
                petRotation = 0
            }
        }
        
        // Cycle through images (1, 2, 3) on multiple taps
        if tapCount > 0 && tapCount % 3 == 0 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentImageIndex = (currentImageIndex + 1) % 3
            }
        }
        
        // Add heart
        let heart = HeartParticle(x: location.x, y: location.y)
        hearts.append(heart)
        
        // Remove heart after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            hearts.removeAll { $0.id == heart.id }
        }
        
        // Update tap count and show message
        tapCount += 1
        withAnimation(.spring()) {
            showMessage = true
        }
        
        // Hide message after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showMessage = false
            }
        }
    }
}

struct HeartParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let rotation: Double = Double.random(in: -30...30)
    let scale: CGFloat = CGFloat.random(in: 0.5...1.2)
}

struct HeartView: View {
    let particle: HeartParticle
    @State private var animate = false
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundColor(AppColors.primary500)
            .scaleEffect(particle.scale * (animate ? 1.5 : 0.5))
            .rotationEffect(.degrees(particle.rotation))
            .opacity(animate ? 0 : 1)
            .position(x: particle.x, y: animate ? particle.y - 80 : particle.y)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    animate = true
                }
            }
    }
}

// MARK: - Daily Tip Card
struct DailyTipCard: View {
    @State private var currentTip = 0
    @State private var isBookmarked = false
    
    let tips = [
        DailyTip(icon: "drop.fill", title: "Hydration Matters", content: "Cats need fresh water daily. Consider a water fountain - many cats prefer running water!", color: AppColors.info),
        DailyTip(icon: "moon.stars.fill", title: "Sleep Schedule", content: "Cats sleep 12-16 hours daily. Provide cozy spots away from high-traffic areas.", color: AppColors.primary600),
        DailyTip(icon: "leaf.fill", title: "Safe Plants", content: "Cat grass and catnip are safe! Avoid lilies, tulips, and azaleas which are toxic to cats.", color: AppColors.success),
        DailyTip(icon: "comb.fill", title: "Grooming Time", content: "Brush your cat regularly to reduce hairballs and strengthen your bond.", color: AppColors.warning),
        DailyTip(icon: "heart.fill", title: "Play Daily", content: "15 minutes of active play helps prevent obesity and behavioral issues.", color: AppColors.primary500),
        DailyTip(icon: "fork.knife", title: "Feeding Tips", content: "Feed cats at consistent times. Most adult cats do well with 2 meals per day.", color: AppColors.primary700),
        DailyTip(icon: "thermometer.medium", title: "Temperature", content: "Cats prefer temperatures between 68-77°F. Provide warm spots in winter!", color: AppColors.primary400)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                    Text(todayString)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        isBookmarked.toggle()
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16))
                        .foregroundColor(isBookmarked ? AppColors.primary700 : AppColors.textTertiary)
                }
            }
            
            // Tip Content
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(tips[currentTip].color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: tips[currentTip].icon)
                        .font(.system(size: 26))
                        .foregroundColor(tips[currentTip].color)
                }
                
                Text(tips[currentTip].title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(tips[currentTip].content)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            
            // Navigation dots & arrows
            HStack {
                Button(action: previousTip) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primary700)
                        .padding(8)
                        .background(AppColors.primary100)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    ForEach(0..<tips.count, id: \.self) { index in
                        Circle()
                            .fill(currentTip == index ? AppColors.primary700 : AppColors.neutral200)
                            .frame(width: 6, height: 6)
                    }
                }
                
                Spacer()
                
                Button(action: nextTip) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primary700)
                        .padding(8)
                        .background(AppColors.primary100)
                        .clipShape(Circle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.08), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            // Set tip based on day of year
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
            currentTip = dayOfYear % tips.count
        }
    }
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    private func nextTip() {
        withAnimation(.spring()) {
            currentTip = (currentTip + 1) % tips.count
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func previousTip() {
        withAnimation(.spring()) {
            currentTip = currentTip == 0 ? tips.count - 1 : currentTip - 1
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

struct DailyTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let content: String
    let color: Color
}

// MARK: - Fun Fact Card
struct FunFactCard: View {
    @State private var isRevealed = false
    @State private var currentFact = 0
    
    let facts = [
        FunFact(icon: "moon.zzz.fill", iconColor: AppColors.primary500, fact: "Cats spend 70% of their lives sleeping - that's about 13-16 hours a day!", category: "Sleep"),
        FunFact(icon: "nose.fill", iconColor: AppColors.primary600, fact: "A cat's nose print is unique, just like human fingerprints!", category: "Anatomy"),
        FunFact(icon: "hare.fill", iconColor: AppColors.primary700, fact: "Cats can rotate their ears 180 degrees and run at speeds up to 30 mph!", category: "Abilities"),
        FunFact(icon: "waveform", iconColor: AppColors.primary500, fact: "Cats have over 100 vocal sounds, while dogs only have about 10!", category: "Communication"),
        FunFact(icon: "brain.head.profile", iconColor: AppColors.primary600, fact: "A cat's brain is 90% similar to a human brain!", category: "Intelligence"),
        FunFact(icon: "heart.fill", iconColor: AppColors.primary700, fact: "Cats purr at a frequency that can help heal bones and reduce stress!", category: "Health"),
        FunFact(icon: "eye.fill", iconColor: AppColors.primary500, fact: "Cats can see in light levels six times lower than what humans need!", category: "Vision"),
        FunFact(icon: "clock.fill", iconColor: AppColors.primary600, fact: "The oldest known pet cat lived to be 38 years old!", category: "Longevity")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Did You Know?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(facts[currentFact].category)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.primary700)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primary100)
                    .cornerRadius(8)
            }
            
            // Mystery box / Revealed content
            ZStack {
                // Mystery state
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary300, AppColors.primary500],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "questionmark")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Tap to reveal a fun fact!")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .opacity(isRevealed ? 0 : 1)
                .scaleEffect(isRevealed ? 0.8 : 1)
                
                // Revealed state
                VStack(spacing: 12) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [facts[currentFact].iconColor.opacity(0.2), facts[currentFact].iconColor.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: facts[currentFact].icon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [facts[currentFact].iconColor, facts[currentFact].iconColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text(facts[currentFact].fact)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                }
                .opacity(isRevealed ? 1 : 0)
                .scaleEffect(isRevealed ? 1 : 0.8)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.primary50)
            )
            .onTapGesture {
                if !isRevealed {
                    revealFact()
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: shareFact) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primary700)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.primary100)
                    .cornerRadius(12)
                }
                .opacity(isRevealed ? 1 : 0.5)
                .disabled(!isRevealed)
                
                Button(action: nextFact) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("New Fact")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.primary700)
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
    
    private func revealFact() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isRevealed = true
        }
    }
    
    private func nextFact() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.spring()) {
            isRevealed = false
            currentFact = (currentFact + 1) % facts.count
        }
        
        // Auto-reveal after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            revealFact()
        }
    }
    
    private func shareFact() {
        let text = "Fun Pet Fact: \(facts[currentFact].fact)\n\n— From Coco's Pet Paradise"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct FunFact: Identifiable {
    let id = UUID()
    let icon: String       // SF Symbol name
    let iconColor: Color   // Icon color from AppColors
    let fact: String
    let category: String
}

// MARK: - Animated Home Background
struct AnimatedHomeBackground: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    AppColors.primary200.opacity(0.6),
                    AppColors.primary100.opacity(0.4),
                    AppColors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated blobs
            GeometryReader { geo in
                // Top blob
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
                
                // Right blob
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
                
                // Bottom blob
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
            // Top left decoration - larger and always visible
            DecorationImage(name: "left-decoration", fallbackIcon: "leaf.fill")
                .frame(width: 220, height: 220)
                .opacity(0.75)
                .rotationEffect(.degrees(-25))
                .offset(x: -30, y: -20 + floatOffset1)
            
            // Top right decoration - larger and always visible
            DecorationImage(name: "testimonials-decoration", fallbackIcon: "leaf.fill")
                .frame(width: 200, height: 200)
                .opacity(0.7)
                .offset(x: geo.size.width - 140, y: 10 + floatOffset2)
        }
        .onAppear {
            // Gentle floating animation for left decoration
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
            ) {
                floatOffset1 = 15
            }
            
            // Slightly different timing for right decoration
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
                .delay(0.5)
            ) {
                floatOffset2 = 12
            }
        }
    }
}

// MARK: - Home Hero Section
struct HomeHeroSection: View {
    @Binding var animateContent: Bool
    @State private var logoFloat: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)
            
            // Welcome message with animated logo
            HStack(spacing: 16) {
                // Animated app logo (changed from PawShape)
                ZStack {
                    Circle()
                        .fill(AppColors.primary100)
                        .frame(width: 60, height: 60)
                    
                    LogoImage(name: "app-logo", size: 38)
                        .offset(y: logoFloat)
                }
                .shadow(color: AppColors.primary700.opacity(0.2), radius: 10, x: 0, y: 5)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Welcome Back!")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .opacity(animateContent ? 1 : 0)
            .offset(x: animateContent ? 0 : -30)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateContent)
            
            // Tagline
            Text("Your pets' home away from home")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 24)
                .opacity(animateContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animateContent)
            
            Spacer().frame(height: 30)
        }
        .frame(height: 220)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                logoFloat = -3
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
                
                // Chat Quick Action with unread badge
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
                
                // Badge for unread count
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
