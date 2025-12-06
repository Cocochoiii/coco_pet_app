//
//  GamificationView.swift
//  CocoPetParadise
//
//  Gamification features - Achievements, Rewards, Virtual Pet Simulator
//

import SwiftUI

// MARK: - Achievements View
struct AchievementsView: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    
    var filteredAchievements: [Achievement] {
        guard let category = selectedCategory else {
            return gamificationManager.achievements
        }
        return gamificationManager.achievements.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // User level card
                    UserLevelCard()
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            AchievementCategoryChip(
                                title: "All",
                                icon: "trophy.fill",
                                isSelected: selectedCategory == nil,
                                color: AppColors.primary700
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                                AchievementCategoryChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Unlocked achievements
                    if !gamificationManager.unlockedAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(AppColors.success)
                                Text("Unlocked")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Text("\(gamificationManager.unlockedAchievements.count)")
                                    .font(AppFonts.bodySmall)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.horizontal)
                            
                            ForEach(filteredAchievements.filter { $0.isUnlocked }) { achievement in
                                AchievementCard(achievement: achievement, isUnlocked: true)
                            }
                        }
                    }
                    
                    // Locked achievements
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppColors.neutral400)
                            Text("In Progress")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Text("\(gamificationManager.lockedAchievements.count)")
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal)
                        
                        ForEach(filteredAchievements.filter { !$0.isUnlocked }) { achievement in
                            AchievementCard(achievement: achievement, isUnlocked: false)
                        }
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 100)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - User Level Card
struct UserLevelCard: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Level badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary600, AppColors.primary700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    VStack(spacing: 0) {
                        Text("Lv")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(gamificationManager.gameProfile.level)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(gamificationManager.gameProfile.levelTitle)
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.neutral200)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary600, AppColors.primary700],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * gamificationManager.gameProfile.levelProgress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(gamificationManager.gameProfile.pointsToNextLevel) pts to next level")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            Divider()
            
            // Stats row
            HStack(spacing: 0) {
                UserStatItem(value: "\(gamificationManager.gameProfile.totalPoints)", label: "Total Points", icon: "star.fill")
                
                Divider().frame(height: 40)
                
                UserStatItem(value: "\(gamificationManager.gameProfile.currentPoints)", label: "Available", icon: "gift.fill")
                
                Divider().frame(height: 40)
                
                UserStatItem(value: "\(gamificationManager.unlockedAchievements.count)", label: "Achievements", icon: "trophy.fill")
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: AppShadows.soft, radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct UserStatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.primary600)
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            Text(label)
                .font(AppFonts.captionSmall)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Achievement Category Chip
struct AchievementCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.1))
            )
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.category.color.opacity(0.15) : AppColors.neutral100)
                    .frame(width: 56, height: 56)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? achievement.category.color : AppColors.neutral400)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(achievement.title)
                        .font(AppFonts.headline)
                        .foregroundColor(isUnlocked ? AppColors.textPrimary : AppColors.textSecondary)
                    
                    if isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.success)
                    }
                }
                
                Text(achievement.description)
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(2)
                
                if !isUnlocked {
                    // Progress bar
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.neutral200)
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(achievement.category.color)
                                    .frame(width: geo.size.width * achievement.progressPercent, height: 4)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(achievement.progress)/\(achievement.requirement)")
                            .font(AppFonts.captionSmall)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            // Points reward
            VStack(spacing: 2) {
                Text("+\(achievement.pointsReward)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? AppColors.success : AppColors.textTertiary)
                Text("pts")
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 6, x: 0, y: 2)
        .padding(.horizontal)
        .opacity(isUnlocked ? 1 : 0.8)
    }
}

// MARK: - Rewards Store View
struct RewardsStoreView: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var selectedType: Reward.RewardType? = nil
    @State private var showRedeemAlert = false
    @State private var selectedReward: Reward?
    
    var filteredRewards: [Reward] {
        guard let type = selectedType else {
            return gamificationManager.rewards
        }
        return gamificationManager.rewards.filter { $0.type == type }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Points balance card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Available Points")
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppColors.warning)
                                Text("\(gamificationManager.gameProfile.currentPoints)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "gift.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.primary300)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary100, Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Type filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            RewardTypeChip(title: "All", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            
                            ForEach(Reward.RewardType.allCases, id: \.self) { type in
                                RewardTypeChip(
                                    title: type.rawValue,
                                    isSelected: selectedType == type,
                                    color: type.color
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Rewards grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredRewards) { reward in
                            RewardCard(reward: reward) {
                                selectedReward = reward
                                showRedeemAlert = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .padding(.vertical)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Rewards Store")
            .navigationBarTitleDisplayMode(.large)
            .alert("Redeem Reward", isPresented: $showRedeemAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Redeem") {
                    if let reward = selectedReward {
                        let _ = gamificationManager.redeemReward(id: reward.id)
                        HapticManager.notification(.success)
                    }
                }
            } message: {
                if let reward = selectedReward {
                    Text("Redeem '\(reward.title)' for \(reward.pointsCost) points?")
                }
            }
        }
    }
}

struct RewardTypeChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = AppColors.primary700
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    let onRedeem: () -> Void
    @EnvironmentObject var gamificationManager: GamificationManager
    
    var canAfford: Bool {
        gamificationManager.gameProfile.currentPoints >= reward.pointsCost
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(reward.type.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: reward.icon)
                    .font(.system(size: 28))
                    .foregroundColor(reward.type.color)
            }
            
            // Title
            Text(reward.title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Description
            Text(reward.description)
                .font(AppFonts.captionSmall)
                .foregroundColor(AppColors.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Spacer()
            
            // Price & Redeem
            if reward.isRedeemed {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Redeemed")
                        .font(AppFonts.caption)
                }
                .foregroundColor(AppColors.success)
            } else {
                Button(action: onRedeem) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("\(reward.pointsCost)")
                            .font(AppFonts.bodySmall)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(canAfford ? AppColors.primary700 : AppColors.neutral400)
                    .cornerRadius(20)
                }
                .disabled(!canAfford)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 6, x: 0, y: 2)
        .opacity(reward.isRedeemed ? 0.6 : 1)
    }
}

// MARK: - Virtual Pet Simulator View
struct VirtualPetSimulatorView: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var showAccessoryShop = false
    @State private var animatePet = false
    @State private var showActionFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackIcon = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [AppColors.primary100, AppColors.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Pet display area
                    VStack(spacing: 16) {
                        // Pet avatar
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 160, height: 160)
                                .shadow(color: AppColors.primary.opacity(0.2), radius: 20, x: 0, y: 10)
                            
                            // Pet icon based on type
                            Image(systemName: gamificationManager.virtualPetState.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.primary700)
                                .scaleEffect(animatePet ? 1.05 : 1)
                                .offset(y: animatePet ? -5 : 0)
                            
                            // Mood indicator
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 40, height: 40)
                                            .shadow(color: Color.black.opacity(0.1), radius: 4)
                                        
                                        Image(systemName: gamificationManager.virtualPetState.moodIcon)
                                            .font(.system(size: 20))
                                            .foregroundColor(gamificationManager.virtualPetState.moodColor)
                                    }
                                    .offset(x: 10, y: 10)
                                }
                            }
                        }
                        .frame(width: 160, height: 160)
                        
                        // Pet name
                        Text(gamificationManager.virtualPetState.name)
                            .font(AppFonts.title2)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Interactions: \(gamificationManager.virtualPetState.totalInteractions)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.top, 20)
                    
                    // Stats bars
                    VStack(spacing: 12) {
                        StatBar(icon: "heart.fill", label: "Happiness", value: gamificationManager.virtualPetState.happiness, color: AppColors.error)
                        StatBar(icon: "fork.knife", label: "Hunger", value: 100 - gamificationManager.virtualPetState.hunger, color: AppColors.warning)
                        StatBar(icon: "bolt.fill", label: "Energy", value: gamificationManager.virtualPetState.energy, color: AppColors.success)
                        StatBar(icon: "sparkles", label: "Cleanliness", value: gamificationManager.virtualPetState.cleanliness, color: AppColors.info)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        PetActionButton(icon: "fork.knife", label: "Feed", color: AppColors.warning) {
                            performAction {
                                gamificationManager.feedVirtualPet()
                                feedbackMessage = "Yummy! 🍽️"
                                feedbackIcon = "fork.knife"
                            }
                        }
                        
                        PetActionButton(icon: "figure.run", label: "Play", color: AppColors.success) {
                            performAction {
                                gamificationManager.playWithVirtualPet()
                                feedbackMessage = "So fun! 🎉"
                                feedbackIcon = "figure.run"
                            }
                        }
                        
                        PetActionButton(icon: "shower.fill", label: "Clean", color: AppColors.info) {
                            performAction {
                                gamificationManager.cleanVirtualPet()
                                feedbackMessage = "Squeaky clean! ✨"
                                feedbackIcon = "sparkles"
                            }
                        }
                        
                        PetActionButton(icon: "moon.zzz.fill", label: "Rest", color: AppColors.primary600) {
                            performAction {
                                gamificationManager.restVirtualPet()
                                feedbackMessage = "Zzz... 😴"
                                feedbackIcon = "moon.zzz.fill"
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                
                // Action feedback overlay
                if showActionFeedback {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Image(systemName: feedbackIcon)
                                .font(.system(size: 24))
                            Text(feedbackMessage)
                                .font(AppFonts.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(AppColors.primary700)
                        .cornerRadius(30)
                        .shadow(color: AppColors.primary.opacity(0.4), radius: 10)
                        .transition(.scale.combined(with: .opacity))
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Virtual Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAccessoryShop = true }) {
                        Image(systemName: "bag.fill")
                            .foregroundColor(AppColors.primary700)
                    }
                }
            }
            .sheet(isPresented: $showAccessoryShop) {
                AccessoryShopView()
            }
            .onAppear {
                startPetAnimation()
                gamificationManager.updateVirtualPetStats()
            }
        }
    }
    
    func startPetAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            animatePet = true
        }
    }
    
    func performAction(_ action: () -> Void) {
        action()
        HapticManager.notification(.success)
        
        withAnimation(.spring(response: 0.3)) {
            showActionFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showActionFeedback = false
            }
        }
    }
}

// MARK: - Stat Bar
struct StatBar: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.neutral200)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(value)%")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 40)
        }
    }
}

// MARK: - Pet Action Button
struct PetActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(label)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .scaleEffect(isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.2), value: isPressed)
        }
    }
}

// MARK: - Accessory Shop View
struct AccessoryShopView: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: VirtualPetAccessory.AccessoryCategory? = nil
    
    var filteredAccessories: [VirtualPetAccessory] {
        guard let category = selectedCategory else {
            return gamificationManager.accessories
        }
        return gamificationManager.accessories.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Points display
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.warning)
                    Text("\(gamificationManager.gameProfile.currentPoints) points")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.primary50)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        
                        ForEach(VirtualPetAccessory.AccessoryCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding()
                }
                
                // Accessories grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredAccessories) { accessory in
                            AccessoryCard(accessory: accessory)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Accessory Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primary700)
                }
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(AppFonts.bodySmall)
            }
            .foregroundColor(isSelected ? .white : AppColors.primary700)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.primary700 : AppColors.primary100)
            )
        }
    }
}

struct AccessoryCard: View {
    let accessory: VirtualPetAccessory
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var showPurchaseAlert = false
    
    var canAfford: Bool {
        gamificationManager.gameProfile.currentPoints >= accessory.pointsCost
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accessory.isOwned ? AppColors.success.opacity(0.1) : AppColors.neutral100)
                    .frame(height: 80)
                
                Image(systemName: accessory.icon)
                    .font(.system(size: 32))
                    .foregroundColor(accessory.isOwned ? AppColors.success : AppColors.primary600)
            }
            
            Text(accessory.name)
                .font(AppFonts.captionSmall)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            
            if accessory.isOwned {
                Text("Owned")
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.success)
            } else {
                Button(action: { showPurchaseAlert = true }) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("\(accessory.pointsCost)")
                            .font(AppFonts.captionSmall)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(canAfford ? AppColors.primary700 : AppColors.neutral400)
                    .cornerRadius(10)
                }
                .disabled(!canAfford)
            }
        }
        .alert("Purchase Accessory", isPresented: $showPurchaseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Buy") {
                let _ = gamificationManager.purchaseAccessory(id: accessory.id)
                HapticManager.notification(.success)
            }
        } message: {
            Text("Buy '\(accessory.name)' for \(accessory.pointsCost) points?")
        }
    }
}

// MARK: - Previews
struct GamificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AchievementsView()
            RewardsStoreView()
            VirtualPetSimulatorView()
        }
        .environmentObject(GamificationManager())
    }
}
