//
//  SocialView.swift
//  CocoPetParadise
//
//  Instagram-style social hub with Tinder-style pet matching
//  Real pet photos, beautiful animations, swipe gestures
//

import SwiftUI

// MARK: - Social View (Main)
struct SocialView: View {
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var gamificationManager: GamificationManager
    
    @State private var selectedTab: SocialTab = .feed
    @State private var showCreatePost = false
    @State private var showCreateDiary = false
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
                // Background
                AppColors.backgroundSecondary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stories Section (Real Pet Stories)
                    PetStoriesSection()
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : -20)
                    
                    // Tab Selector
                    SocialTabSelector(selectedTab: $selectedTab)
                        .padding(.top, 8)
                        .opacity(animateContent ? 1 : 0)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        // Feed Tab
                        CommunityFeedView(showCreatePost: $showCreatePost)
                            .tag(SocialTab.feed)
                        
                        // Diary Tab
                        DiaryFeedView(showCreateDiary: $showCreateDiary)
                            .tag(SocialTab.diary)
                        
                        // Matching Tab - Tinder Style
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
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateContent = true
                }
            }
        }
    }
}

// MARK: - Pet Stories Section (Real Pets)
struct PetStoriesSection: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @State private var selectedPet: Pet?
    @State private var showStoryViewer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Pet Stories")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Text("\(petDataManager.pets.count) pets")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.primary600)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // Stories Carousel with Real Pets
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    // Add Story Button
                    AddStoryButton()
                    
                    // Real Pet Stories
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
    }
}

// MARK: - Real Pet Story Circle
struct RealPetStoryCircle: View {
    let pet: Pet
    @State private var isAnimating = false
    
    var gradientColors: [Color] {
        pet.type == .cat ?
            [AppColors.primary400, AppColors.primary600, AppColors.primary500] :
            [Color(hex: "FF6B6B"), Color(hex: "FF8E8E"), Color(hex: "FF5252")]
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Gradient ring with animation
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
                
                // White border
                Circle()
                    .fill(Color.white)
                    .frame(width: 66, height: 66)
                
                // Pet image
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
                
                // Type badge
                Circle()
                    .fill(pet.type == .cat ? AppColors.primary600 : Color(hex: "FF6B6B"))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    )
                    .offset(x: 24, y: 24)
            }
            
            // Pet name
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

// MARK: - Pet Story Viewer (Full Screen)
struct PetStoryViewerView: View {
    let pet: Pet
    let allPets: [Pet]
    @Binding var isPresented: Bool
    
    @State private var currentImageIndex = 0
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    
    var currentPetImages: [String] {
        pet.images.isEmpty ? [pet.image] : pet.images
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Current Image
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
                
                // Gradient overlay
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
                
                // Content overlay
                VStack {
                    // Progress bars
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
                    
                    // Header
                    HStack(spacing: 12) {
                        // Pet avatar
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
                        
                        // Close button
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
                    
                    // Pet info at bottom
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About \(pet.name)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Personality tags
                        FlowLayout(spacing: 8) {
                            ForEach(pet.personality, id: \.self) { trait in
                                Text(trait)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                        
                        // Favorite activities
                        if !pet.favoriteActivities.isEmpty {
                            Text("Loves: \(pet.favoriteActivities.joined(separator: ", "))")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial.opacity(0.5))
                            .cornerRadius(20)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 50)
                }
                
                // Tap areas for navigation
                HStack(spacing: 0) {
                    // Previous
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            goToPrevious()
                        }
                    
                    // Next
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
                goToNext()
            }
        }
    }
    
    private func goToNext() {
        if currentImageIndex < currentPetImages.count - 1 {
            currentImageIndex += 1
            progress = 0
        } else {
            isPresented = false
            timer?.invalidate()
        }
    }
    
    private func goToPrevious() {
        if currentImageIndex > 0 {
            currentImageIndex -= 1
            progress = 0
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

// MARK: - FlowLayout for tags
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

// MARK: - Tinder Style Matching View
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
            // Background gradient
            LinearGradient(
                colors: [AppColors.primary50, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Text("Find Playmates")
                        .font(.system(size: 0, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                   
                }
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Card Stack
                ZStack {
                    if remainingPets.isEmpty {
                        EmptyMatchesView(onReset: resetMatches)
                    } else {
                        // Background cards (show next 2)
                        ForEach(backgroundCardIndices, id: \.self) { index in
                            SwipeCard(pet: remainingPets[index])
                                .scaleEffect(1 - CGFloat(index) * 0.05)
                                .offset(y: CGFloat(index) * 10)
                                .allowsHitTesting(false)
                        }
                        
                        // Top card (interactive)
                        if let topPet = remainingPets.first {
                            SwipeCard(pet: topPet)
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
                                    SwipeOverlay(offset: offset)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .padding(.horizontal, 20)
                
                // Action Buttons
                if !remainingPets.isEmpty {
                    HStack(spacing: 16) {
                        // Pass button
                        ActionButton(
                            icon: "xmark",
                            color: Color(hex: "FF6B6B"),
                            size: 54
                        ) {
                            swipeLeft()
                        }
                        
                        // Super like button
                        ActionButton(
                            icon: "star.fill",
                            color: AppColors.warning,
                            size: 44
                        ) {
                            superLike()
                        }
                        
                        // Like button
                        ActionButton(
                            icon: "heart.fill",
                            color: AppColors.success,
                            size: 54
                        ) {
                            swipeRight()
                        }
                    }
                    .padding(.top, 16)
                }
                
                // Stats
                HStack(spacing: 24) {
                    StatPill(icon: "heart.fill", count: likedPets.count, label: "Matches", color: AppColors.success)
                    StatPill(icon: "xmark", count: passedPets.count, label: "Passed", color: AppColors.textTertiary)
                    StatPill(icon: "pawprint.fill", count: remainingPets.count, label: "Left", color: AppColors.primary600)
                }
                .padding(.top, 12)
                
                Spacer()
            }
            
            // Match overlay
            if showMatch, let pet = matchedPet {
                MatchSuccessOverlay(pet: pet, isPresented: $showMatch) {
                    // Send message action
                    chatPet = pet
                    showMatch = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showChatSheet = true
                    }
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .sheet(isPresented: $showChatSheet) {
            if let pet = chatPet {
                PetChatView(pet: pet)
            }
        }
    }
    
    private func handleSwipeEnd(value: DragGesture.Value, pet: Pet) {
        let threshold: CGFloat = 100
        
        if value.translation.width > threshold {
            // Swipe right - Like
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = CGSize(width: 500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                likedPets.append(pet)
                matchedPet = pet
                showMatch = true
                HapticManager.notification(.success)
                resetCardPosition()
            }
        } else if value.translation.width < -threshold {
            // Swipe left - Pass
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = CGSize(width: -500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                passedPets.append(pet)
                HapticManager.impact(.light)
                resetCardPosition()
            }
        } else {
            // Return to center
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                offset = .zero
                rotation = 0
            }
        }
    }
    
    private func swipeRight() {
        guard let pet = remainingPets.first else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = CGSize(width: 500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            likedPets.append(pet)
            matchedPet = pet
            showMatch = true
            HapticManager.notification(.success)
            resetCardPosition()
        }
    }
    
    private func swipeLeft() {
        guard let pet = remainingPets.first else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = CGSize(width: -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            passedPets.append(pet)
            HapticManager.impact(.light)
            resetCardPosition()
        }
    }
    
    private func superLike() {
        guard let pet = remainingPets.first else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = CGSize(width: 0, height: -500)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            likedPets.append(pet)
            matchedPet = pet
            showMatch = true
            HapticManager.notification(.success)
            resetCardPosition()
        }
    }
    
    private func resetCardPosition() {
        offset = .zero
        rotation = 0
    }
    
    private func resetMatches() {
        withAnimation {
            likedPets = []
            passedPets = []
        }
    }
}

// MARK: - Swipe Card
struct SwipeCard: View {
    let pet: Pet
    @State private var currentImageIndex = 0
    
    var images: [String] {
        pet.images.isEmpty ? [pet.image] : pet.images
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Image section
            ZStack(alignment: .bottom) {
                // Pet image with tap to change
                TabView(selection: $currentImageIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, imageName in
                        if let uiImage = UIImage(named: imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .tag(index)
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
                                        .font(.system(size: 60))
                                        .foregroundColor(AppColors.primary400)
                                )
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 260)
                
                // Image indicators
                HStack(spacing: 4) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, _ in
                        Capsule()
                            .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(width: index == currentImageIndex ? 20 : 6, height: 4)
                    }
                }
                .padding(.bottom, 12)
                
                // Gradient overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 100)
            }
            .frame(height: 260)
            .clipped()
            
            // Info section
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(pet.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            // Verified badge
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.info)
                        }
                        
                        Text(pet.breed)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
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
                }
                
                // Personality tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(pet.personality, id: \.self) { trait in
                            Text(trait)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppColors.primary700)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppColors.primary100)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Swipe Overlay
struct SwipeOverlay: View {
    let offset: CGSize
    
    var likeOpacity: Double {
        min(max(Double(offset.width) / 100, 0), 1)
    }
    
    var nopeOpacity: Double {
        min(max(Double(-offset.width) / 100, 0), 1)
    }
    
    var body: some View {
        ZStack {
            // LIKE overlay
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.success, lineWidth: 4)
                .background(AppColors.success.opacity(0.1).cornerRadius(16))
                .opacity(likeOpacity)
                .overlay(
                    VStack {
                        HStack {
                            Text("MATCH!")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(AppColors.success)
                                .rotationEffect(.degrees(-15))
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }
                    .opacity(likeOpacity)
                )
            
            // NOPE overlay
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "FF6B6B"), lineWidth: 4)
                .background(Color(hex: "FF6B6B").opacity(0.1).cornerRadius(16))
                .opacity(nopeOpacity)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Text("NOPE")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(Color(hex: "FF6B6B"))
                                .rotationEffect(.degrees(15))
                                .padding()
                        }
                        Spacer()
                    }
                    .opacity(nopeOpacity)
                )
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let color: Color
    var size: CGFloat = 60
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: size, height: size)
                    .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: size, height: size)
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
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
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary500)
            }
            
            VStack(spacing: 8) {
                Text("You've seen everyone!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Come back later for new furry friends\nor reset to see them again")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onReset) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Start Over")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppColors.primary500, AppColors.primary700],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(30)
                .shadow(color: AppColors.primary600.opacity(0.4), radius: 15, x: 0, y: 8)
            }
        }
        .padding(40)
    }
}

// MARK: - Match Success Overlay
struct MatchSuccessOverlay: View {
    let pet: Pet
    @Binding var isPresented: Bool
    let onSendMessage: () -> Void
    @State private var animateHeart = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 24) {
                // Animated hearts
                ZStack {
                    ForEach(0..<8, id: \.self) { index in
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primary400)
                            .offset(
                                x: animateHeart ? CGFloat.random(in: -100...100) : 0,
                                y: animateHeart ? CGFloat.random(in: -150...(-50)) : 0
                            )
                            .opacity(animateHeart ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.5)
                                .delay(Double(index) * 0.1),
                                value: animateHeart
                            )
                    }
                    
                    // Pet image
                    if let uiImage = UIImage(named: pet.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(color: AppColors.primary500.opacity(0.5), radius: 20)
                            .scaleEffect(showContent ? 1 : 0.5)
                    }
                }
                
                // Match text
                if showContent {
                    VStack(spacing: 8) {
                        Text("It's a Match! 🎉")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("You and \(pet.name) liked each other!")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: { onSendMessage() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "message.fill")
                                Text("Send Message")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primary500, AppColors.primary700],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                        }
                        
                        Button(action: { isPresented = false }) {
                            Text("Keep Swiping")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            animateHeart = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Social Tab Selector
struct SocialTabSelector: View {
    @Binding var selectedTab: SocialView.SocialTab
    @Namespace private var animation
    
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
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(selectedTab == tab ? AppColors.primary700 : AppColors.textSecondary)
                        
                        // Indicator
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 3)
                            
                            if selectedTab == tab {
                                Rectangle()
                                    .fill(AppColors.primary700)
                                    .frame(height: 3)
                                    .cornerRadius(2)
                                    .matchedGeometryEffect(id: "indicator", in: animation)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}

// MARK: - Add Story Button
struct AddStoryButton: View {
    var body: some View {
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

// MARK: - Keep existing views for compatibility
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

struct SocialPostCard: View {
    let post: CommunityPost
    @State private var isLiked = false
    @State private var showComments = false
    
    var categoryColor: Color {
        switch post.category {
        case .experience: return AppColors.primary600
        case .question: return AppColors.info
        case .tips: return AppColors.warning
        case .showcase: return Color(hex: "FF6B6B")
        case .review: return AppColors.success
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(post.authorName.prefix(1)))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(categoryColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(post.timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Spacer()
                
                Text(post.category.rawValue.capitalized)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(categoryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(categoryColor.opacity(0.12))
                    .cornerRadius(12)
            }
            
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(4)
            
            // Actions
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? Color(hex: "FF6B6B") : AppColors.textSecondary)
                            .scaleEffect(isLiked ? 1.2 : 1)
                        Text("\(post.likes + (isLiked ? 1 : 0))")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Button(action: { showComments = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                        Text("\(post.comments.count)")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppColors.primary700.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

struct DiaryFeedView: View {
    @EnvironmentObject var diaryManager: DiaryManager
    @Binding var showCreateDiary: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if diaryManager.entries.isEmpty {
                EmptyFeedView(
                    icon: "book.fill",
                    title: "No diary entries",
                    subtitle: "Start documenting your pet's adventures!",
                    actionTitle: "Write Entry"
                ) {
                    showCreateDiary = true
                }
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(diaryManager.entries) { entry in
                        DiaryCardLarge(entry: entry)
                    }
                }
                .padding(16)
            }
            
            Spacer(minLength: 100)
        }
        .background(AppColors.backgroundSecondary)
    }
}

struct DiaryCardLarge: View {
    let entry: DiaryEntry
    @State private var isLiked = false
    
    var moodColor: Color {
        switch entry.mood {
        case .happy: return AppColors.warning
        case .playful: return Color(hex: "FF6B6B")
        case .relaxed: return AppColors.success
        case .sleepy: return AppColors.info
        case .hungry: return Color(hex: "FF9F43")
        case .curious: return AppColors.primary600
        case .cuddly: return Color(hex: "FF6B9D")
        case .excited: return AppColors.warning
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(moodColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Text(entry.mood.emoji)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(entry.timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Spacer()
                
                Text(entry.mood.rawValue.capitalized)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(moodColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(moodColor.opacity(0.12))
                    .cornerRadius(12)
            }
            
            Text(entry.content)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(3)
            
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? Color(hex: "FF6B6B") : AppColors.textSecondary)
                        Text("\(entry.likes + (isLiked ? 1 : 0))")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(entry.comments.count)")
                }
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppColors.primary700.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

struct EmptyFeedView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primary500)
            }
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.primary700)
                    .cornerRadius(20)
            }
        }
    }
}

// Keep CreatePostView and CreateDiaryEntryView from original file
struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var communityManager: CommunityManager
    @State private var content = ""
    @State private var selectedCategory: CommunityPost.PostCategory = .experience
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(CommunityPost.PostCategory.allCases, id: \.self) { category in
                            SocialCategoryChip(
                                title: category.rawValue.capitalized,
                                icon: iconFor(category),
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Content
                TextEditor(text: $content)
                    .font(.system(size: 16))
                    .padding(12)
                    .frame(minHeight: 200)
                    .background(AppColors.neutral50)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        communityManager.createPost(
                            authorId: UUID().uuidString,
                            authorName: "You",
                            content: content,
                            category: selectedCategory
                        )
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(content.isEmpty ? AppColors.textTertiary : AppColors.primary700)
                    .disabled(content.isEmpty)
                }
            }
        }
    }
    
    func iconFor(_ category: CommunityPost.PostCategory) -> String {
        switch category {
        case .experience: return "star.fill"
        case .question: return "questionmark.circle.fill"
        case .tips: return "lightbulb.fill"
        case .showcase: return "photo.fill"
        case .review: return "star.bubble.fill"
        }
    }
}

struct CreateDiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var petDataManager: PetDataManager
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: DiaryEntry.PetMood = .happy
    @State private var selectedPet: Pet?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Pet selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Pet")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(petDataManager.pets.prefix(10)) { pet in
                                    Button(action: { selectedPet = pet }) {
                                        VStack(spacing: 6) {
                                            if let uiImage = UIImage(named: pet.image) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle()
                                                            .stroke(selectedPet?.id == pet.id ? AppColors.primary600 : Color.clear, lineWidth: 3)
                                                    )
                                            } else {
                                                Circle()
                                                    .fill(AppColors.primary100)
                                                    .frame(width: 50, height: 50)
                                                    .overlay(
                                                        Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                                            .foregroundColor(AppColors.primary500)
                                                    )
                                            }
                                            
                                            Text(pet.name)
                                                .font(.system(size: 11))
                                                .foregroundColor(selectedPet?.id == pet.id ? AppColors.primary700 : AppColors.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Mood selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mood")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 10) {
                            ForEach(DiaryEntry.PetMood.allCases, id: \.self) { mood in
                                Button(action: { selectedMood = mood }) {
                                    VStack(spacing: 4) {
                                        Text(mood.emoji)
                                            .font(.system(size: 28))
                                        Text(mood.rawValue.capitalized)
                                            .font(.system(size: 10))
                                            .foregroundColor(selectedMood == mood ? AppColors.primary700 : AppColors.textSecondary)
                                    }
                                    .frame(width: 70, height: 60)
                                    .background(selectedMood == mood ? AppColors.primary100 : AppColors.neutral50)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Title
                    TextField("Title", text: $title)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(12)
                        .background(AppColors.neutral50)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                    
                    // Content
                    TextEditor(text: $content)
                        .font(.system(size: 15))
                        .padding(12)
                        .frame(minHeight: 150)
                        .background(AppColors.neutral50)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 16)
            }
            .navigationTitle("New Diary Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        diaryManager.createEntry(
                            petId: selectedPet?.id ?? "",
                            petName: selectedPet?.name ?? "Pet",
                            authorId: UUID().uuidString,
                            authorName: "You",
                            title: title,
                            content: content,
                            mood: selectedMood
                        )
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(title.isEmpty || content.isEmpty ? AppColors.textTertiary : AppColors.primary700)
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Pet Chat View (for matched pets)
struct PetChatView: View {
    let pet: Pet
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var messages: [PetChatMessage] = []
    @State private var showSentConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat header with pet info
                VStack(spacing: 12) {
                    if let uiImage = UIImage(named: pet.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppColors.primary300, lineWidth: 3))
                    }
                    
                    VStack(spacing: 4) {
                        Text(pet.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(pet.breed)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.success)
                            Text("Matched!")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.success)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(AppColors.primary50)
                
                // Messages area
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Welcome message
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hi! 👋 I'm \(pet.name)'s owner.")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Thanks for matching with \(pet.name)! Feel free to say hi or ask about scheduling a playdate.")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .padding(12)
                            .background(AppColors.neutral100)
                            .cornerRadius(16)
                            .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                            
                            Spacer(minLength: 60)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // User messages
                        ForEach(messages) { message in
                            HStack {
                                Spacer(minLength: 60)
                                
                                Text(message.text)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(AppColors.primary600)
                                    .cornerRadius(16)
                                    .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                
                // Sent confirmation
                if showSentConfirmation {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                        Text("Message request sent!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.success)
                    }
                    .padding(.vertical, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Say hi to \(pet.name)...", text: $messageText)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.neutral100)
                        .cornerRadius(24)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: messageText.isEmpty ? [AppColors.neutral300, AppColors.neutral300] : [AppColors.primary500, AppColors.primary700],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = PetChatMessage(text: messageText, isFromUser: true)
        messages.append(newMessage)
        messageText = ""
        
        HapticManager.notification(.success)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSentConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSentConfirmation = false
            }
        }
    }
}

struct PetChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
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
    }
}
