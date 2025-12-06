//
//  CommunityView.swift
//  CocoPetParadise
//
//  Community forum for pet owners to share experiences
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var selectedCategory: CommunityPost.PostCategory? = nil
    @State private var showNewPost = false
    @State private var searchText = ""
    
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
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.textTertiary)
                        
                        TextField("Search community...", text: $searchText)
                            .font(AppFonts.bodyMedium)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryFilterChip(
                                title: "All",
                                icon: "square.grid.2x2.fill",
                                isSelected: selectedCategory == nil,
                                color: AppColors.primary700
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(CommunityPost.PostCategory.allCases, id: \.self) { category in
                                CategoryFilterChip(
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
                        .padding(.vertical, 12)
                    }
                    
                    // Pinned posts
                    if selectedCategory == nil && !communityManager.pinnedPosts.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "pin.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.warning)
                                Text("Pinned")
                                    .font(AppFonts.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.horizontal)
                            
                            ForEach(communityManager.pinnedPosts) { post in
                                CommunityPostCard(post: post, isPinned: true)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Posts list
                    if filteredPosts.isEmpty {
                        EmptyCommunityView(showNewPost: $showNewPost)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredPosts.filter { !$0.isPinned }) { post in
                                    CommunityPostCard(post: post)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewPost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primary700)
                    }
                }
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView()
            }
        }
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

// MARK: - Community Post Card
struct CommunityPostCard: View {
    let post: CommunityPost
    var isPinned: Bool = false
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var showComments = false
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                // Author avatar
                ZStack {
                    Circle()
                        .fill(AppColors.primary200)
                        .frame(width: 44, height: 44)
                    
                    Text(String(post.authorName.prefix(1)))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.primary700)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.authorName)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.warning)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: post.category.icon)
                                .font(.system(size: 10))
                            Text(post.category.rawValue)
                                .font(AppFonts.captionSmall)
                        }
                        .foregroundColor(post.category.color)
                        
                        Text("•")
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(timeAgo(from: post.createdAt))
                            .font(AppFonts.captionSmall)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                Spacer()
            }
            
            // Content
            Text(post.content)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(4)
            
            // Actions
            HStack(spacing: 20) {
                // Like button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isLiked.toggle()
                        communityManager.toggleLike(postId: post.id, userId: appState.currentUser?.id ?? "guest")
                        if isLiked {
                            gamificationManager.addPoints(2, reason: "Liked a post")
                        }
                    }
                    HapticManager.impact(.light)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(isLiked ? AppColors.error : AppColors.textTertiary)
                            .scaleEffect(isLiked ? 1.2 : 1)
                        
                        Text("\(post.likes)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Comment button
                Button(action: { showComments = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("\(post.comments.count)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Share button
                Button(action: sharePost) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Spacer()
            }
            .padding(.top, 4)
            
            // Preview comments
            if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    ForEach(post.comments.prefix(2)) { comment in
                        HStack(alignment: .top, spacing: 8) {
                            Text(comment.authorName)
                                .font(AppFonts.bodySmall)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(comment.content)
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    
                    if post.comments.count > 2 {
                        Button(action: { showComments = true }) {
                            Text("View all \(post.comments.count) comments")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.primary700)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
        .onAppear {
            isLiked = post.likedBy.contains(appState.currentUser?.id ?? "")
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Original post
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary200)
                                .frame(width: 40, height: 40)
                            
                            Text(String(post.authorName.prefix(1)))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.primary700)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.authorName)
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(post.category.rawValue)
                                .font(AppFonts.caption)
                                .foregroundColor(post.category.color)
                        }
                    }
                    
                    Text(post.content)
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding()
                .background(AppColors.primary50)
                
                Divider()
                
                // Comments list
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(post.comments) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                    .padding()
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
        
        communityManager.addComment(
            postId: post.id,
            authorId: appState.currentUser?.id ?? "guest",
            authorName: appState.currentUser?.name ?? "Guest",
            content: newComment
        )
        newComment = ""
        HapticManager.notification(.success)
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: PostComment
    
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
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h"
        } else {
            return "\(Int(interval / 86400))d"
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Category selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(CommunityPost.PostCategory.allCases, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 14))
                                        Text(category.rawValue)
                                            .font(AppFonts.bodySmall)
                                    }
                                    .foregroundColor(selectedCategory == category ? .white : category.color)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == category ? category.color : category.color.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Content input
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's on your mind?")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextEditor(text: $content)
                        .font(AppFonts.bodyMedium)
                        .frame(minHeight: 150)
                        .padding(12)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Character count
                HStack {
                    Spacer()
                    Text("\(content.count)/500")
                        .font(AppFonts.caption)
                        .foregroundColor(content.count > 500 ? AppColors.error : AppColors.textTertiary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Post button
                Button(action: submitPost) {
                    HStack {
                        if isPosting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Post")
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: content.isEmpty || content.count > 500))
                .disabled(content.isEmpty || content.count > 500 || isPosting)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    func submitPost() {
        guard !content.isEmpty && content.count <= 500 else { return }
        
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

// MARK: - Empty Community View
struct EmptyCommunityView: View {
    @Binding var showNewPost: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.neutral300)
            
            Text("No posts yet")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Be the first to share your experience!")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
            
            Button(action: { showNewPost = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Post")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
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
