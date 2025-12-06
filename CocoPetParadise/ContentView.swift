//
//  ContentView.swift
//  CocoPetParadise
//
//  Main content view with tab navigation and floating chat button
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var chatManager: ChatManager
    @State private var selectedTab: Int = 0
    @State private var showChat: Bool = false
    
    var body: some View {
        Group {
            if appState.showOnboarding {
                OnboardingView()
            } else {
                ZStack {
                    MainTabView(selectedTab: $selectedTab, showChat: $showChat)
                    
                    // Floating Chat Button - appears on all tabs
                    FloatingChatButton(showChat: $showChat)
                }
            }
        }
        .animation(.easeInOut, value: appState.showOnboarding)
        .fullScreenCover(isPresented: $showChat) {
            ChatView()
                .environmentObject(chatManager)
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @Binding var selectedTab: Int
    @Binding var showChat: Bool
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var gamificationManager: GamificationManager
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showChat: $showChat)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            PetsView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint.fill")
                }
                .tag(1)
            
            BookingView()
                .tabItem {
                    Label("Book", systemImage: "calendar")
                }
                .tag(2)
            
            SocialView()
                .tabItem {
                    Label("Community", systemImage: "camera.on.rectangle.fill")
                }
                .tag(3)
            
            ProfileView(showChat: $showChat)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .badge(notificationManager.unreadCount + chatManager.unreadCount > 0 ? notificationManager.unreadCount + chatManager.unreadCount : 0)
                .tag(4)
        }
        .tint(AppColors.primary700)
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            image: "pawprint.circle.fill",
            title: "Welcome to\nCoco's Pet Paradise",
            subtitle: "Premium home-style pet boarding in Wellesley Hills, MA",
            color: AppColors.primary
        ),
        OnboardingPage(
            image: "house.fill",
            title: "Home Away\nFrom Home",
            subtitle: "Your furry friends enjoy comfortable, personalized care in a loving home environment",
            color: AppColors.primary600
        ),
        OnboardingPage(
            image: "camera.fill",
            title: "Stay Connected",
            subtitle: "Receive daily photo and video updates of your pet's activities and adventures",
            color: AppColors.primary700
        ),
        OnboardingPage(
            image: "person.3.fill",
            title: "Join Our Community",
            subtitle: "Connect with other pet owners, share experiences, and find playmates for your pets",
            color: AppColors.primary600
        ),
        OnboardingPage(
            image: "trophy.fill",
            title: "Earn Rewards",
            subtitle: "Complete bookings, unlock achievements, and redeem exclusive rewards",
            color: AppColors.warning
        ),
        OnboardingPage(
            image: "calendar.badge.clock",
            title: "Easy Booking",
            subtitle: "Book your pet's stay in seconds with our simple calendar system",
            color: AppColors.primary800
        )
    ]
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        appState.completeOnboarding()
                    }
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .padding()
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? AppColors.primary : AppColors.neutral300)
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                // Next/Get Started button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        appState.completeOnboarding()
                    }
                }) {
                    HStack {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let subtitle: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 180, height: 180)
                
                Image(systemName: page.image)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
            }
            
            // Title
            Text(page.title)
                .font(AppFonts.largeTitle)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text(page.subtitle)
                .font(AppFonts.bodyLarge)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(BookingManager())
            .environmentObject(PetDataManager())
            .environmentObject(NotificationManager())
            .environmentObject(ChatManager())
            .environmentObject(GamificationManager())
            .environmentObject(CommunityManager())
            .environmentObject(DiaryManager())
            .environmentObject(PetMatchingManager())
            .environmentObject(ActivityTrackingManager())
    }
}
