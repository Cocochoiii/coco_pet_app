//
//  ProfileView.swift
//  CocoPetParadise
//
//  User profile, settings, notifications, gamification, and account management
//

import SwiftUI
import PhotosUI

// MARK: - Profile Image Manager
class ProfileImageManager: ObservableObject {
    @Published var profileImage: UIImage?
    
    private let imageKey = "userProfileImage"
    
    init() {
        loadImage()
    }
    
    func saveImage(_ image: UIImage?) {
        if let image = image, let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: imageKey)
            self.profileImage = image
        } else {
            UserDefaults.standard.removeObject(forKey: imageKey)
            self.profileImage = nil
        }
    }
    
    func loadImage() {
        if let data = UserDefaults.standard.data(forKey: imageKey),
           let image = UIImage(data: data) {
            self.profileImage = image
        }
    }
    
    func removeImage() {
        UserDefaults.standard.removeObject(forKey: imageKey)
        self.profileImage = nil
    }
}

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var gamificationManager: GamificationManager
    @Binding var showChat: Bool
    @StateObject private var profileImageManager = ProfileImageManager()
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showContact = false
    @State private var showLoginSheet = false
    @State private var showAchievements = false
    @State private var showRewards = false
    @State private var showVirtualPet = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ProfileHeader(profileImageManager: profileImageManager)
                    
                    if appState.isAuthenticated {
                        // Gamification Quick Stats
                        GamificationQuickStats()
                        
                        // Quick Stats Cards
                        QuickStatsCards()
                    }
                    
                    VStack(spacing: 16) {
                        // Gamification Section
                        if appState.isAuthenticated {
                            MenuSection(title: "Fun & Rewards") {
                                MenuRow(icon: "star.fill", title: "Points & Level", badge: "Lvl \(gamificationManager.gameProfile.level)", badgeColor: AppColors.warning) {
                                    showAchievements = true
                                }
                                MenuRow(icon: "trophy.fill", title: "Achievements", badge: "\(gamificationManager.unlockedAchievements.count)/\(gamificationManager.achievements.count)", badgeColor: Color(hex: "FFD700")) {
                                    showAchievements = true
                                }
                                MenuRow(icon: "gift.fill", title: "Rewards Store", badge: "\(gamificationManager.gameProfile.currentPoints) pts", badgeColor: AppColors.success) {
                                    showRewards = true
                                }
                                MenuRow(icon: "hare.fill", title: "Virtual Pet", showChevron: true) {
                                    showVirtualPet = true
                                }
                            }
                        }
                        
                        MenuSection(title: "Account") {
                            if appState.isAuthenticated {
                                MenuRow(icon: "heart.fill", title: "Favorite Pets", badge: "\(petDataManager.favoritePets.count)") { }
                                MenuRow(icon: "calendar", title: "My Bookings", badge: "\(bookingManager.upcomingBookings.count)") { }
                                MenuRow(icon: "bell.fill", title: "Notifications", badge: notificationManager.unreadCount > 0 ? "\(notificationManager.unreadCount)" : nil) {
                                    showNotifications = true
                                }
                            } else {
                                MenuRow(icon: "person.badge.plus", title: "Sign In / Create Account", showChevron: true) {
                                    showLoginSheet = true
                                }
                            }
                        }
                        
                        MenuSection(title: "Support") {
                            MenuRow(
                                icon: "bubble.left.and.bubble.right.fill",
                                title: "Chat with Us",
                                badge: chatManager.unreadCount > 0 ? "\(chatManager.unreadCount)" : nil,
                                showChevron: true
                            ) {
                                showChat = true
                            }
                            MenuRow(icon: "message.fill", title: "Contact Us", showChevron: true) { showContact = true }
                            MenuRow(icon: "questionmark.circle.fill", title: "FAQ", showChevron: true) { }
                            MenuRow(icon: "phone.fill", title: "Call Us") {
                                if let url = URL(string: "tel:+16175551234") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        
                        MenuSection(title: "App") {
                            MenuRow(icon: "gearshape.fill", title: "Settings", showChevron: true) { showSettings = true }
                            MenuRow(icon: "info.circle.fill", title: "About", showChevron: true) { showAbout = true }
                            MenuRow(icon: "star.fill", title: "Rate the App") { }
                            MenuRow(icon: "square.and.arrow.up", title: "Share App") { shareApp() }
                        }
                        
                        if appState.isAuthenticated {
                            Button(action: {
                                withAnimation {
                                    appState.logout()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                }
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Version 1.0.0")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 8)
                }
                .padding(.bottom, 100)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showNotifications) { NotificationsView() }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showAbout) { AboutView() }
            .sheet(isPresented: $showContact) { ContactView() }
            .sheet(isPresented: $showLoginSheet) { LoginView() }
            .sheet(isPresented: $showAchievements) { AchievementsView() }
            .sheet(isPresented: $showRewards) { RewardsStoreView() }
            .sheet(isPresented: $showVirtualPet) { VirtualPetSimulatorView() }
        }
    }
    
    func shareApp() {
        let text = "Check out Coco's Pet Paradise - the best pet boarding in Wellesley Hills! 🐾"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Gamification Quick Stats
struct GamificationQuickStats: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Level Badge
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary600, AppColors.primary700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    VStack(spacing: 0) {
                        Text("Lv")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(gamificationManager.gameProfile.level)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(gamificationManager.gameProfile.levelTitle)
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            // Points
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.warning)
                    Text("\(gamificationManager.gameProfile.currentPoints)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Text("Points")
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            
            // Achievements
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.warning)
                    Text("\(gamificationManager.unlockedAchievements.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Text("Achievements")
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: AppShadows.soft, radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Profile Header with Image Upload
struct ProfileHeader: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var profileImageManager: ProfileImageManager
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary200)
                        .frame(width: 100, height: 100)
                    
                    if let profileImage = profileImageManager.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.primary700)
                    }
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary700)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            profileImageManager.saveImage(image)
                        }
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text(appState.currentUser?.name ?? "Guest")
                    .font(AppFonts.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(appState.currentUser?.email ?? "Sign in to access all features")
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                
                if appState.isAdmin {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                        Text("Admin")
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(AppColors.primary700)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primary100)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Quick Stats Cards
struct QuickStatsCards: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var bookingManager: BookingManager
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(icon: "pawprint.fill", value: "\(petDataManager.userPets.count)", label: "My Pets", color: AppColors.primary700)
            QuickStatCard(icon: "calendar", value: "\(bookingManager.upcomingBookings.count)", label: "Bookings", color: AppColors.info)
            QuickStatCard(icon: "heart.fill", value: "\(petDataManager.favoritePets.count)", label: "Favorites", color: AppColors.error)
        }
        .padding(.horizontal)
    }
}

struct QuickStatCard: View {
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
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(AppFonts.captionSmall)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 6, x: 0, y: 2)
    }
}

// MARK: - Menu Section
struct MenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textTertiary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    var badge: String? = nil
    var badgeColor: Color = AppColors.primary700
    var showChevron: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.primary700)
                    .frame(width: 28)
                
                Text(title)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(AppFonts.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(badgeColor)
                        .cornerRadius(10)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Notifications View
struct NotificationsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationManager.notifications.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.neutral300)
                        Text("No notifications")
                            .font(AppFonts.title3)
                            .foregroundColor(AppColors.textPrimary)
                        Text("You're all caught up!")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(notificationManager.notifications) { notification in
                            NotificationRow(notification: notification)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                notificationManager.deleteNotification(id: notificationManager.notifications[index].id)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !notificationManager.notifications.isEmpty {
                        Button("Mark All Read") {
                            notificationManager.markAllAsRead()
                        }
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.primary700)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primary700)
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(notification.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if !notification.isRead {
                        Circle()
                            .fill(AppColors.primary700)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.body)
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                
                Text(notification.date.formatted(date: .abbreviated, time: .shortened))
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textTertiary)
            }
            
            Spacer()
        }
        .padding(14)
        .background(notification.isRead ? Color.white : AppColors.primary50)
        .cornerRadius(12)
        .onTapGesture {
            notificationManager.markAsRead(id: notification.id)
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var darkMode = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell.fill")
                    }
                    .tint(AppColors.primary700)
                }
                
                Section("Appearance") {
                    Toggle(isOn: $darkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    .tint(AppColors.primary700)
                }
                
                Section("Data") {
                    Button(action: {}) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Button(action: {}) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                
                Section("Legal") {
                    Button(action: {}) {
                        Label("Terms of Service", systemImage: "doc.text")
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Button(action: {}) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .navigationTitle("Settings")
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

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Logo
                    LogoImage(name: "app-logo", size: 100)
                        .padding(.top, 40)
                    
                    Text("Coco's Pet Paradise")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Premium pet boarding service in Wellesley Hills, MA. We provide a loving home environment for your furry family members while you're away.")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        AboutFeatureRow(icon: "house.fill", title: "Home Environment", description: "Cozy, home-style boarding")
                        AboutFeatureRow(icon: "camera.fill", title: "Daily Updates", description: "Photos and videos of your pet")
                        AboutFeatureRow(icon: "heart.fill", title: "Personalized Care", description: "Tailored to your pet's needs")
                        AboutFeatureRow(icon: "clock.fill", title: "24/7 Supervision", description: "Round-the-clock attention")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.primary700)
                        
                        Text("Wellesley Hills, MA")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Button("Get Directions") { }
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.primary700)
                    }
                    .padding()
                }
                .padding(.bottom, 40)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("About")
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

struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary700)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text(description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    
    var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && email.contains("@")
        } else {
            return !email.isEmpty && !password.isEmpty && email.contains("@")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary700)
                        
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(isSignUp ? "Sign up to manage your bookings" : "Sign in to your account")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        if isSignUp {
                            ProfileFormTextField(label: "Name", placeholder: "Enter your name", text: $name, icon: "person")
                        }
                        
                        ProfileFormTextField(label: "Email", placeholder: "Enter your email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundColor(AppColors.textTertiary)
                                
                                SecureField("Enter your password", text: $password)
                                    .font(AppFonts.bodyMedium)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: submit) {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: !isFormValid))
                    .disabled(!isFormValid)
                    .padding(.horizontal)
                    
                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.primary700)
                    }
                    
                    Text("Admin: hcaicoco@gmail.com")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                .padding(.bottom, 40)
            }
            .background(AppColors.backgroundSecondary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    func submit() {
        let isAdmin = email.lowercased() == "hcaicoco@gmail.com"
        let user = User(
            name: isSignUp ? name : email.components(separatedBy: "@").first ?? "User",
            email: email,
            isAdmin: isAdmin
        )
        appState.login(user: user)
        dismiss()
    }
}

// MARK: - Profile Form TextField
struct ProfileFormTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.textTertiary)
                
                TextField(placeholder, text: $text)
                    .font(AppFonts.bodyMedium)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(showChat: .constant(false))
            .environmentObject(AppState())
            .environmentObject(PetDataManager())
            .environmentObject(BookingManager())
            .environmentObject(NotificationManager())
            .environmentObject(ChatManager())
            .environmentObject(GamificationManager())
    }
}
