//
//  DiaryView.swift
//  CocoPetParadise
//
//  Pet diary feature with mood tracking and story sharing
//

import SwiftUI
import PhotosUI

struct DiaryView: View {
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var showNewEntry = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                HStack(spacing: 0) {
                    DiaryTabButton(title: "All Stories", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    DiaryTabButton(title: "My Diary", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    DiaryTabButton(title: "Saved", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content
                TabView(selection: $selectedTab) {
                    AllStoriesView(showNewEntry: $showNewEntry)
                        .tag(0)
                    
                    MyDiaryView(showNewEntry: $showNewEntry)
                        .tag(1)
                    
                    SavedStoriesView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Pet Diary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primary700)
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                NewDiaryEntryView()
            }
        }
    }
}

// MARK: - Diary Tab Button
struct DiaryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(AppFonts.bodySmall)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? AppColors.primary700 : AppColors.textTertiary)
                
                Rectangle()
                    .fill(isSelected ? AppColors.primary700 : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - All Stories View
struct AllStoriesView: View {
    @EnvironmentObject var diaryManager: DiaryManager
    @Binding var showNewEntry: Bool
    
    var body: some View {
        if diaryManager.publicEntries.isEmpty {
            EmptyDiaryView(showNewEntry: $showNewEntry, message: "No stories yet. Be the first to share!")
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(diaryManager.publicEntries) { entry in
                        DiaryEntryCard(entry: entry)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - My Diary View
struct MyDiaryView: View {
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var appState: AppState
    @Binding var showNewEntry: Bool
    
    var myEntries: [DiaryEntry] {
        diaryManager.entries.filter { $0.authorId == (appState.currentUser?.id ?? "") }
    }
    
    var body: some View {
        if myEntries.isEmpty {
            EmptyDiaryView(showNewEntry: $showNewEntry, message: "Start documenting your pet's adventures!")
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(myEntries) { entry in
                        DiaryEntryCard(entry: entry, isOwn: true)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Saved Stories View
struct SavedStoriesView: View {
    @EnvironmentObject var diaryManager: DiaryManager
    
    var body: some View {
        if diaryManager.savedDiaryEntries.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "bookmark")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.neutral300)
                
                Text("No saved stories")
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Tap the bookmark icon on stories you love")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(diaryManager.savedDiaryEntries) { entry in
                        DiaryEntryCard(entry: entry)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Diary Entry Card
struct DiaryEntryCard: View {
    let entry: DiaryEntry
    var isOwn: Bool = false
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var isLiked = false
    @State private var isSaved = false
    @State private var showComments = false
    @State private var showFullEntry = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                // Pet avatar placeholder
                ZStack {
                    Circle()
                        .fill(entry.mood.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: entry.mood.icon)
                        .font(.system(size: 24))
                        .foregroundColor(entry.mood.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(entry.petName)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        // Mood badge
                        HStack(spacing: 4) {
                            Image(systemName: entry.mood.icon)
                                .font(.system(size: 10))
                            Text(entry.mood.rawValue)
                                .font(AppFonts.captionSmall)
                        }
                        .foregroundColor(entry.mood.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(entry.mood.color.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    HStack(spacing: 6) {
                        Text("by \(entry.authorName)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("•")
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(timeAgo(from: entry.createdAt))
                            .font(AppFonts.caption)
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
                        .foregroundColor(isSaved ? AppColors.primary700 : AppColors.textTertiary)
                }
            }
            
            // Title
            Text(entry.title)
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            // Content preview
            Text(entry.content)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(4)
            
            // Read more button
            if entry.content.count > 200 {
                Button(action: { showFullEntry = true }) {
                    Text("Read more...")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.primary700)
                }
            }
            
            // Actions
            HStack(spacing: 24) {
                // Like
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isLiked.toggle()
                        diaryManager.toggleLike(entryId: entry.id, userId: appState.currentUser?.id ?? "guest")
                        if isLiked {
                            gamificationManager.addPoints(2, reason: "Liked a diary entry")
                        }
                    }
                    HapticManager.impact(.light)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? AppColors.error : AppColors.textTertiary)
                            .scaleEffect(isLiked ? 1.2 : 1)
                        Text("\(entry.likes)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Comments
                Button(action: { showComments = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(AppColors.textTertiary)
                        Text("\(entry.comments.count)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Share
                Button(action: shareEntry) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
        .onAppear {
            isLiked = entry.likedBy.contains(appState.currentUser?.id ?? "")
            isSaved = diaryManager.isEntrySaved(entry.id)
        }
        .sheet(isPresented: $showComments) {
            DiaryCommentsView(entry: entry)
        }
        .sheet(isPresented: $showFullEntry) {
            FullDiaryEntryView(entry: entry)
        }
    }
    
    func shareEntry() {
        let text = "📖 \(entry.petName)'s Diary: \"\(entry.title)\"\n\n\(entry.content.prefix(200))...\n\nShared from Coco's Pet Paradise 🐾"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
}

// MARK: - Full Diary Entry View
struct FullDiaryEntryView: View {
    let entry: DiaryEntry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(entry.mood.color.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: entry.mood.icon)
                                .font(.system(size: 28))
                                .foregroundColor(entry.mood.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.petName)
                                .font(AppFonts.title3)
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: entry.mood.icon)
                                        .font(.system(size: 12))
                                    Text(entry.mood.rawValue)
                                        .font(AppFonts.bodySmall)
                                }
                                .foregroundColor(entry.mood.color)
                                
                                Text("•")
                                    .foregroundColor(AppColors.textTertiary)
                                
                                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(AppFonts.bodySmall)
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                    
                    // Title
                    Text(entry.title)
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Divider()
                    
                    // Content
                    Text(entry.content)
                        .font(AppFonts.bodyLarge)
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(6)
                    
                    // Author
                    HStack {
                        Text("Written by")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                        Text(entry.authorName)
                            .font(AppFonts.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primary700)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Diary Entry")
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

// MARK: - Diary Comments View
struct DiaryCommentsView: View {
    let entry: DiaryEntry
    @EnvironmentObject var diaryManager: DiaryManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var newComment = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Entry preview
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(entry.mood.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: entry.mood.icon)
                            .font(.system(size: 18))
                            .foregroundColor(entry.mood.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.title)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Text(entry.petName)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(AppColors.primary50)
                
                Divider()
                
                // Comments list
                if entry.comments.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.neutral300)
                        Text("No comments yet")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Be the first to comment!")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(entry.comments) { comment in
                                DiaryCommentRow(comment: comment)
                            }
                        }
                        .padding()
                    }
                }
                
                // Comment input
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $newComment)
                        .font(AppFonts.bodyMedium)
                        .padding(12)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(20)
                    
                    Button(action: submitComment) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(newComment.isEmpty ? AppColors.neutral300 : AppColors.primary700)
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding()
                .background(Color.white)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primary700)
                }
            }
        }
    }
    
    func submitComment() {
        guard !newComment.isEmpty else { return }
        
        diaryManager.addComment(
            entryId: entry.id,
            authorId: appState.currentUser?.id ?? "guest",
            authorName: appState.currentUser?.name ?? "Guest",
            content: newComment
        )
        newComment = ""
        HapticManager.notification(.success)
    }
}

// MARK: - Diary Comment Row
struct DiaryCommentRow: View {
    let comment: DiaryComment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.neutral200)
                    .frame(width: 36, height: 36)
                
                Text(String(comment.authorName.prefix(1)))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName)
                        .font(AppFonts.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text(timeAgo(from: comment.createdAt))
                        .font(AppFonts.captionSmall)
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Text(comment.content)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 { return "\(Int(interval / 60))m" }
        else if interval < 86400 { return "\(Int(interval / 3600))h" }
        else { return "\(Int(interval / 86400))d" }
    }
}

// MARK: - New Diary Entry View
struct NewDiaryEntryView: View {
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
    
    var availablePets: [Pet] {
        petDataManager.userPets + petDataManager.pets.prefix(5)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Pet selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Pet")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(availablePets) { pet in
                                    PetSelectorButton(pet: pet, isSelected: selectedPet?.id == pet.id) {
                                        selectedPet = pet
                                    }
                                }
                            }
                        }
                    }
                    
                    // Mood selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How is your pet feeling?")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(DiaryEntry.PetMood.allCases, id: \.self) { mood in
                                    MoodSelectorButton(mood: mood, isSelected: selectedMood == mood) {
                                        selectedMood = mood
                                    }
                                }
                            }
                        }
                    }
                    
                    // Title input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextField("Give your entry a title...", text: $title)
                            .font(AppFonts.bodyMedium)
                            .padding(14)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(12)
                    }
                    
                    // Content input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Story")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextEditor(text: $content)
                            .font(AppFonts.bodyMedium)
                            .frame(minHeight: 150)
                            .padding(12)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(12)
                    }
                    
                    // Privacy toggle
                    HStack {
                        Image(systemName: isPublic ? "globe" : "lock.fill")
                            .foregroundColor(AppColors.primary700)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isPublic ? "Public" : "Private")
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(AppColors.textPrimary)
                            Text(isPublic ? "Everyone can see this entry" : "Only you can see this entry")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textTertiary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isPublic)
                            .tint(AppColors.primary700)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: submitEntry) {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("Post")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(canPost ? AppColors.primary700 : AppColors.neutral400)
                    .disabled(!canPost || isPosting)
                }
            }
        }
    }
    
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

// MARK: - Pet Selector Button
struct PetSelectorButton: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primary700 : AppColors.neutral200)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: pet.type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                }
                
                Text(pet.name)
                    .font(AppFonts.captionSmall)
                    .foregroundColor(isSelected ? AppColors.primary700 : AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 70)
        }
    }
}

// MARK: - Mood Selector Button
struct MoodSelectorButton: View {
    let mood: DiaryEntry.PetMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mood.color : mood.color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: mood.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : mood.color)
                }
                
                Text(mood.rawValue)
                    .font(AppFonts.captionSmall)
                    .foregroundColor(isSelected ? mood.color : AppColors.textTertiary)
            }
        }
    }
}

// MARK: - Empty Diary View
struct EmptyDiaryView: View {
    @Binding var showNewEntry: Bool
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.neutral300)
            
            Text("No entries yet")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            Text(message)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showNewEntry = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Write Entry")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryView()
            .environmentObject(DiaryManager())
            .environmentObject(PetDataManager())
            .environmentObject(AppState())
            .environmentObject(GamificationManager())
    }
}
