//
//  CommunityView.swift
//  CocoPetParadise
//
//  Community forum for pet owners to share experiences - Enhanced UI/UX
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var selectedCategory: CommunityPost.PostCategory? = nil
    @State private var showNewPost = false
    @State private var searchText = ""
    @State private var animateContent = false
    @FocusState private var isSearchFocused: Bool
    
    var filteredPosts: [CommunityPost] {
        var posts = communityManager.postsForCategory(selectedCategory)
        
        if !searchText.isEmpty {
            posts = posts.filter {
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.authorName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return posts.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundSecondary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    CommunitySearchBar(
                        text: $searchText,
                        isFocused: $isSearchFocused
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 10)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryFilterChip(
                                title: "All",
                                icon: "square.grid.2x2.fill",
                                isSelected: selectedCategory == nil,
                                color: AppColors.primary700
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCategory = nil
                                }
                                HapticManager.impact(.light)
                            }
                            
                            ForEach(CommunityPost.PostCategory.allCases, id: \.self) { category in
                                CategoryFilterChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                    }
                                    HapticManager.impact(.light)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 10)
                    
                    // Posts content
                    if filteredPosts.isEmpty && communityManager.pinnedPosts.isEmpty {
                        EmptyCommunityView(showNewPost: $showNewPost)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 14) {
                                // Pinned posts section
                                if selectedCategory == nil && !communityManager.pinnedPosts.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "pin.fill")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppColors.warning)
                                            Text("Pinned")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                        .padding(.horizontal, 4)
                                        
                                        ForEach(Array(communityManager.pinnedPosts.enumerated()), id: \.element.id) { index, post in
                                            CommunityPostCard(post: post, isPinned: true)
                                                .opacity(animateContent ? 1 : 0)
                                                .offset(y: animateContent ? 0 : 15)
                                                .animation(
                                                    .spring(response: 0.4, dampingFraction: 0.75)
                                                    .delay(Double(index) * 0.05),
                                                    value: animateContent
                                                )
                                        }
                                    }
                                    .padding(.bottom, 8)
                                }
                                
                                // Regular posts
                                ForEach(Array(filteredPosts.filter { !$0.isPinned }.enumerated()), id: \.element.id) { index, post in
                                    CommunityPostCard(post: post)
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(y: animateContent ? 0 : 15)
                                        .animation(
                                            .spring(response: 0.4, dampingFraction: 0.75)
                                            .delay(Double(index) * 0.04 + 0.1),
                                            value: animateContent
                                        )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewPost = true
                        HapticManager.impact(.medium)
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary600, AppColors.primary700],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 34, height: 34)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: AppColors.primary700.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(CommunityScaleButtonStyle())
                }
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                    animateContent = true
                }
            }
        }
    }
}

// MARK: - Button Styles
struct CommunityScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct CommunityCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Community Search Bar
struct CommunitySearchBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isFocused.wrappedValue ? AppColors.primary600 : AppColors.textTertiary)
            
            TextField("Search community...", text: $text)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textPrimary)
                .focused(isFocused)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.neutral400)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused.wrappedValue ? AppColors.primary400 : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
    }
}

// MARK: - Category Filter Chip
struct CategoryFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [color, color.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        color.opacity(0.1)
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : color.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? color.opacity(0.25) : Color.clear,
                radius: 6,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(CommunityScaleButtonStyle())
    }
}

// MARK: - Community Post Card
struct CommunityPostCard: View {
    let post: CommunityPost
    var isPinned: Bool = false
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var showComments = false
    @State private var isLiked = false
    @State private var showHeartAnimation = false
    @State private var likeCount: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 12) {
                // Author avatar with gradient border
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [post.category.color.opacity(0.3), post.category.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                    
                    Text(String(post.authorName.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(post.category.color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(post.authorName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        if isPinned {
                            HStack(spacing: 3) {
                                Image(systemName: "pin.fill")
                                    .font(.system(size: 8))
                                Text("Pinned")
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .foregroundColor(AppColors.warning)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.warning.opacity(0.12))
                            .cornerRadius(8)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: post.category.icon)
                                .font(.system(size: 9))
                            Text(post.category.rawValue)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(post.category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(post.category.color.opacity(0.1))
                        .cornerRadius(6)
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.neutral300)
                        
                        Text(timeAgo(from: post.createdAt))
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                Spacer()
                
                // More options
                Button(action: {
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(width: 32, height: 32)
                        .background(AppColors.neutral50)
                        .clipShape(Circle())
                }
                .buttonStyle(CommunityScaleButtonStyle())
            }
            
            // Content
            Text(post.content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(4)
                .lineLimit(5)
            
            // Actions bar
            HStack(spacing: 0) {
                // Like button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                        likeCount += isLiked ? 1 : -1
                        if isLiked {
                            showHeartAnimation = true
                            gamificationManager.addPoints(2, reason: "Liked a post")
                        }
                    }
                    communityManager.toggleLike(postId: post.id, userId: appState.currentUser?.id ?? "guest")
                    HapticManager.impact(.light)
                    
                    if isLiked {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showHeartAnimation = false
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        ZStack {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(isLiked ? AppColors.error : AppColors.textTertiary)
                                .scaleEffect(showHeartAnimation ? 1.3 : 1)
                            
                            if showHeartAnimation {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.error)
                                    .scaleEffect(2)
                                    .opacity(0)
                                    .animation(.easeOut(duration: 0.5), value: showHeartAnimation)
                            }
                        }
                        
                        Text("\(likeCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isLiked ? AppColors.error : AppColors.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isLiked ? AppColors.error.opacity(0.08) : Color.clear)
                    )
                }
                .buttonStyle(CommunityScaleButtonStyle())
                
                Spacer()
                
                // Comment button
                Button(action: {
                    showComments = true
                    HapticManager.impact(.light)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("\(post.comments.count)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(CommunityScaleButtonStyle())
                
                Spacer()
                
                // Share button
                Button(action: {
                    sharePost()
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(CommunityScaleButtonStyle())
                
                Spacer()
                
                // Bookmark button
                Button(action: {
                    HapticManager.impact(.light)
                }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(CommunityScaleButtonStyle())
            }
            .padding(.top, 2)
            
            // Preview comments
            if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Rectangle()
                        .fill(AppColors.neutral100)
                        .frame(height: 1)
                    
                    ForEach(post.comments.prefix(2)) { comment in
                        HStack(alignment: .top, spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.neutral100)
                                    .frame(width: 24, height: 24)
                                Text(String(comment.authorName.prefix(1)).uppercased())
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(comment.authorName)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text(timeAgo(from: comment.createdAt))
                                        .font(.system(size: 10))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                
                                Text(comment.content)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    
                    if post.comments.count > 2 {
                        Button(action: {
                            showComments = true
                            HapticManager.impact(.light)
                        }) {
                            Text("View all \(post.comments.count) comments")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColors.primary600)
                        }
                        .buttonStyle(CommunityScaleButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .onAppear {
            isLiked = post.likedBy.contains(appState.currentUser?.id ?? "")
            likeCount = post.likes
        }
        .sheet(isPresented: $showComments) {
            PostCommentsView(post: post)
        }
    }
    
    func sharePost() {
        let text = "Check out this post from Coco's Pet Paradise community: \"\(post.content.prefix(100))...\""
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
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Post Comments View
struct PostCommentsView: View {
    let post: CommunityPost
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var newComment = ""
    @State private var animateContent = false
    @FocusState private var isCommentFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Original post
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [post.category.color.opacity(0.3), post.category.color.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 42, height: 42)
                            
                            Text(String(post.authorName.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(post.category.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(post.authorName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: post.category.icon)
                                    .font(.system(size: 10))
                                Text(post.category.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(post.category.color)
                        }
                        
                        Spacer()
                    }
                    
                    Text(post.content)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textPrimary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [post.category.color.opacity(0.08), post.category.color.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                Rectangle()
                    .fill(AppColors.neutral100)
                    .frame(height: 1)
                
                // Comments header
                HStack {
                    Text("\(post.comments.count) Comments")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {}) {
                            Label("Most Recent", systemImage: "clock")
                        }
                        Button(action: {}) {
                            Label("Most Liked", systemImage: "heart")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Sort")
                                .font(.system(size: 12, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.neutral50)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Comments list
                if post.comments.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(AppColors.neutral100)
                                .frame(width: 70, height: 70)
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 28))
                                .foregroundColor(AppColors.neutral400)
                        }
                        
                        VStack(spacing: 6) {
                            Text("No comments yet")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Be the first to share your thoughts!")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(post.comments.enumerated()), id: \.element.id) { index, comment in
                                CommentRow(comment: comment)
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(y: animateContent ? 0 : 10)
                                    .animation(
                                        .easeOut(duration: 0.3).delay(Double(index) * 0.05),
                                        value: animateContent
                                    )
                                
                                if index < post.comments.count - 1 {
                                    Rectangle()
                                        .fill(AppColors.neutral100)
                                        .frame(height: 1)
                                        .padding(.leading, 52)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                // Comment input
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppColors.neutral100)
                        .frame(height: 1)
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary100)
                                .frame(width: 36, height: 36)
                            Text(String((appState.currentUser?.name ?? "G").prefix(1)).uppercased())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.primary700)
                        }
                        
                        HStack(spacing: 8) {
                            TextField("Add a comment...", text: $newComment)
                                .font(.system(size: 14))
                                .focused($isCommentFocused)
                            
                            if !newComment.isEmpty {
                                Button(action: submitComment) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(AppColors.primary600)
                                }
                                .buttonStyle(CommunityScaleButtonStyle())
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppColors.neutral50)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.neutral400)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                    animateContent = true
                }
            }
        }
    }
    
    func submitComment() {
        guard !newComment.isEmpty else { return }
        
        communityManager.addComment(
            postId: post.id,
            authorId: appState.currentUser?.id ?? "guest",
            authorName: appState.currentUser?.name ?? "Guest",
            content: newComment
        )
        newComment = ""
        isCommentFocused = false
        HapticManager.notification(.success)
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: PostComment
    @State private var isLiked = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.neutral100)
                    .frame(width: 36, height: 36)
                
                Text(String(comment.authorName.prefix(1)).uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(comment.authorName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(timeAgo(from: comment.createdAt))
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isLiked.toggle()
                        }
                        HapticManager.impact(.light)
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(isLiked ? AppColors.error : AppColors.neutral400)
                            .scaleEffect(isLiked ? 1.2 : 1)
                    }
                    .buttonStyle(CommunityScaleButtonStyle())
                }
                
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textPrimary)
                    .lineSpacing(3)
                
                // Reply button
                Button(action: {
                    HapticManager.impact(.light)
                }) {
                    Text("Reply")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                }
                .buttonStyle(CommunityScaleButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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

// MARK: - New Post View
struct NewPostView: View {
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gamificationManager: GamificationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var content = ""
    @State private var selectedCategory: CommunityPost.PostCategory = .experience
    @State private var isPosting = false
    @State private var animateContent = false
    @FocusState private var isContentFocused: Bool
    
    var characterCount: Int { content.count }
    var isValid: Bool { !content.isEmpty && characterCount <= 500 }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Author preview
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.primary200, AppColors.primary100],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                
                                Text(String((appState.currentUser?.name ?? "G").prefix(1)).uppercased())
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.primary700)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(appState.currentUser?.name ?? "Guest User")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Posting to Community")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 10)
                        
                        // Category selector
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.primary600)
                                Text("Category")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(CommunityPost.PostCategory.allCases, id: \.self) { category in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                                selectedCategory = category
                                            }
                                            HapticManager.impact(.light)
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: category.icon)
                                                    .font(.system(size: 12))
                                                Text(category.rawValue)
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .foregroundColor(selectedCategory == category ? .white : category.color)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                Group {
                                                    if selectedCategory == category {
                                                        LinearGradient(
                                                            colors: [category.color, category.color.opacity(0.8)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    } else {
                                                        category.color.opacity(0.1)
                                                    }
                                                }
                                            )
                                            .cornerRadius(20)
                                            .shadow(
                                                color: selectedCategory == category ? category.color.opacity(0.3) : Color.clear,
                                                radius: 6,
                                                x: 0,
                                                y: 3
                                            )
                                        }
                                        .buttonStyle(CommunityScaleButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 10)
                        .animation(.easeOut(duration: 0.35).delay(0.05), value: animateContent)
                        
                        // Content input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.primary600)
                                Text("What's on your mind?")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("Share your experience, ask a question, or give advice...")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textTertiary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                }
                                
                                TextEditor(text: $content)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(minHeight: 140)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .focused($isContentFocused)
                                    .scrollContentBackground(.hidden)
                            }
                            .background(AppColors.neutral50)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isContentFocused ? AppColors.primary400 : AppColors.neutral200,
                                        lineWidth: isContentFocused ? 1.5 : 1
                                    )
                            )
                            
                            // Character count
                            HStack {
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    if characterCount > 450 {
                                        Image(systemName: characterCount > 500 ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
                                            .font(.system(size: 11))
                                    }
                                    Text("\(characterCount)/500")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(
                                    characterCount > 500 ? AppColors.error :
                                    characterCount > 450 ? AppColors.warning :
                                    AppColors.textTertiary
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    characterCount > 450 ?
                                    (characterCount > 500 ? AppColors.error : AppColors.warning).opacity(0.1) :
                                    AppColors.neutral100
                                )
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 10)
                        .animation(.easeOut(duration: 0.35).delay(0.1), value: animateContent)
                        
                        // Community guidelines
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.info)
                            
                            Text("Be respectful and kind. Share helpful information that benefits our pet community.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(2)
                        }
                        .padding(14)
                        .background(AppColors.info.opacity(0.08))
                        .cornerRadius(12)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 10)
                        .animation(.easeOut(duration: 0.35).delay(0.15), value: animateContent)
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
                
                // Post button
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppColors.neutral100)
                        .frame(height: 1)
                    
                    Button(action: submitPost) {
                        HStack(spacing: 8) {
                            if isPosting {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.9)
                            } else {
                                Text("Post")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 14))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            Group {
                                if isValid {
                                    LinearGradient(
                                        colors: [AppColors.primary600, AppColors.primary700],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color(AppColors.neutral400)
                                }
                            }
                        )
                        .cornerRadius(14)
                        .shadow(
                            color: isValid ? AppColors.primary700.opacity(0.3) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .disabled(!isValid || isPosting)
                    .buttonStyle(CommunityScaleButtonStyle())
                    .padding(16)
                }
                .background(Color.white)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isContentFocused = false
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.primary600)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.35)) {
                    animateContent = true
                }
            }
        }
    }
    
    func submitPost() {
        guard isValid else { return }
        
        isPosting = true
        HapticManager.impact(.medium)
        
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

// MARK: - Empty Community View
struct EmptyCommunityView: View {
    @Binding var showNewPost: Bool
    @State private var animatePulse = false
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 110, height: 110)
                
                Circle()
                    .stroke(AppColors.primary200, lineWidth: 2)
                    .frame(width: 130, height: 130)
                    .scaleEffect(animateIcon ? 1.1 : 1)
                    .opacity(animateIcon ? 0 : 0.6)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 45))
                    .foregroundColor(AppColors.primary500)
                    .scaleEffect(animatePulse ? 1.05 : 1)
            }
            
            VStack(spacing: 10) {
                Text("No posts yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Be the first to share your experience\nwith our pet community!")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            
            Button(action: {
                showNewPost = true
                HapticManager.impact(.medium)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Create First Post")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppColors.primary600, AppColors.primary700],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: AppColors.primary700.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(CommunityScaleButtonStyle())
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                animateIcon = true
            }
        }
    }
}

// MARK: - Preview
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .environmentObject(AppState())
            .environmentObject(CommunityManager())
            .environmentObject(GamificationManager())
    }
}
