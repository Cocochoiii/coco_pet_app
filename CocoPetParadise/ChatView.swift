//
//  ChatView.swift
//  CocoPetParadise
//
//  In-App Messaging/Chat Feature
//  Beautiful chat interface matching the cream-pink aesthetic
//

import SwiftUI

// MARK: - Chat Models

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let content: String
    let senderType: SenderType
    let timestamp: Date
    var isRead: Bool
    let mediaURL: String?
    let messageType: MessageType
    
    enum SenderType: String, Codable {
        case user = "user"
        case admin = "admin"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .user: return "You"
            case .admin: return "Coco's Team"
            case .system: return "System"
            }
        }
    }
    
    enum MessageType: String, Codable {
        case text = "text"
        case image = "image"
        case quickReply = "quick_reply"
        case booking = "booking"
        case petUpdate = "pet_update"
    }
    
    init(id: String = UUID().uuidString,
         content: String,
         senderType: SenderType,
         timestamp: Date = Date(),
         isRead: Bool = false,
         mediaURL: String? = nil,
         messageType: MessageType = .text) {
        self.id = id
        self.content = content
        self.senderType = senderType
        self.timestamp = timestamp
        self.isRead = isRead
        self.mediaURL = mediaURL
        self.messageType = messageType
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

struct Conversation: Identifiable, Codable {
    let id: String
    let participantName: String
    let participantImage: String?
    var messages: [ChatMessage]
    var lastMessageTimestamp: Date
    var unreadCount: Int
    let bookingId: String?
    
    init(id: String = UUID().uuidString,
         participantName: String = "Coco's Team",
         participantImage: String? = nil,
         messages: [ChatMessage] = [],
         lastMessageTimestamp: Date = Date(),
         unreadCount: Int = 0,
         bookingId: String? = nil) {
        self.id = id
        self.participantName = participantName
        self.participantImage = participantImage
        self.messages = messages
        self.lastMessageTimestamp = lastMessageTimestamp
        self.unreadCount = unreadCount
        self.bookingId = bookingId
    }
}

// MARK: - Chat Manager

class ChatManager: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var isTyping: Bool = false
    @Published var unreadCount: Int = 0
    
    private let conversationsKey = "chatConversations"
    
    init() {
        loadConversations()
        
        // Create default conversation if none exists
        if conversations.isEmpty {
            createDefaultConversation()
        }
    }
    
    func loadConversations() {
        if let data = UserDefaults.standard.data(forKey: conversationsKey),
           let saved = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = saved
            updateUnreadCount()
        }
    }
    
    func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: conversationsKey)
        }
    }
    
    func createDefaultConversation() {
        let welcomeMessages = [
            ChatMessage(
                content: "Welcome to Coco's Pet Paradise! 🐾",
                senderType: .admin,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            ChatMessage(
                content: "Hi there! I'm here to help with any questions about our pet boarding services. How can I assist you today?",
                senderType: .admin,
                timestamp: Date().addingTimeInterval(-3590)
            )
        ]
        
        let conversation = Conversation(
            participantName: "Coco's Team",
            participantImage: "app-logo",
            messages: welcomeMessages,
            lastMessageTimestamp: Date().addingTimeInterval(-3590),
            unreadCount: 2
        )
        
        conversations.append(conversation)
        currentConversation = conversation
        saveConversations()
        updateUnreadCount()
    }
    
    func sendMessage(_ content: String, in conversationId: String? = nil) {
        let targetId = conversationId ?? currentConversation?.id ?? conversations.first?.id
        
        guard let id = targetId,
              let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        
        let message = ChatMessage(
            content: content,
            senderType: .user,
            isRead: true
        )
        
        conversations[index].messages.append(message)
        conversations[index].lastMessageTimestamp = Date()
        currentConversation = conversations[index]
        
        saveConversations()
        
        // Simulate admin typing and response
        simulateAdminResponse(for: content, in: id)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func simulateAdminResponse(for userMessage: String, in conversationId: String) {
        // Show typing indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isTyping = true
        }
        
        // Generate contextual response
        let response = generateResponse(for: userMessage)
        
        // Send response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.5...2.5)) {
            self.isTyping = false
            
            guard let index = self.conversations.firstIndex(where: { $0.id == conversationId }) else { return }
            
            let responseMessage = ChatMessage(
                content: response,
                senderType: .admin,
                isRead: false
            )
            
            self.conversations[index].messages.append(responseMessage)
            self.conversations[index].lastMessageTimestamp = Date()
            self.conversations[index].unreadCount += 1
            self.currentConversation = self.conversations[index]
            
            self.saveConversations()
            self.updateUnreadCount()
            
            // Notification sound/haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private func generateResponse(for message: String) -> String {
        let lowercased = message.lowercased()
        
        if lowercased.contains("price") || lowercased.contains("cost") || lowercased.contains("rate") {
            return "Our boarding rates are:\n\n🐱 Cats: $25/night\n🐕 Small Dogs: $40/night\n🐕 Large Dogs: $60/night\n\nAll stays include daily updates with photos! Would you like to book a stay?"
        } else if lowercased.contains("book") || lowercased.contains("reservation") || lowercased.contains("schedule") {
            return "I'd be happy to help you book a stay! You can use our booking calendar in the app, or I can help you find available dates. What dates are you looking at?"
        } else if lowercased.contains("location") || lowercased.contains("where") || lowercased.contains("address") {
            return "We're located in beautiful Wellesley Hills, MA! 📍 We offer free pickup within 10 miles. Would you like directions?"
        } else if lowercased.contains("photo") || lowercased.contains("update") || lowercased.contains("picture") {
            return "We send daily photo and video updates of your pet during their stay! 📸 You'll receive them right here in the app and via email."
        } else if lowercased.contains("hello") || lowercased.contains("hi") || lowercased.contains("hey") {
            return "Hello! 👋 So nice to hear from you! How can I help you with your pet boarding needs today?"
        } else if lowercased.contains("thank") {
            return "You're welcome! 🐾 Is there anything else I can help you with?"
        } else if lowercased.contains("available") || lowercased.contains("availability") {
            return "Let me check our availability for you! Currently we have openings in the coming weeks. You can see real-time availability in our booking calendar. Any specific dates in mind?"
        } else if lowercased.contains("food") || lowercased.contains("diet") || lowercased.contains("feed") {
            return "We're happy to accommodate any dietary needs! Just let us know your pet's food preferences and any special requirements when booking. You can also bring their own food if preferred. 🍽️"
        } else if lowercased.contains("medication") || lowercased.contains("medicine") {
            return "Yes, we can administer medications! Please provide detailed instructions when booking, and our team will ensure your pet stays healthy and happy. 💊"
        } else if lowercased.contains("cat") || lowercased.contains("cats") {
            return "We love cats! 🐱 Our cat boarding includes cozy private spaces, climbing structures, and plenty of playtime. Bibi and Dudu, our resident cats, help new guests feel at home!"
        } else if lowercased.contains("dog") || lowercased.contains("dogs") {
            return "Dogs are welcome! 🐕 We have spacious play areas, regular walks, and lots of socialization opportunities. Each pup gets personalized attention and care."
        } else {
            let responses = [
                "Thanks for your message! I'll look into this and get back to you shortly. Is there anything specific you'd like to know about our services?",
                "Great question! Our team at Coco's Pet Paradise is dedicated to providing the best care. Can you tell me more about what you're looking for?",
                "I appreciate you reaching out! Let me help you with that. Would you like to know more about our boarding services or schedule a visit?",
                "Thanks for getting in touch! 🐾 We'd love to help. Feel free to ask about pricing, availability, or our services!"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
    
    func markAsRead(conversationId: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        
        for i in 0..<conversations[index].messages.count {
            conversations[index].messages[i].isRead = true
        }
        conversations[index].unreadCount = 0
        currentConversation = conversations[index]
        
        saveConversations()
        updateUnreadCount()
    }
    
    func updateUnreadCount() {
        unreadCount = conversations.reduce(0) { $0 + $1.unreadCount }
    }
    
    func getOrCreateConversation() -> Conversation {
        if let existing = currentConversation ?? conversations.first {
            return existing
        }
        createDefaultConversation()
        return conversations.first!
    }
    
    func clearChat() {
        guard let currentId = currentConversation?.id,
              let index = conversations.firstIndex(where: { $0.id == currentId }) else { return }
        
        conversations[index].messages = []
        currentConversation = conversations[index]
        saveConversations()
        
        // Re-add welcome message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let welcomeMessage = ChatMessage(
                content: "Chat cleared! How can I help you today? 🐾",
                senderType: .admin
            )
            self.conversations[index].messages.append(welcomeMessage)
            self.currentConversation = self.conversations[index]
            self.saveConversations()
        }
    }
}

// MARK: - Main Chat View

struct ChatView: View {
    @EnvironmentObject var chatManager: ChatManager
    @Environment(\.dismiss) var dismiss
    @State private var messageText: String = ""
    @State private var showQuickReplies: Bool = true
    @State private var showOptions: Bool = false
    @FocusState private var isInputFocused: Bool
    
    let quickReplies = [
        "What are your rates?",
        "Check availability",
        "How do I book?",
        "Where are you located?"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.backgroundSecondary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Date header
                                ChatDateHeader(date: Date())
                                
                                // Messages
                                ForEach(chatManager.currentConversation?.messages ?? []) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                }
                                
                                // Typing indicator
                                if chatManager.isTyping {
                                    TypingIndicator()
                                        .id("typing")
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .onChange(of: chatManager.currentConversation?.messages.count) { oldValue, newValue in
                            scrollToBottom(proxy: proxy)
                        }
                        .onChange(of: chatManager.isTyping) { oldValue, newValue in
                            scrollToBottom(proxy: proxy)
                        }
                        .onAppear {
                            scrollToBottom(proxy: proxy, animated: false)
                        }
                    }
                    
                    // Quick replies
                    if showQuickReplies && messageText.isEmpty {
                        QuickRepliesView(replies: quickReplies) { reply in
                            sendMessage(reply)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Input bar
                    ChatInputBar(
                        text: $messageText,
                        isFocused: $isInputFocused,
                        onSend: {
                            sendMessage(messageText)
                        }
                    )
                }
            }
            .navigationTitle("Chat with Us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(8)
                            .background(AppColors.neutral100)
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    ChatHeader()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            if let url = URL(string: "tel:+16175551234") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Label("Call Us", systemImage: "phone.fill")
                        }
                        
                        Button(action: {
                            chatManager.clearChat()
                        }) {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(8)
                            .background(AppColors.neutral100)
                            .clipShape(Circle())
                    }
                }
            }
            .onAppear {
                let conversation = chatManager.getOrCreateConversation()
                chatManager.markAsRead(conversationId: conversation.id)
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            chatManager.sendMessage(text)
            messageText = ""
            showQuickReplies = false
        }
        
        // Re-show quick replies after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showQuickReplies = true
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let lastId = chatManager.isTyping ? "typing" : chatManager.currentConversation?.messages.last?.id
            if let id = lastId {
                if animated {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                } else {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Chat Header

struct ChatHeader: View {
    @State private var isOnline = true
    
    var body: some View {
        HStack(spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 36, height: 36)
                
                LogoImage(name: "app-logo", size: 28)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Coco's Team")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(isOnline ? AppColors.success : AppColors.neutral400)
                        .frame(width: 6, height: 6)
                    
                    Text(isOnline ? "Online" : "Away")
                        .font(.system(size: 11))
                        .foregroundColor(isOnline ? AppColors.success : AppColors.textTertiary)
                }
            }
        }
    }
}

// MARK: - Chat Date Header

struct ChatDateHeader: View {
    let date: Date
    
    var body: some View {
        Text(formatDate(date))
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(AppColors.textTertiary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.neutral100)
            .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage
    @State private var showTimestamp = false
    
    private var isFromUser: Bool {
        message.senderType == .user
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isFromUser {
                Spacer(minLength: 60)
            } else {
                // Admin avatar
                ZStack {
                    Circle()
                        .fill(AppColors.primary100)
                        .frame(width: 32, height: 32)
                    
                    LogoImage(name: "app-logo", size: 24)
                }
            }
            
            VStack(alignment: isFromUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(isFromUser ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isFromUser
                        ? AppColors.primary700
                        : Color.white
                    )
                    .cornerRadius(18)
                    .cornerRadius(isFromUser ? 4 : 18, corners: isFromUser ? .bottomRight : .bottomLeft)
                    .shadow(color: AppColors.primary.opacity(0.1), radius: 4, x: 0, y: 2)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showTimestamp.toggle()
                        }
                    }
                
                // Timestamp (shown on tap or always for recent messages)
                if showTimestamp || isRecentMessage {
                    HStack(spacing: 4) {
                        Text(formatTime(message.timestamp))
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textTertiary)
                        
                        if isFromUser {
                            Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.system(size: 10))
                                .foregroundColor(message.isRead ? AppColors.success : AppColors.textTertiary)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            
            if !isFromUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private var isRecentMessage: Bool {
        Date().timeIntervalSince(message.timestamp) < 60 // Show for messages less than 1 minute old
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Admin avatar
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 32, height: 32)
                
                LogoImage(name: "app-logo", size: 24)
            }
            
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(AppColors.textTertiary)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(18)
            .cornerRadius(4, corners: .bottomLeft)
            .shadow(color: AppColors.primary.opacity(0.1), radius: 4, x: 0, y: 2)
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animationOffset = -5
        }
    }
}

// MARK: - Quick Replies View

struct QuickRepliesView: View {
    let replies: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(replies, id: \.self) { reply in
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onSelect(reply)
                    }) {
                        Text(reply)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.primary700)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppColors.primary50)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(AppColors.primary200, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(AppColors.backgroundSecondary)
    }
}

// MARK: - Chat Input Bar

struct ChatInputBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppColors.border)
            
            HStack(alignment: .bottom, spacing: 12) {
                // Attachment button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primary400)
                }
                
                // Text input
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Type a message...", text: $text, axis: .vertical)
                        .font(.system(size: 15))
                        .lineLimit(1...5)
                        .focused(isFocused)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    
                    // Emoji button
                    Button(action: {}) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.trailing, 8)
                    .padding(.bottom, 10)
                }
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.border, lineWidth: 1)
                )
                
                // Send button
                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  ? AppColors.neutral300
                                  : AppColors.primary700)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .scaleEffect(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1 : 1.05)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: text.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppColors.backgroundSecondary)
        }
    }
}

// MARK: - Floating Chat Button

struct FloatingChatButton: View {
    @Binding var showChat: Bool
    @EnvironmentObject var chatManager: ChatManager
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showChat = true
                }) {
                    ZStack {
                        // Pulse effect for unread messages
                        if chatManager.unreadCount > 0 {
                            Circle()
                                .fill(AppColors.primary300.opacity(0.4))
                                .frame(width: 52, height: 52)
                                .scaleEffect(pulseScale)
                        }
                        
                        // Main button - smaller size
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary600, AppColors.primary700],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .shadow(color: AppColors.primary700.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // Icon - smaller
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .offset(y: isAnimating ? -1 : 1)
                        
                        // Unread badge - smaller
                        if chatManager.unreadCount > 0 {
                            ZStack {
                                Circle()
                                    .fill(AppColors.error)
                                    .frame(width: 18, height: 18)
                                
                                Text("\(min(chatManager.unreadCount, 9))\(chatManager.unreadCount > 9 ? "+" : "")")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 15, y: -15)
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 90)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            if chatManager.unreadCount > 0 {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                }
            }
        }
    }
}

// MARK: - Preview

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(ChatManager())
    }
}
