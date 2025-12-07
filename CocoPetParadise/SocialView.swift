//
//  SocialView.swift
//  CocoPetParadise
//
//  Premium Instagram-style social hub with Tinder-style pet matching
//  Real pet photos, beautiful animations, swipe gestures
//  User story creation with photo editing and text overlay
//  Unified cream-pink color scheme
//

import SwiftUI
import PhotosUI

// MARK: - User Story Model
struct UserStory: Identifiable, Codable {
    let id: String
    let authorName: String
    let imageName: String
    let text: String
    let textPosition: TextPosition
    let textColor: String
    let createdAt: Date
    var isViewed: Bool
    
    struct TextPosition: Codable {
        var x: CGFloat
        var y: CGFloat
    }
    
    init(id: String = UUID().uuidString,
         authorName: String,
         imageName: String,
         text: String,
         textPosition: TextPosition = TextPosition(x: 0.5, y: 0.7),
         textColor: String = "#FFFFFF",
         createdAt: Date = Date(),
         isViewed: Bool = false) {
        self.id = id
        self.authorName = authorName
        self.imageName = imageName
        self.text = text
        self.textPosition = textPosition
        self.textColor = textColor
        self.createdAt = createdAt
        self.isViewed = isViewed
    }
    
    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > 24 * 60 * 60
    }
}

// MARK: - Story Manager
class StoryManager: ObservableObject {
    @Published var userStories: [UserStory] = []
    private let storiesKey = "userStories"
    
    init() {
        loadStories()
        cleanExpiredStories()
    }
    
    func loadStories() {
        if let data = UserDefaults.standard.data(forKey: storiesKey),
           let saved = try? JSONDecoder().decode([UserStory].self, from: data) {
            userStories = saved.filter { !$0.isExpired }
        }
    }
    
    func saveStories() {
        if let encoded = try? JSONEncoder().encode(userStories) {
            UserDefaults.standard.set(encoded, forKey: storiesKey)
        }
    }
    
    func addStory(_ story: UserStory) {
        userStories.insert(story, at: 0)
        saveStories()
    }
    
    func deleteStory(id: String) {
        if let story = userStories.first(where: { $0.id == id }) {
            deleteStoryImage(named: story.imageName)
        }
        userStories.removeAll { $0.id == id }
        saveStories()
    }
    
    func markAsViewed(id: String) {
        if let index = userStories.firstIndex(where: { $0.id == id }) {
            userStories[index].isViewed = true
            saveStories()
        }
    }
    
    func cleanExpiredStories() {
        let expired = userStories.filter { $0.isExpired }
        for story in expired {
            deleteStoryImage(named: story.imageName)
        }
        userStories.removeAll { $0.isExpired }
        saveStories()
    }
    
    func saveStoryImage(_ image: UIImage, storyId: String) -> String {
        let fileName = "story_\(storyId).jpg"
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return fileName
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: fileURL)
        }
        return fileName
    }
    
    func loadStoryImage(named fileName: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
    
    private func deleteStoryImage(named fileName: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}

// MARK: - Casual Pet Story Captions
struct PetStoryCaptions {
    static func getCaptions(for pet: Pet) -> [String] {
        let catCaptions: [[String]] = [
            ["Just woke up from my 5th nap today 😴", "Found the perfect sunspot ☀️", "Plotting world domination... after snacks 🐱"],
            ["Living my best chonky life 🧡", "Did someone say treats? 👀", "Professional napper reporting for duty 💤"],
            ["Being adorable is a full-time job ✨", "Caught a feather today! Almost... 🪶", "Why walk when you can zoom? 💨"],
            ["Cuddle weather is every day 🥰", "Just vibing on the couch 🛋️", "My human thinks they own me lol 😂"],
            ["Window watching is serious business 🪟", "Judging everyone silently 👁️", "Too elegant for your drama ✨"],
            ["Made a new friend today! 🐱", "Stealing hearts and treats 💕", "Being fluffy is hard work 😤"],
            ["Lap time is the best time 💗", "So soft, much fluff, wow 🐾", "Purrfectly content right now 😊"],
            ["Meow meow meow (translate: feed me) 🗣️", "Climbed the cat tree AGAIN 🏔️", "I'm not loud, you're just quiet 😤"],
            ["Watching. Waiting. Plotting. 🎭", "Certified good boy/girl 🏆", "Grace and elegance loading... ✨"],
            ["Made a friend today! 🐱", "Exploring new territories 🗺️", "Best hair day ever 💇"],
            ["Midnight zoomies incoming 🌙", "Being mysterious is my brand 🖤", "Hide and seek champion 🏆"],
            ["Running laps for no reason 🏃", "Attack mode: ACTIVATED ⚡", "Love me, I'm adorable 🥺"],
            ["Food > Everything 🍽️", "Belly rubs accepted here ⬇️", "Professional loaf position 🍞"]
        ]
        
        let dogCaptions: [[String]] = [
            ["Who's a good boy? ME! 🐕", "Fetch is life 🎾", "Training hard, hardly training 😅"],
            ["Zoomies completed ✅", "Couch potato mode ON 🛋️", "Fastest boi in the west 🏃‍♂️"],
            ["Big brain time 🧠", "Herding invisible sheep 🐑", "Smartest pup in the room 🎓"],
            ["Focus. Determination. Treats. 🎯", "Running laps like a pro 🏃", "Ball is life 🏐"],
            ["Loyal to the max 💪", "Adventure time! 🗺️", "Best tricks, best boy 🏆"],
            ["Independent but still cute 😎", "Exploring the great indoors 🏠", "Shiba attitude activated 🐕‍🦺"],
            ["Soft ears, softer heart 💕", "Grooming is self-care 💅", "Cuddle puddle ready 🥰"],
            ["Swimming is my therapy 🏊", "Making friends everywhere 🤝", "Golden hour with golden retriever ✨"],
            ["Smiling is my superpower 😊", "Fluffy cloud reporting 🌥️", "Snow? Where's the snow? ❄️"],
            ["Brush time is the best! 🪮", "Being sweet comes naturally 🍬", "Run. Play. Repeat. 🔄"],
            ["Elegance in every step 🩰", "Smarty paws over here 🎓", "Poodle perfection 💅"]
        ]
        
        let catNames = ["Bibi", "Dudu", "Fifi", "Meimei", "Neon", "Xiabao", "Mia", "Tutu", "Xianbei", "Chacha", "Yaya", "Er Gou", "Chouchou"]
        let dogNames = ["Oscar", "Loki", "Nana", "Richard", "Tata", "Caicai", "Mia", "Nova", "Haha", "Jiujiu", "Toast"]
        
        if pet.type == .cat {
            if let index = catNames.firstIndex(where: { pet.name.contains($0) }) {
                return catCaptions[index]
            }
        } else {
            if let index = dogNames.firstIndex(where: { pet.name.contains($0) }) {
                return dogCaptions[index]
            }
        }
        
        return pet.type == .cat ?
            ["Living my best life 🐱", "Meow mood today 😸", "Purrfect day ✨"] :
            ["Woof woof! 🐕", "Best day ever! 🎉", "Living the dream 💭"]
    }
}

// MARK: - Social View (Main)
struct SocialView: View {
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var gamificationManager: GamificationManager
    @StateObject private var storyManager = StoryManager()
    
    @State private var selectedTab: SocialTab = .feed
    @State private var showCreatePost = false
    @State private var showCreateDiary = false
    @State private var showCreateStory = false
    @State private var animateContent = false
    
    enum SocialTab: String, CaseIterable {
        case feed = "Feed"
        case diary = "Diary"
        case matching = "Find Friends"
        
        var icon: String {
            switch self {
            case .feed: return "rectangle.stack.fill"
            case .diary: return "book.fill"
            case .matching: return "heart.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundSecondary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    PetStoriesSection(storyManager: storyManager, showCreateStory: $showCreateStory)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : -20)
                    
                    SocialTabSelector(selectedTab: $selectedTab)
                        .padding(.top, 8)
                        .opacity(animateContent ? 1 : 0)
                    
                    TabView(selection: $selectedTab) {
                        CommunityFeedView(showCreatePost: $showCreatePost)
                            .tag(SocialTab.feed)
                        
                        DiaryFeedView(showCreateDiary: $showCreateDiary)
                            .tag(SocialTab.diary)
                        
                        TinderStyleMatchingView()
                            .tag(SocialTab.matching)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == .diary {
                            showCreateDiary = true
                        } else if selectedTab == .feed {
                            showCreatePost = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primary700)
                    }
                    .opacity(selectedTab == .matching ? 0 : 1)
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .sheet(isPresented: $showCreateDiary) {
                CreateDiaryEntryView()
            }
            .fullScreenCover(isPresented: $showCreateStory) {
                CreateStoryView(storyManager: storyManager)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateContent = true
                }
            }
        }
    }
}

// MARK: - Pet Stories Section
struct PetStoriesSection: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var appState: AppState
    @ObservedObject var storyManager: StoryManager
    @Binding var showCreateStory: Bool
    @State private var selectedPet: Pet?
    @State private var selectedUserStory: UserStory?
    @State private var showStoryViewer = false
    @State private var showUserStoryViewer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Stories")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Text("\(petDataManager.pets.count + storyManager.userStories.count) stories")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.primary600)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    AddStoryButton {
                        showCreateStory = true
                    }
                    
                    ForEach(storyManager.userStories) { story in
                        UserStoryCircle(story: story, storyManager: storyManager)
                            .onTapGesture {
                                selectedUserStory = story
                                showUserStoryViewer = true
                                HapticManager.impact(.light)
                            }
                    }
                    
                    if !storyManager.userStories.isEmpty {
                        Rectangle()
                            .fill(AppColors.neutral200)
                            .frame(width: 1, height: 50)
                    }
                    
                    ForEach(petDataManager.pets) { pet in
                        RealPetStoryCircle(pet: pet)
                            .onTapGesture {
                                selectedPet = pet
                                showStoryViewer = true
                                HapticManager.impact(.light)
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 8)
        .background(Color.white)
        .fullScreenCover(isPresented: $showStoryViewer) {
            if let pet = selectedPet {
                PetStoryViewerView(pet: pet, allPets: petDataManager.pets, isPresented: $showStoryViewer)
            }
        }
        .fullScreenCover(isPresented: $showUserStoryViewer) {
            if let story = selectedUserStory {
                UserStoryViewerView(story: story, storyManager: storyManager, isPresented: $showUserStoryViewer)
            }
        }
    }
}

// MARK: - User Story Circle
struct UserStoryCircle: View {
    let story: UserStory
    @ObservedObject var storyManager: StoryManager
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: story.isViewed ?
                                [AppColors.neutral300, AppColors.neutral400, AppColors.neutral300] :
                                [AppColors.primary400, AppColors.primary600, AppColors.primary500, AppColors.primary400],
                            center: .center,
                            startAngle: .degrees(isAnimating ? 0 : 360),
                            endAngle: .degrees(isAnimating ? 360 : 720)
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 72, height: 72)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 66, height: 66)
                
                if let image = storyManager.loadStoryImage(named: story.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(AppColors.primary100)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary400)
                        )
                }
            }
            
            Text("Your Story")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .frame(width: 70)
        }
        .onAppear {
            if !story.isViewed {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Real Pet Story Circle
struct RealPetStoryCircle: View {
    let pet: Pet
    @State private var isAnimating = false
    
    var gradientColors: [Color] {
        [AppColors.primary400, AppColors.primary600, AppColors.primary500]
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: gradientColors + [gradientColors[0]],
                            center: .center,
                            startAngle: .degrees(isAnimating ? 0 : 360),
                            endAngle: .degrees(isAnimating ? 360 : 720)
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 72, height: 72)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 66, height: 66)
                
                if let uiImage = UIImage(named: pet.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary100, AppColors.primary200],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary500)
                        )
                }
                
                Circle()
                    .fill(AppColors.primary600)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    )
                    .offset(x: 24, y: 24)
            }
            
            Text(pet.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .frame(width: 70)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Add Story Button
struct AddStoryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary100, AppColors.primary50],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 66, height: 66)
                    
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                        .foregroundColor(AppColors.primary400)
                        .frame(width: 66, height: 66)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppColors.primary600)
                }
                
                Text("Add Story")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Social Tab Selector
struct SocialTabSelector: View {
    @Binding var selectedTab: SocialView.SocialTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SocialView.SocialTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    HapticManager.impact(.light)
                }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14))
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(selectedTab == tab ? AppColors.primary700 : AppColors.textTertiary)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(selectedTab == tab ? AppColors.primary700 : Color.clear)
                            .frame(height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}

// MARK: - Tinder Style Matching View (Unified Colors)
struct TinderStyleMatchingView: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var showMatch = false
    @State private var matchedPet: Pet?
    @State private var likedPets: [Pet] = []
    @State private var passedPets: [Pet] = []
    @State private var showChatSheet = false
    @State private var chatPet: Pet?
    
    var remainingPets: [Pet] {
        petDataManager.pets.filter { pet in
            !likedPets.contains(where: { $0.id == pet.id }) &&
            !passedPets.contains(where: { $0.id == pet.id })
        }
    }
    
    var backgroundCardIndices: [Int] {
        let count = min(remainingPets.count, 3)
        guard count > 1 else { return [] }
        return Array((1..<count).reversed())
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primary50, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Card Stack
                ZStack {
                    if remainingPets.isEmpty {
                        EmptyMatchesView(onReset: resetMatches)
                    } else {
                        ForEach(backgroundCardIndices, id: \.self) { index in
                            PremiumSwipeCard(pet: remainingPets[index])
                                .scaleEffect(1 - CGFloat(index) * 0.05)
                                .offset(y: CGFloat(index) * 10)
                                .allowsHitTesting(false)
                        }
                        
                        if let topPet = remainingPets.first {
                            PremiumSwipeCard(pet: topPet)
                                .offset(offset)
                                .rotationEffect(.degrees(rotation))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            offset = value.translation
                                            rotation = Double(value.translation.width / 20)
                                        }
                                        .onEnded { value in
                                            handleSwipeEnd(value: value, pet: topPet)
                                        }
                                )
                                .overlay(
                                    PremiumSwipeOverlay(offset: offset)
                                )
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Action buttons - Unified color scheme
                if !remainingPets.isEmpty {
                    HStack(spacing: 20) {
                        // Pass button
                        Button(action: { passCurrentPet() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: AppColors.primary200.opacity(0.5), radius: 10, x: 0, y: 4)
                                
                                Circle()
                                    .stroke(AppColors.neutral300, lineWidth: 1.5)
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppColors.neutral500)
                            }
                        }
                        
                        // Super like - Star button
                        Button(action: { superLikeCurrentPet() }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.primary300, AppColors.primary500],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .shadow(color: AppColors.primary400.opacity(0.4), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "star.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Like button
                        Button(action: { likeCurrentPet() }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.primary500, AppColors.primary700],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                    .shadow(color: AppColors.primary600.opacity(0.4), radius: 10, x: 0, y: 4)
                                
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 10)
                }
            }
            
            // Match popup
            if showMatch, let pet = matchedPet {
                PremiumMatchPopupView(pet: pet, isPresented: $showMatch) {
                    chatPet = pet
                    showChatSheet = true
                }
            }
        }
        .sheet(isPresented: $showChatSheet) {
            if let pet = chatPet {
                PremiumPetChatView(pet: pet)
            }
        }
    }
    
    private func handleSwipeEnd(value: DragGesture.Value, pet: Pet) {
        let threshold: CGFloat = 100
        
        if value.translation.width > threshold {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = CGSize(width: 500, height: 0)
            }
            HapticManager.notification(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                likedPets.append(pet)
                offset = .zero
                rotation = 0
                
                if Bool.random() {
                    matchedPet = pet
                    showMatch = true
                }
            }
        } else if value.translation.width < -threshold {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = CGSize(width: -500, height: 0)
            }
            HapticManager.impact(.medium)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                passedPets.append(pet)
                offset = .zero
                rotation = 0
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = .zero
                rotation = 0
            }
        }
    }
    
    private func likeCurrentPet() {
        guard let pet = remainingPets.first else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = CGSize(width: 500, height: 0)
        }
        HapticManager.notification(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            likedPets.append(pet)
            offset = .zero
            rotation = 0
            
            if Bool.random() {
                matchedPet = pet
                showMatch = true
            }
        }
    }
    
    private func passCurrentPet() {
        guard let pet = remainingPets.first else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = CGSize(width: -500, height: 0)
        }
        HapticManager.impact(.medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            passedPets.append(pet)
            offset = .zero
            rotation = 0
        }
    }
    
    private func superLikeCurrentPet() {
        guard let pet = remainingPets.first else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = CGSize(width: 0, height: -500)
        }
        HapticManager.notification(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            likedPets.append(pet)
            offset = .zero
            rotation = 0
            matchedPet = pet
            showMatch = true
        }
    }
    
    private func resetMatches() {
        likedPets = []
        passedPets = []
    }
}

// MARK: - Premium Swipe Card
struct PremiumSwipeCard: View {
    let pet: Pet
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Pet image
                if let uiImage = UIImage(named: pet.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary100, AppColors.primary200],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.primary400)
                        )
                }
                
                // Gradient overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Info
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .bottom, spacing: 10) {
                        Text(pet.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Pet type badge
                        HStack(spacing: 4) {
                            Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 12))
                            Text(pet.type == .cat ? "Cat" : "Dog")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColors.primary600.opacity(0.8))
                        .cornerRadius(12)
                    }
                    
                    Text(pet.breed)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Personality tags
                    HStack(spacing: 8) {
                        ForEach(pet.personality.prefix(3), id: \.self) { trait in
                            Text(trait)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(14)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
        }
    }
}

// MARK: - Premium Swipe Overlay
struct PremiumSwipeOverlay: View {
    let offset: CGSize
    
    var body: some View {
        ZStack {
            // Like overlay
            if offset.width > 0 {
                HStack {
                    VStack {
                        Text("LIKE")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundColor(AppColors.primary600)
                            .padding(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.primary600, lineWidth: 4)
                            )
                            .rotationEffect(.degrees(-20))
                            .padding(.top, 50)
                            .padding(.leading, 24)
                        Spacer()
                    }
                    Spacer()
                }
                .opacity(Double(offset.width / 100))
            }
            
            // Nope overlay
            if offset.width < 0 {
                HStack {
                    Spacer()
                    VStack {
                        Text("NOPE")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundColor(AppColors.neutral500)
                            .padding(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.neutral500, lineWidth: 4)
                            )
                            .rotationEffect(.degrees(20))
                            .padding(.top, 50)
                            .padding(.trailing, 24)
                        Spacer()
                    }
                }
                .opacity(Double(-offset.width / 100))
            }
        }
    }
}

// MARK: - Premium Match Popup View
struct PremiumMatchPopupView: View {
    let pet: Pet
    @Binding var isPresented: Bool
    let onChat: () -> Void
    @State private var animate = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Confetti effect
            if showConfetti {
                MatchConfettiView()
                    .ignoresSafeArea()
            }
            
            // Centered content
            VStack(spacing: 24) {
                Spacer()
                
                // Title with animation
                Text("It's a Match!")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1 : 0.5)
                    .opacity(animate ? 1 : 0)
                
                // Pet image with glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(AppColors.primary400.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)
                    
                    if let uiImage = UIImage(named: pet.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [AppColors.primary400, AppColors.primary600],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 5
                                    )
                            )
                            .shadow(color: AppColors.primary600.opacity(0.5), radius: 25)
                    }
                }
                .scaleEffect(animate ? 1 : 0.3)
                .opacity(animate ? 1 : 0)
                
                // Pet name
                VStack(spacing: 6) {
                    Text(pet.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("wants to be friends!")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(animate ? 1 : 0)
                
                Spacer()
                
                // Actions
                VStack(spacing: 14) {
                    Button(action: {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onChat()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 18))
                            Text("Send Message")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primary500, AppColors.primary700],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: AppColors.primary700.opacity(0.5), radius: 15, x: 0, y: 8)
                    }
                    
                    Button(action: { isPresented = false }) {
                        Text("Keep Swiping")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .opacity(animate ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showConfetti = true
            }
            HapticManager.notification(.success)
        }
    }
}

// MARK: - Match Confetti View
struct MatchConfettiView: View {
    @State private var particles: [MatchConfettiParticle] = []
    
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
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles(in size: CGSize) {
        let colors: [Color] = [AppColors.primary400, AppColors.primary500, AppColors.primary600, .white, AppColors.primary200]
        
        for _ in 0..<50 {
            let particle = MatchConfettiParticle(
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -20),
                color: colors.randomElement() ?? AppColors.primary500,
                size: CGFloat.random(in: 4...10),
                opacity: 1.0
            )
            particles.append(particle)
        }
        
        // Animate particles falling
        for i in 0..<particles.count {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2...4)
            
            withAnimation(.easeIn(duration: duration).delay(delay)) {
                particles[i].position.y = size.height + 50
                particles[i].position.x += CGFloat.random(in: -100...100)
            }
            
            withAnimation(.easeIn(duration: duration * 0.8).delay(delay + duration * 0.5)) {
                particles[i].opacity = 0
            }
        }
    }
}

struct MatchConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

// MARK: - Empty Matches View
struct EmptyMatchesView: View {
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart.circle")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary400)
            }
            
            Text("No more pets!")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text("You've seen all the available playmates.\nCheck back later for new friends!")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Button(action: onReset) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Start Over")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(AppColors.primary600)
                .cornerRadius(25)
                .shadow(color: AppColors.primary600.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 10)
        }
        .padding(40)
    }
}

// MARK: - Premium Pet Chat View
struct PremiumPetChatView: View {
    let pet: Pet
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var messages: [PetChatMessage] = []
    @State private var showQuickReplies = true
    
    let quickReplies = [
        "Hi there! 👋",
        "Want to play? 🎾",
        "You're so cute! 😍",
        "When can we meet? 📅"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Pet header
                HStack(spacing: 14) {
                    if let uiImage = UIImage(named: pet.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(AppColors.primary200)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                    .foregroundColor(AppColors.primary500)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pet.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Online")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Chat content
                ScrollView {
                    VStack(spacing: 16) {
                        // Match indicator
                        VStack(spacing: 12) {
                            if let uiImage = UIImage(named: pet.image) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            }
                            
                            Text("You matched with \(pet.name)!")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("Start the conversation")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        
                        // Messages
                        ForEach(messages) { message in
                            HStack {
                                if message.isFromUser {
                                    Spacer()
                                }
                                
                                Text(message.text)
                                    .font(.system(size: 15))
                                    .foregroundColor(message.isFromUser ? .white : AppColors.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        message.isFromUser ?
                                        AnyView(
                                            LinearGradient(
                                                colors: [AppColors.primary500, AppColors.primary600],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        ) :
                                        AnyView(AppColors.neutral100)
                                    )
                                    .cornerRadius(20)
                                
                                if !message.isFromUser {
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Quick replies
                        if showQuickReplies && messages.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Quick replies")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppColors.textTertiary)
                                    .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(quickReplies, id: \.self) { reply in
                                            Button(action: {
                                                messageText = reply
                                                sendMessage()
                                            }) {
                                                Text(reply)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppColors.primary700)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 10)
                                                    .background(AppColors.primary100)
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .background(AppColors.backgroundSecondary)
                
                // Message input
                HStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        
                        TextField("Type a message...", text: $messageText)
                            .font(.system(size: 15))
                        
                        Button(action: {}) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.neutral100)
                    .cornerRadius(25)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: messageText.isEmpty ? [AppColors.neutral300, AppColors.neutral300] : [AppColors.primary500, AppColors.primary600],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(16)
                .background(Color.white)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        messages.append(PetChatMessage(text: messageText, isFromUser: true))
        messageText = ""
        showQuickReplies = false
        HapticManager.impact(.light)
        
        // Simulate pet response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responses = [
                "Woof! 🐕",
                "Meow~ 😸",
                "*wags tail excitedly* 🎉",
                "*purrs happily* 💕"
            ]
            messages.append(PetChatMessage(text: responses.randomElement() ?? "❤️", isFromUser: false))
        }
    }
}

struct PetChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}

// MARK: - Community Feed View
struct CommunityFeedView: View {
    @EnvironmentObject var communityManager: CommunityManager
    @Binding var showCreatePost: Bool
    @State private var selectedCategory: CommunityPost.PostCategory? = nil
    
    var filteredPosts: [CommunityPost] {
        if let category = selectedCategory {
            return communityManager.posts.filter { $0.category == category }
        }
        return communityManager.posts
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        SocialCategoryChip(
                            title: "All",
                            icon: "square.grid.2x2.fill",
                            isSelected: selectedCategory == nil
                        ) { selectedCategory = nil }
                        
                        ForEach(CommunityPost.PostCategory.allCases, id: \.self) { category in
                            SocialCategoryChip(
                                title: category.rawValue.capitalized,
                                icon: iconForCategory(category),
                                isSelected: selectedCategory == category
                            ) { selectedCategory = category }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                
                // Posts
                if filteredPosts.isEmpty {
                    EmptyFeedView(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "No posts yet",
                        subtitle: "Be the first to share something!",
                        actionTitle: "Create Post"
                    ) {
                        showCreatePost = true
                    }
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPosts) { post in
                            SocialPostCard(post: post)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(AppColors.backgroundSecondary)
    }
    
    func iconForCategory(_ category: CommunityPost.PostCategory) -> String {
        switch category {
        case .experience: return "star.fill"
        case .question: return "questionmark.circle.fill"
        case .tips: return "lightbulb.fill"
        case .showcase: return "photo.fill"
        case .review: return "star.bubble.fill"
        }
    }
}

// MARK: - Social Category Chip
struct SocialCategoryChip: View {
    let title: String
    let icon: String
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
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ?
                          LinearGradient(colors: [AppColors.primary600, AppColors.primary700], startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [Color.white, Color.white], startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: isSelected ? AppColors.primary600.opacity(0.3) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Social Post Card
struct SocialPostCard: View {
    let post: CommunityPost
    @State private var isLiked = false
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary200, AppColors.primary300],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(post.authorName.prefix(1)))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primary700)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(post.category.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text(post.timeAgo)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
            }
            
            // Content
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(5)
            
            // Actions
            HStack(spacing: 24) {
                Button(action: {
                    isLiked.toggle()
                    HapticManager.impact(.light)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? AppColors.primary600 : AppColors.textSecondary)
                        Text("\(post.likes + (isLiked ? 1 : 0))")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Button(action: { showComments.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(AppColors.textSecondary)
                        Text("\(post.comments.count)")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Empty Feed View
struct EmptyFeedView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primary400)
            }
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.primary600)
                    .cornerRadius(25)
            }
        }
        .padding(40)
    }
}

// MARK: - Diary Feed View (Enhanced)
struct DiaryFeedView: View {
    @EnvironmentObject var diaryManager: DiaryManager
    @Binding var showCreateDiary: Bool
    @State private var selectedMood: DiaryEntry.PetMood?
    
    var filteredEntries: [DiaryEntry] {
        if let mood = selectedMood {
            return diaryManager.entries.filter { $0.mood == mood }
        }
        return diaryManager.entries
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Mood filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        MoodFilterChip(mood: nil, isSelected: selectedMood == nil) {
                            selectedMood = nil
                        }
                        
                        ForEach(DiaryEntry.PetMood.allCases, id: \.self) { mood in
                            MoodFilterChip(mood: mood, isSelected: selectedMood == mood) {
                                selectedMood = mood
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                
                if filteredEntries.isEmpty {
                    EmptyFeedView(
                        icon: "book.fill",
                        title: "No diary entries",
                        subtitle: "Start documenting your pet's adventures!",
                        actionTitle: "Write Entry"
                    ) {
                        showCreateDiary = true
                    }
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEntries) { entry in
                            DiaryEntryCardEnhanced(entry: entry)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(AppColors.backgroundSecondary)
    }
}

// MARK: - Mood Filter Chip
struct MoodFilterChip: View {
    let mood: DiaryEntry.PetMood?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let mood = mood {
                    Image(systemName: mood.icon)
                        .font(.system(size: 14))
                    Text(mood.rawValue)
                        .font(.system(size: 13, weight: .medium))
                } else {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 12))
                    Text("All")
                        .font(.system(size: 13, weight: .medium))
                }
            }
            .foregroundColor(isSelected ? .white : (mood?.color ?? AppColors.textSecondary))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? (mood?.color ?? AppColors.primary600) : (mood?.color.opacity(0.1) ?? Color.white))
            )
            .shadow(color: isSelected ? (mood?.color.opacity(0.3) ?? AppColors.primary600.opacity(0.3)) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Enhanced Diary Entry Card
struct DiaryEntryCardEnhanced: View {
    let entry: DiaryEntry
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var appState: AppState
    @State private var isLiked = false
    @State private var isSaved = false
    @State private var showFullEntry = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with mood indicator
            HStack(spacing: 12) {
                // Pet avatar with mood ring
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [entry.mood.color, entry.mood.color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .fill(entry.mood.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: entry.mood.icon)
                                .font(.system(size: 22))
                                .foregroundColor(entry.mood.color)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(entry.petName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        // Mood badge
                        Text(entry.mood.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(entry.mood.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(entry.mood.color.opacity(0.15))
                            .cornerRadius(8)
                    }
                    
                    HStack(spacing: 6) {
                        Text("by \(entry.authorName)")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("•")
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(timeAgo(from: entry.createdAt))
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                Spacer()
                
                // Save button
                Button(action: {
                    isSaved.toggle()
                    diaryManager.toggleSaveEntry(entryId: entry.id)
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(isSaved ? AppColors.primary600 : AppColors.textTertiary)
                }
            }
            
            // Title
            Text(entry.title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            // Content preview
            Text(entry.content)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(4)
                .lineSpacing(3)
            
            // Read more
            if entry.content.count > 200 {
                Button(action: { showFullEntry = true }) {
                    Text("Read more...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primary600)
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Actions
            HStack(spacing: 24) {
                // Like
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isLiked.toggle()
                        diaryManager.toggleLike(entryId: entry.id, userId: appState.currentUser?.id ?? "guest")
                    }
                    HapticManager.impact(.light)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? AppColors.primary600 : AppColors.textTertiary)
                            .scaleEffect(isLiked ? 1.15 : 1)
                        Text("\(entry.likes)")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Comments
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(AppColors.textTertiary)
                        Text("\(entry.comments.count)")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Share
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Spacer()
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        .onAppear {
            isLiked = entry.likedBy.contains(appState.currentUser?.id ?? "")
            isSaved = diaryManager.isEntrySaved(entry.id)
        }
    }
    
    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

// MARK: - Create Post View (Enhanced)
struct CreatePostView: View {
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gamificationManager: GamificationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var content = ""
    @State private var selectedCategory: CommunityPost.PostCategory = .experience
    @State private var isPosting = false
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // User header
                    HStack(spacing: 14) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary200, AppColors.primary300],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String((appState.currentUser?.name ?? "G").prefix(1)))
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(AppColors.primary700)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appState.currentUser?.name ?? "Guest")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Posting to Community")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Category selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(CommunityPost.PostCategory.allCases, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                        HapticManager.impact(.light)
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 14))
                                            Text(category.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(selectedCategory == category ? .white : AppColors.primary600)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ?
                                                      LinearGradient(colors: [AppColors.primary500, AppColors.primary600], startPoint: .leading, endPoint: .trailing) :
                                                      LinearGradient(colors: [AppColors.primary100, AppColors.primary100], startPoint: .leading, endPoint: .trailing))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Content input
                    VStack(alignment: .leading, spacing: 10) {
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("What's on your mind? Share your pet stories, tips, or questions...")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textTertiary)
                                    .padding(.horizontal, 4)
                                    .padding(.top, 8)
                            }
                            
                            TextEditor(text: $content)
                                .font(.system(size: 16))
                                .frame(minHeight: 150)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .padding(16)
                        .background(AppColors.neutral100)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Character count
                        HStack {
                            Spacer()
                            Text("\(content.count)/500")
                                .font(.system(size: 13))
                                .foregroundColor(content.count > 500 ? AppColors.error : AppColors.textTertiary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Add photos button
                    Button(action: { showImagePicker = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 20))
                            
                            Text("Add Photos")
                                .font(.system(size: 15, weight: .medium))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(AppColors.primary600)
                        .padding(16)
                        .background(AppColors.primary50)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    
                    // Tips card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.warning)
                            
                            Text("Tips for great posts")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(text: "Share specific experiences or ask clear questions")
                            TipRow(text: "Add photos to make your post more engaging")
                            TipRow(text: "Be respectful and supportive to other pet owners")
                        }
                    }
                    .padding(16)
                    .background(AppColors.warning.opacity(0.1))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: submitPost) {
                        if isPosting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Post")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(canPost ? AppColors.primary600 : AppColors.neutral400)
                    .disabled(!canPost || isPosting)
                }
            }
        }
    }
    
    var canPost: Bool {
        !content.isEmpty && content.count <= 500
    }
    
    func submitPost() {
        guard canPost else { return }
        
        isPosting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            communityManager.createPost(
                authorId: appState.currentUser?.id ?? "guest",
                authorName: appState.currentUser?.name ?? "Guest User",
                content: content,
                category: selectedCategory
            )
            
            gamificationManager.incrementAchievement(id: "social_butterfly")
            gamificationManager.addPoints(15, reason: "Shared a community post")
            
            isPosting = false
            HapticManager.notification(.success)
            dismiss()
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(AppColors.success)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Create Diary Entry View (Enhanced)
struct CreateDiaryEntryView: View {
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gamificationManager: GamificationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: DiaryEntry.PetMood = .happy
    @State private var selectedPet: Pet?
    @State private var isPublic = true
    @State private var isPosting = false
    @State private var showMoodPicker = false
    
    var availablePets: [Pet] {
        petDataManager.userPets + Array(petDataManager.pets.prefix(8))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Pet selector
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Select Pet")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("*")
                                .foregroundColor(AppColors.error)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(availablePets) { pet in
                                    DiaryPetSelector(pet: pet, isSelected: selectedPet?.id == pet.id) {
                                        selectedPet = pet
                                        HapticManager.impact(.light)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Mood selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How is your pet feeling?")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(DiaryEntry.PetMood.allCases, id: \.self) { mood in
                                    DiaryMoodSelector(mood: mood, isSelected: selectedMood == mood) {
                                        selectedMood = mood
                                        HapticManager.impact(.light)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Title input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Title")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextField("Give your entry a catchy title...", text: $title)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(AppColors.neutral100)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    
                    // Content input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Story")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("Tell us about your pet's day, adventures, funny moments...")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textTertiary)
                                    .padding(.horizontal, 4)
                                    .padding(.top, 8)
                            }
                            
                            TextEditor(text: $content)
                                .font(.system(size: 16))
                                .frame(minHeight: 150)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .padding(16)
                        .background(AppColors.neutral100)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    
                    // Privacy toggle
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(isPublic ? AppColors.primary100 : AppColors.neutral100)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: isPublic ? "globe" : "lock.fill")
                                .font(.system(size: 18))
                                .foregroundColor(isPublic ? AppColors.primary600 : AppColors.textSecondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isPublic ? "Public" : "Private")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(isPublic ? "Everyone can see this entry" : "Only you can see this entry")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textTertiary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isPublic)
                            .tint(AppColors.primary600)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Writing prompts
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary500)
                            
                            Text("Need inspiration?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(writingPrompts, id: \.self) { prompt in
                                Button(action: {
                                    title = prompt
                                    HapticManager.impact(.light)
                                }) {
                                    Text(prompt)
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.primary700)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(AppColors.primary50)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 10)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("New Diary Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: submitEntry) {
                        if isPosting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Post")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(canPost ? AppColors.primary600 : AppColors.neutral400)
                    .disabled(!canPost || isPosting)
                }
            }
        }
    }
    
    let writingPrompts = [
        "Morning routine",
        "Favorite toy",
        "Funny moment",
        "New trick learned",
        "Nap time",
        "Meal time"
    ]
    
    var canPost: Bool {
        selectedPet != nil && !title.isEmpty && !content.isEmpty
    }
    
    func submitEntry() {
        guard canPost, let pet = selectedPet else { return }
        
        isPosting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            diaryManager.createEntry(
                petId: pet.id,
                petName: pet.name,
                authorId: appState.currentUser?.id ?? "guest",
                authorName: appState.currentUser?.name ?? "Guest",
                title: title,
                content: content,
                mood: selectedMood,
                isPublic: isPublic
            )
            
            gamificationManager.incrementAchievement(id: "diary_keeper")
            gamificationManager.addPoints(20, reason: "Created a diary entry")
            
            isPosting = false
            HapticManager.notification(.success)
            dismiss()
        }
    }
}

// MARK: - Diary Pet Selector
struct DiaryPetSelector: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ?
                              LinearGradient(colors: [AppColors.primary500, AppColors.primary600], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [AppColors.neutral100, AppColors.neutral200], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 64, height: 64)
                    
                    if let uiImage = UIImage(named: pet.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                            .font(.system(size: 26))
                            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                    }
                    
                    if isSelected {
                        Circle()
                            .stroke(AppColors.primary600, lineWidth: 3)
                            .frame(width: 68, height: 68)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.success)
                            .background(Circle().fill(Color.white).frame(width: 18, height: 18))
                            .offset(x: 22, y: -22)
                    }
                }
                
                Text(pet.name)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primary700 : AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Diary Mood Selector
struct DiaryMoodSelector: View {
    let mood: DiaryEntry.PetMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mood.color : mood.color.opacity(0.15))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: mood.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : mood.color)
                }
                
                Text(mood.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? mood.color : AppColors.textTertiary)
            }
            .scaleEffect(isSelected ? 1.05 : 1)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}

// MARK: - Create Story View (Instagram-style)
struct CreateStoryView: View {
    @ObservedObject var storyManager: StoryManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedImage: UIImage?
    @State private var storyText = ""
    @State private var textPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.65)
    @State private var selectedTextColor = Color.white
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var isPosting = false
    @State private var showTextEditor = false
    @State private var isDraggingText = false
    
    let textColors: [Color] = [.white, .black, AppColors.primary500, AppColors.primary600, Color(hex: "FFD93D"), Color(hex: "6BCB77")]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = selectedImage {
                GeometryReader { geo in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                        
                        VStack {
                            LinearGradient(
                                colors: [Color.black.opacity(0.5), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 150)
                            
                            Spacer()
                            
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 200)
                        }
                        
                        if !storyText.isEmpty {
                            Text(storyText)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(selectedTextColor)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.3))
                                )
                                .position(textPosition)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDraggingText = true
                                            textPosition = value.location
                                        }
                                        .onEnded { _ in
                                            isDraggingText = false
                                        }
                                )
                                .animation(.spring(response: 0.3), value: textPosition)
                        }
                        
                        if storyText.isEmpty {
                            VStack {
                                Spacer()
                                Button(action: { showTextEditor = true }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "textformat")
                                        Text("Tap to add text")
                                    }
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(25)
                                }
                                .padding(.bottom, 150)
                            }
                        }
                        
                        // Top controls
                        VStack {
                            HStack {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    ForEach(textColors, id: \.self) { color in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedTextColor == color ? Color.white : Color.clear, lineWidth: 3)
                                            )
                                            .shadow(color: .black.opacity(0.3), radius: 2)
                                            .onTapGesture {
                                                selectedTextColor = color
                                                HapticManager.impact(.light)
                                            }
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { showTextEditor = true }) {
                                    Image(systemName: "textformat")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 60)
                            
                            Spacer()
                        }
                        
                        // Bottom controls
                        VStack {
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Button(action: { showImagePicker = true }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 22))
                                        Text("Change")
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 70)
                                }
                                
                                Spacer()
                                
                                Button(action: postStory) {
                                    HStack(spacing: 8) {
                                        if isPosting {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Text("Share Story")
                                                .font(.system(size: 16, weight: .bold))
                                            Image(systemName: "arrow.right.circle.fill")
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.primary500, AppColors.primary700],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(30)
                                    .shadow(color: AppColors.primary700.opacity(0.5), radius: 10, x: 0, y: 5)
                                }
                                .disabled(isPosting)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 50)
                        }
                    }
                }
                .ignoresSafeArea()
            } else {
                // Image selection screen
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Create Your Story")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Share a moment with the community")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: { showCamera = true }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary600)
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Take Photo")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Use your camera")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        
                        Button(action: { showImagePicker = true }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary400)
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Choose from Gallery")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Select existing photo")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 16)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            StoryImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showCamera) {
            StoryCameraPicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showTextEditor) {
            StoryTextEditorView(text: $storyText, isPresented: $showTextEditor)
        }
    }
    
    private func postStory() {
        guard let image = selectedImage else { return }
        
        isPosting = true
        
        let storyId = UUID().uuidString
        let imageName = storyManager.saveStoryImage(image, storyId: storyId)
        
        let story = UserStory(
            id: storyId,
            authorName: appState.currentUser?.name ?? "Me",
            imageName: imageName,
            text: storyText,
            textPosition: UserStory.TextPosition(
                x: textPosition.x / UIScreen.main.bounds.width,
                y: textPosition.y / UIScreen.main.bounds.height
            ),
            textColor: selectedTextColor.toHex()
        )
        
        storyManager.addStory(story)
        
        HapticManager.notification(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPosting = false
            dismiss()
        }
    }
}

// MARK: - Story Text Editor
struct StoryTextEditorView: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Add your caption")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 20)
                
                TextField("What's happening?", text: $text, axis: .vertical)
                    .font(.system(size: 22, weight: .medium))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick captions")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(["Living my best life ✨", "Perfect moment 📸", "Feeling blessed 🙏", "Good vibes only 🌈", "Making memories 💕"], id: \.self) { suggestion in
                                Button(action: { text = suggestion }) {
                                    Text(suggestion)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.primary700)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(AppColors.primary100)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("Add Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary700)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}

// MARK: - Story Image Picker
struct StoryImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: StoryImagePicker
        
        init(_ parent: StoryImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

// MARK: - Story Camera Picker
struct StoryCameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: StoryCameraPicker
        
        init(_ parent: StoryCameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - User Story Viewer
struct UserStoryViewerView: View {
    let story: UserStory
    @ObservedObject var storyManager: StoryManager
    @Binding var isPresented: Bool
    
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let image = storyManager.loadStoryImage(named: story.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    AppColors.primary200
                }
                
                VStack {
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    
                    Spacer()
                    
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 250)
                }
                .ignoresSafeArea()
                
                if !story.text.isEmpty {
                    Text(story.text)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: story.textColor))
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                        )
                        .position(
                            x: story.textPosition.x * geo.size.width,
                            y: story.textPosition.y * geo.size.height
                        )
                }
                
                VStack {
                    GeometryReader { barGeo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                            
                            Capsule()
                                .fill(Color.white)
                                .frame(width: barGeo.size.width * progress)
                        }
                    }
                    .frame(height: 3)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                    
                    HStack(spacing: 12) {
                        Circle()
                            .fill(AppColors.primary500)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(story.authorName.prefix(1)))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Story")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(timeAgo(from: story.createdAt))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                            timer?.invalidate()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            storyManager.deleteStory(id: story.id)
                            isPresented = false
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                Text("Delete")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
                
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            progress = 0
                        }
                    
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isPresented = false
                            timer?.invalidate()
                        }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPaused = true }
                        .onEnded { _ in isPaused = false }
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            storyManager.markAsViewed(id: story.id)
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        progress = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard !isPaused else { return }
            
            withAnimation(.linear(duration: 0.05)) {
                progress += 0.01
            }
            
            if progress >= 1.0 {
                isPresented = false
                timer?.invalidate()
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }
}

// MARK: - Pet Story Viewer
struct PetStoryViewerView: View {
    let pet: Pet
    let allPets: [Pet]
    @Binding var isPresented: Bool
    
    @State private var currentImageIndex = 0
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var currentCaption: String = ""
    
    var currentPetImages: [String] {
        pet.images.isEmpty ? [pet.image] : pet.images
    }
    
    var captions: [String] {
        PetStoryCaptions.getCaptions(for: pet)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let uiImage = UIImage(named: currentPetImages[currentImageIndex]) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    AppColors.primary200
                        .overlay(
                            Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.primary400)
                        )
                }
                
                VStack {
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    
                    Spacer()
                    
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 250)
                }
                .ignoresSafeArea()
                
                VStack {
                    HStack(spacing: 4) {
                        ForEach(Array(currentPetImages.enumerated()), id: \.offset) { index, _ in
                            GeometryReader { barGeo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.3))
                                    
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: progressWidth(for: index, totalWidth: barGeo.size.width))
                                }
                            }
                            .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                    
                    HStack(spacing: 12) {
                        if let uiImage = UIImage(named: pet.image) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pet.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(pet.breed)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                            timer?.invalidate()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(currentCaption)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text("\(Int.random(in: 1...12))h ago")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 50)
                }
                
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            goToPrevious()
                        }
                    
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            goToNext()
                        }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPaused = true }
                        .onEnded { _ in isPaused = false }
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            updateCaption()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateCaption() {
        if currentImageIndex < captions.count {
            currentCaption = captions[currentImageIndex]
        } else {
            currentCaption = captions[currentImageIndex % captions.count]
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        progress = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard !isPaused else { return }
            
            withAnimation(.linear(duration: 0.05)) {
                progress += 0.01
            }
            
            if progress >= 1.0 {
                goToNext()
            }
        }
    }
    
    private func goToNext() {
        if currentImageIndex < currentPetImages.count - 1 {
            currentImageIndex += 1
            progress = 0
            updateCaption()
        } else {
            isPresented = false
            timer?.invalidate()
        }
    }
    
    private func goToPrevious() {
        if currentImageIndex > 0 {
            currentImageIndex -= 1
            progress = 0
            updateCaption()
        }
    }
    
    private func progressWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < currentImageIndex {
            return totalWidth
        } else if index == currentImageIndex {
            return totalWidth * progress
        } else {
            return 0
        }
    }
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#FFFFFF"
        }
        
        let r = Int((components[0] * 255).rounded())
        let g = Int((components[1] * 255).rounded())
        let b = Int((components[2] * 255).rounded())
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview
struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
            .environmentObject(CommunityManager())
            .environmentObject(DiaryManager())
            .environmentObject(PetMatchingManager())
            .environmentObject(PetDataManager())
            .environmentObject(GamificationManager())
            .environmentObject(AppState())
    }
}
