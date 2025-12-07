//
//  CocoPetParadiseApp.swift
//  CocoPetParadise
//
//  Coco's Pet Paradise - Premium Pet Boarding iOS App
//  A luxurious home-style pet boarding experience
//

import SwiftUI

@main
struct CocoPetParadiseApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var bookingManager = BookingManager()
    @StateObject private var petDataManager = PetDataManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var chatManager = ChatManager()
    @StateObject private var gamificationManager = GamificationManager()
    @StateObject private var communityManager = CommunityManager()
    @StateObject private var diaryManager = DiaryManager()
    @StateObject private var petMatchingManager = PetMatchingManager()
    @StateObject private var activityTrackingManager = ActivityTrackingManager()
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(bookingManager)
                .environmentObject(petDataManager)
                .environmentObject(notificationManager)
                .environmentObject(chatManager)
                .environmentObject(gamificationManager)
                .environmentObject(communityManager)
                .environmentObject(diaryManager)
                .environmentObject(petMatchingManager)
                .environmentObject(activityTrackingManager)
                .onAppear {
                    notificationManager.requestPermission()
                }
        }
    }
    
    private func configureAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppColors.background)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.textPrimary),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(AppColors.textPrimary),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.primary)
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppColors.background)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = UIColor(AppColors.primary)
    }
}

// MARK: - Root View (Splash -> Auth -> Main)
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            // Main content based on auth state
            // Only render after splash is done to prevent overlap
            if !showSplash {
                if appState.isAuthenticated {
                    ContentView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    AuthView()
                        .transition(.opacity)
                }
            }
            
            // Splash screen overlay
            if showSplash {
                SplashScreen(onComplete: {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                })
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.isAuthenticated)
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isAdmin: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var showOnboarding: Bool = true
    @Published var selectedTab: Tab = .home
    
    enum Tab: Int, CaseIterable {
        case home = 0
        case pets = 1
        case booking = 2
        case services = 3
        case profile = 4
    }
    
    init() {
        showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isLoggedIn = true
            isAdmin = user.isAdmin
        }
    }
    
    func login(user: User) {
        currentUser = user
        isLoggedIn = true
        isAdmin = user.isAdmin
        isAuthenticated = true
        
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        isAdmin = false
        isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func completeOnboarding() {
        showOnboarding = false
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let isAdmin: Bool
    var profileImageURL: String?
    var favoritePets: [String]
    var bookingHistory: [String]
    
    init(id: String = UUID().uuidString, name: String, email: String, phone: String? = nil, isAdmin: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.isAdmin = isAdmin
        self.favoritePets = []
        self.bookingHistory = []
    }
}
