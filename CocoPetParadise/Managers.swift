//
//  Managers.swift
//  CocoPetParadise
//
//  Data managers for pets, bookings, notifications,
//  gamification, community, diary, and matching
//

import Foundation
import SwiftUI
import UserNotifications

// MARK: - Pet Data Manager
class PetDataManager: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var userPets: [Pet] = []
    @Published var favoritePets: [String] = []
    @Published var isLoading: Bool = false
    
    private let favoritesKey = "favoritePets"
    private let userPetsKey = "userPets"
    
    init() {
        loadPets()
        loadUserPets()
        loadFavorites()
    }
    
    func loadPets() {
        isLoading = true
        pets = SampleData.pets
        isLoading = false
    }
    
    // MARK: - User Pets Management
    func loadUserPets() {
        if let data = UserDefaults.standard.data(forKey: userPetsKey),
           let saved = try? JSONDecoder().decode([Pet].self, from: data) {
            userPets = saved
        }
    }
    
    func saveUserPets() {
        if let encoded = try? JSONEncoder().encode(userPets) {
            UserDefaults.standard.set(encoded, forKey: userPetsKey)
        }
    }
    
    func addUserPet(_ pet: Pet) {
        var newPet = pet
        newPet.isUserPet = true
        userPets.insert(newPet, at: 0)
        saveUserPets()
    }
    
    func updateUserPet(_ pet: Pet) {
        if let index = userPets.firstIndex(where: { $0.id == pet.id }) {
            userPets[index] = pet
            saveUserPets()
        }
    }
    
    func deleteUserPet(id: String) {
        deleteUserPetMedia(petId: id)
        userPets.removeAll { $0.id == id }
        favoritePets.removeAll { $0 == id }
        UserDefaults.standard.set(favoritePets, forKey: favoritesKey)
        saveUserPets()
    }
    
    func isUserPet(_ pet: Pet) -> Bool {
        return pet.isUserPet || userPets.contains { $0.id == pet.id }
    }
    
    // MARK: - User Pet Media Storage
    func saveUserPetImage(_ image: UIImage, petId: String, imageIndex: Int) -> String {
        let fileName = "user_pet_\(petId)_\(imageIndex).jpg"
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return fileName
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: fileURL)
        }
        
        return fileName
    }
    
    func loadUserPetImage(named fileName: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        
        return nil
    }
    
    func saveUserPetVideo(_ videoURL: URL, petId: String) -> String? {
        let fileName = "user_pet_video_\(petId).mp4"
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: videoURL, to: destinationURL)
            return fileName
        } catch {
            print("Error saving video: \(error)")
            return nil
        }
    }
    
    func getUserPetVideoURL(named fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        return nil
    }
    
    func deleteUserPetMedia(petId: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
            for file in files {
                if file.contains("user_pet_\(petId)") || file.contains("user_pet_video_\(petId)") {
                    let filePath = documentsDirectory.appendingPathComponent(file)
                    try? fileManager.removeItem(at: filePath)
                }
            }
        } catch {
            print("Error deleting pet media: \(error)")
        }
    }
    
    // MARK: - Favorites Management
    func loadFavorites() {
        if let favorites = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoritePets = favorites
            for i in 0..<pets.count {
                pets[i].isFavorite = favoritePets.contains(pets[i].id)
            }
            for i in 0..<userPets.count {
                userPets[i].isFavorite = favoritePets.contains(userPets[i].id)
            }
        }
    }
    
    func toggleFavorite(pet: Pet) {
        if let index = userPets.firstIndex(where: { $0.id == pet.id }) {
            userPets[index].isFavorite.toggle()
            if userPets[index].isFavorite {
                if !favoritePets.contains(pet.id) {
                    favoritePets.append(pet.id)
                }
            } else {
                favoritePets.removeAll { $0 == pet.id }
            }
            saveUserPets()
        } else if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index].isFavorite.toggle()
            if pets[index].isFavorite {
                if !favoritePets.contains(pet.id) {
                    favoritePets.append(pet.id)
                }
            } else {
                favoritePets.removeAll { $0 == pet.id }
            }
        }
        
        UserDefaults.standard.set(favoritePets, forKey: favoritesKey)
    }
    
    func isFavorite(pet: Pet) -> Bool {
        return favoritePets.contains(pet.id)
    }
    
    // MARK: - Computed Properties
    var allPets: [Pet] {
        return userPets + pets
    }
    
    var cats: [Pet] {
        return allPets.filter { $0.type == .cat }
    }
    
    var dogs: [Pet] {
        return allPets.filter { $0.type == .dog }
    }
    
    var residentPets: [Pet] {
        return pets.filter { $0.status == .resident }
    }
    
    var boardingPets: [Pet] {
        return pets.filter { $0.status == .boarding }
    }
    
    func getPet(by id: String) -> Pet? {
        return allPets.first { $0.id == id }
    }
}

// MARK: - Booking Manager
class BookingManager: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading: Bool = false
    
    private let bookingsKey = "userBookings"
    
    init() {
        loadBookings()
    }
    
    func loadBookings() {
        if let data = UserDefaults.standard.data(forKey: bookingsKey),
           let saved = try? JSONDecoder().decode([Booking].self, from: data) {
            bookings = saved
        }
    }
    
    func saveBookings() {
        if let encoded = try? JSONEncoder().encode(bookings) {
            UserDefaults.standard.set(encoded, forKey: bookingsKey)
        }
    }
    
    func createBooking(_ booking: Booking) {
        bookings.insert(booking, at: 0)
        saveBookings()
    }
    
    func addBooking(_ booking: Booking) {
        bookings.insert(booking, at: 0)
        saveBookings()
    }
    
    func updateBookingStatus(id: String, status: Booking.BookingStatus) {
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings[index].status = status
            saveBookings()
        }
    }
    
    func cancelBooking(id: String) {
        updateBookingStatus(id: id, status: .cancelled)
    }
    
    var upcomingBookings: [Booking] {
        return bookings.filter { $0.status == .pending || $0.status == .confirmed }
            .sorted { $0.startDate < $1.startDate }
    }
    
    var pastBookings: [Booking] {
        return bookings.filter { $0.status == .completed || $0.status == .cancelled }
            .sorted { $0.endDate > $1.endDate }
    }
    
    var activeBookings: [Booking] {
        return bookings.filter { $0.status == .inProgress }
    }
    
    // MARK: - Availability
    func getAvailability(for date: Date) -> DateAvailability? {
        let calendar = Calendar.current
        
        let bookingsOnDate = bookings.filter { booking in
            guard booking.status != .cancelled else { return false }
            return date >= calendar.startOfDay(for: booking.startDate) &&
                   date <= calendar.startOfDay(for: booking.endDate)
        }
        
        let totalSpots = 5
        let usedSpots = bookingsOnDate.count
        let availableSpots = max(0, totalSpots - usedSpots)
        
        return DateAvailability(
            date: date,
            availableSpots: availableSpots,
            totalSpots: totalSpots
        )
    }
    
    func isDateAvailable(_ date: Date) -> Bool {
        guard let availability = getAvailability(for: date) else { return false }
        return !availability.isFull
    }
}

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    @Published var isAuthorized: Bool = false
    
    private let notificationsKey = "appNotifications"
    
    init() {
        loadNotifications()
        checkAuthorization()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: notificationsKey),
           let saved = try? JSONDecoder().decode([AppNotification].self, from: data) {
            notifications = saved
            updateUnreadCount()
        }
    }
    
    func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: notificationsKey)
        }
    }
    
    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
        saveNotifications()
        updateUnreadCount()
        
        if isAuthorized {
            scheduleLocalNotification(notification)
        }
    }
    
    func markAsRead(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
            saveNotifications()
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
        saveNotifications()
        updateUnreadCount()
    }
    
    func deleteNotification(id: String) {
        notifications.removeAll { $0.id == id }
        saveNotifications()
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    private func scheduleLocalNotification(_ notification: AppNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleBookingReminder(booking: Booking) {
        guard isAuthorized else { return }
        
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: booking.startDate)
        guard let reminderDate = reminderDate, reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Stay Tomorrow! 🐾"
        content.body = "\(booking.petName)'s stay at Coco's Pet Paradise starts tomorrow. Don't forget to prepare their essentials!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "booking_reminder_\(booking.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

// ============================================================
// MARK: - GAMIFICATION MANAGER
// ============================================================

class GamificationManager: ObservableObject {
    @Published var gameProfile: UserGameProfile = UserGameProfile()
    @Published var achievements: [Achievement] = []
    @Published var rewards: [Reward] = []
    @Published var virtualPetState: VirtualPetState = VirtualPetState()
    @Published var accessories: [VirtualPetAccessory] = []
    
    private let profileKey = "userGameProfile"
    private let achievementsKey = "userAchievements"
    private let virtualPetKey = "virtualPetState"
    
    init() {
        loadGameProfile()
        loadAchievements()
        loadVirtualPet()
        setupDefaultAchievements()
        setupDefaultRewards()
        setupDefaultAccessories()
    }
    
    // MARK: - Profile Management
    func loadGameProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let saved = try? JSONDecoder().decode(UserGameProfile.self, from: data) {
            gameProfile = saved
        }
    }
    
    func saveGameProfile() {
        if let encoded = try? JSONEncoder().encode(gameProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    // MARK: - Points & Leveling
    func addPoints(_ points: Int, reason: String) {
        gameProfile.totalPoints += points
        gameProfile.currentPoints += points
        gameProfile.lastActivityDate = Date()
        
        let newLevel = (gameProfile.totalPoints / 500) + 1
        if newLevel > gameProfile.level {
            gameProfile.level = newLevel
        }
        
        saveGameProfile()
        checkAchievements()
    }
    
    func spendPoints(_ points: Int) -> Bool {
        guard gameProfile.currentPoints >= points else { return false }
        gameProfile.currentPoints -= points
        saveGameProfile()
        return true
    }
    
    // MARK: - Achievements
    func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = saved
        }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    func setupDefaultAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(id: "first_booking", title: "First Stay", description: "Complete your first booking", icon: "calendar.badge.checkmark", category: .booking, pointsReward: 100, requirement: 1),
                Achievement(id: "loyal_customer", title: "Loyal Customer", description: "Complete 5 bookings", icon: "heart.fill", category: .loyalty, pointsReward: 500, requirement: 5),
                Achievement(id: "super_fan", title: "Super Fan", description: "Complete 10 bookings", icon: "star.fill", category: .loyalty, pointsReward: 1000, requirement: 10),
                Achievement(id: "social_butterfly", title: "Social Butterfly", description: "Share 5 community posts", icon: "person.3.fill", category: .social, pointsReward: 200, requirement: 5),
                Achievement(id: "explorer", title: "Explorer", description: "View all virtual tour rooms", icon: "map.fill", category: .explorer, pointsReward: 150, requirement: 10),
                Achievement(id: "diary_keeper", title: "Diary Keeper", description: "Write 10 diary entries", icon: "book.fill", category: .social, pointsReward: 300, requirement: 10),
                Achievement(id: "pet_lover", title: "Pet Lover", description: "Favorite 5 pets", icon: "heart.circle.fill", category: .loyalty, pointsReward: 100, requirement: 5),
                Achievement(id: "caretaker", title: "Virtual Caretaker", description: "Interact with virtual pet 50 times", icon: "pawprint.fill", category: .special, pointsReward: 250, requirement: 50),
                Achievement(id: "early_bird", title: "Early Bird", description: "Book 7 days in advance", icon: "sunrise.fill", category: .booking, pointsReward: 150, requirement: 1),
                Achievement(id: "reviewer", title: "Trusted Reviewer", description: "Leave 3 reviews", icon: "star.bubble.fill", category: .social, pointsReward: 200, requirement: 3),
            ]
            saveAchievements()
        }
    }
    
    func updateAchievementProgress(id: String, progress: Int) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].progress = progress
            
            if achievements[index].progress >= achievements[index].requirement && !achievements[index].isUnlocked {
                unlockAchievement(id: id)
            }
            saveAchievements()
        }
    }
    
    func incrementAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].progress += 1
            
            if achievements[index].progress >= achievements[index].requirement && !achievements[index].isUnlocked {
                unlockAchievement(id: id)
            }
            saveAchievements()
        }
    }
    
    func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()
            gameProfile.unlockedAchievements.append(id)
            addPoints(achievements[index].pointsReward, reason: "Achievement: \(achievements[index].title)")
            saveAchievements()
        }
    }
    
    func checkAchievements() {
        // Check various achievement triggers
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    // MARK: - Rewards
    func setupDefaultRewards() {
        rewards = [
            Reward(id: "discount_10", title: "10% Off Next Booking", description: "Save 10% on your next pet boarding", icon: "tag.fill", type: .discount, pointsCost: 200),
            Reward(id: "discount_20", title: "20% Off Next Booking", description: "Save 20% on your next pet boarding", icon: "tag.fill", type: .discount, pointsCost: 400),
            Reward(id: "free_grooming", title: "Free Grooming Session", description: "One free grooming during your pet's stay", icon: "sparkles", type: .freeService, pointsCost: 300),
            Reward(id: "free_pickup", title: "Free Pickup & Dropoff", description: "Free transportation for your next booking", icon: "car.fill", type: .freeService, pointsCost: 250),
            Reward(id: "crown_accessory", title: "Royal Crown", description: "Virtual crown for your pet avatar", icon: "crown.fill", type: .virtualItem, pointsCost: 100),
            Reward(id: "bow_accessory", title: "Cute Bow Tie", description: "Virtual bow tie for your pet avatar", icon: "gift.fill", type: .virtualItem, pointsCost: 75),
            Reward(id: "vip_treatment", title: "VIP Treatment", description: "Extra playtime and special treats", icon: "star.fill", type: .exclusive, pointsCost: 500),
            Reward(id: "photo_session", title: "Professional Photo Session", description: "Professional photos of your pet during their stay", icon: "camera.fill", type: .exclusive, pointsCost: 400),
        ]
    }
    
    func redeemReward(id: String) -> Bool {
        guard let reward = rewards.first(where: { $0.id == id }) else { return false }
        guard spendPoints(reward.pointsCost) else { return false }
        
        if let index = rewards.firstIndex(where: { $0.id == id }) {
            rewards[index].isRedeemed = true
            rewards[index].redeemedDate = Date()
            gameProfile.redeemedRewards.append(id)
            saveGameProfile()
        }
        
        return true
    }
    
    var availableRewards: [Reward] {
        rewards.filter { !$0.isRedeemed && gameProfile.currentPoints >= $0.pointsCost }
    }
    
    // MARK: - Virtual Pet
    func loadVirtualPet() {
        if let data = UserDefaults.standard.data(forKey: virtualPetKey),
           let saved = try? JSONDecoder().decode(VirtualPetState.self, from: data) {
            virtualPetState = saved
        }
    }
    
    func saveVirtualPet() {
        if let encoded = try? JSONEncoder().encode(virtualPetState) {
            UserDefaults.standard.set(encoded, forKey: virtualPetKey)
        }
    }
    
    func feedVirtualPet() {
        virtualPetState.feed()
        saveVirtualPet()
        incrementAchievement(id: "caretaker")
        addPoints(5, reason: "Fed virtual pet")
    }
    
    func playWithVirtualPet() {
        virtualPetState.play()
        saveVirtualPet()
        incrementAchievement(id: "caretaker")
        addPoints(10, reason: "Played with virtual pet")
    }
    
    func cleanVirtualPet() {
        virtualPetState.clean()
        saveVirtualPet()
        incrementAchievement(id: "caretaker")
        addPoints(5, reason: "Cleaned virtual pet")
    }
    
    func restVirtualPet() {
        virtualPetState.sleep()
        saveVirtualPet()
        incrementAchievement(id: "caretaker")
        addPoints(5, reason: "Let virtual pet rest")
    }
    
    func updateVirtualPetStats() {
        virtualPetState.updatePassiveStats()
        saveVirtualPet()
    }
    
    // MARK: - Accessories
    func setupDefaultAccessories() {
        accessories = [
            VirtualPetAccessory(id: "crown", name: "Royal Crown", icon: "crown.fill", category: .hat, pointsCost: 150),
            VirtualPetAccessory(id: "bowtie", name: "Bow Tie", icon: "gift.fill", category: .collar, pointsCost: 75),
            VirtualPetAccessory(id: "bandana", name: "Cute Bandana", icon: "flag.fill", category: .collar, pointsCost: 50),
            VirtualPetAccessory(id: "ball", name: "Tennis Ball", icon: "tennisball.fill", category: .toy, pointsCost: 30),
            VirtualPetAccessory(id: "mouse", name: "Toy Mouse", icon: "hare.fill", category: .toy, pointsCost: 40),
            VirtualPetAccessory(id: "cozy_bed", name: "Cozy Bed", icon: "bed.double.fill", category: .bed, pointsCost: 100),
            VirtualPetAccessory(id: "fancy_bowl", name: "Fancy Bowl", icon: "cup.and.saucer.fill", category: .bowl, pointsCost: 60),
            VirtualPetAccessory(id: "party_hat", name: "Party Hat", icon: "party.popper.fill", category: .hat, pointsCost: 80),
        ]
    }
    
    func purchaseAccessory(id: String) -> Bool {
        guard let accessory = accessories.first(where: { $0.id == id }) else { return false }
        guard spendPoints(accessory.pointsCost) else { return false }
        
        if let index = accessories.firstIndex(where: { $0.id == id }) {
            accessories[index].isOwned = true
            virtualPetState.accessories.append(id)
            gameProfile.virtualItems.append(id)
            saveVirtualPet()
            saveGameProfile()
        }
        
        return true
    }
    
    var ownedAccessories: [VirtualPetAccessory] {
        accessories.filter { $0.isOwned }
    }
}

// ============================================================
// MARK: - COMMUNITY MANAGER
// ============================================================

class CommunityManager: ObservableObject {
    @Published var posts: [CommunityPost] = []
    @Published var isLoading: Bool = false
    
    private let postsKey = "communityPosts"
    
    init() {
        loadPosts()
        if posts.isEmpty {
            setupSamplePosts()
        }
    }
    
    func loadPosts() {
        if let data = UserDefaults.standard.data(forKey: postsKey),
           let saved = try? JSONDecoder().decode([CommunityPost].self, from: data) {
            posts = saved
        }
    }
    
    func savePosts() {
        if let encoded = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(encoded, forKey: postsKey)
        }
    }
    
    func setupSamplePosts() {
        posts = [
            CommunityPost(
                authorId: "sample1",
                authorName: "Sarah M.",
                content: "Just picked up Whiskers from his 2-week stay! He looks so happy and healthy. Coco sent us daily photos and I could see he was having the time of his life! 🐱❤️",
                category: .experience,
                createdAt: Date().addingTimeInterval(-86400),
                likes: 24
            ),
            CommunityPost(
                authorId: "sample2",
                authorName: "Michael L.",
                content: "Pro tip: If your pet is staying for the first time, bring their favorite toy and a piece of clothing that smells like you. It really helps them settle in faster!",
                category: .tips,
                createdAt: Date().addingTimeInterval(-172800),
                likes: 42,
                isPinned: true
            ),
            CommunityPost(
                authorId: "sample3",
                authorName: "Jennifer K.",
                content: "Has anyone tried the grooming add-on service? My Luna needs a bath after her stay and wondering if it's worth it.",
                category: .question,
                createdAt: Date().addingTimeInterval(-259200),
                likes: 8,
                comments: [
                    PostComment(authorId: "reply1", authorName: "David W.", content: "Yes! Totally worth it. They did a great job with Buddy and the price is reasonable.")
                ]
            ),
            CommunityPost(
                authorId: "sample4",
                authorName: "Emily R.",
                content: "Look at Simba enjoying the cat play room! 📸 He usually hides from strangers but he was playing within hours. So impressed!",
                category: .showcase,
                createdAt: Date().addingTimeInterval(-345600),
                likes: 67
            ),
        ]
        savePosts()
    }
    
    func createPost(authorId: String, authorName: String, content: String, category: CommunityPost.PostCategory, images: [String] = []) {
        let post = CommunityPost(
            authorId: authorId,
            authorName: authorName,
            content: content,
            images: images,
            category: category
        )
        posts.insert(post, at: 0)
        savePosts()
    }
    
    func toggleLike(postId: String, userId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        if posts[index].likedBy.contains(userId) {
            posts[index].likedBy.removeAll { $0 == userId }
            posts[index].likes -= 1
        } else {
            posts[index].likedBy.append(userId)
            posts[index].likes += 1
        }
        savePosts()
    }
    
    func addComment(postId: String, authorId: String, authorName: String, content: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        let comment = PostComment(authorId: authorId, authorName: authorName, content: content)
        posts[index].comments.append(comment)
        savePosts()
    }
    
    func deletePost(id: String) {
        posts.removeAll { $0.id == id }
        savePosts()
    }
    
    var pinnedPosts: [CommunityPost] {
        posts.filter { $0.isPinned }
    }
    
    func postsForCategory(_ category: CommunityPost.PostCategory?) -> [CommunityPost] {
        guard let category = category else { return posts }
        return posts.filter { $0.category == category }
    }
}

// ============================================================
// MARK: - DIARY MANAGER
// ============================================================

class DiaryManager: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    @Published var savedEntries: [String] = []
    
    private let entriesKey = "diaryEntries"
    private let savedEntriesKey = "savedDiaryEntries"
    
    init() {
        loadEntries()
        loadSavedEntries()
        if entries.isEmpty {
            setupSampleEntries()
        }
    }
    
    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let saved = try? JSONDecoder().decode([DiaryEntry].self, from: data) {
            entries = saved
        }
    }
    
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    func loadSavedEntries() {
        if let saved = UserDefaults.standard.array(forKey: savedEntriesKey) as? [String] {
            savedEntries = saved
        }
    }
    
    func saveSavedEntries() {
        UserDefaults.standard.set(savedEntries, forKey: savedEntriesKey)
    }
    
    func setupSampleEntries() {
        entries = [
            DiaryEntry(
                petId: "cat-1",
                petName: "Bibi",
                authorId: "coco",
                authorName: "Coco",
                title: "Bibi's Playful Morning",
                content: "Bibi had the most adorable morning today! She discovered a new sunny spot by the window and spent hours watching birds. When playtime came around, she was extra energetic and pounced on every toy in sight. Her little munchkin legs are just the cutest! 🐱☀️",
                mood: .playful,
                createdAt: Date().addingTimeInterval(-43200),
                likes: 15
            ),
            DiaryEntry(
                petId: "cat-2",
                petName: "Dudu",
                authorId: "coco",
                authorName: "Coco",
                title: "Dudu's Spa Day",
                content: "Today was grooming day for our golden boy Dudu! He was such a patient gentleman during his brushing session. His coat is looking extra fluffy and shiny now. After all that pampering, he took a well-deserved nap on his favorite cushion. 💛✨",
                mood: .relaxed,
                createdAt: Date().addingTimeInterval(-86400),
                likes: 23
            ),
        ]
        saveEntries()
    }
    
    func createEntry(petId: String, petName: String, authorId: String, authorName: String, title: String, content: String, mood: DiaryEntry.PetMood, images: [String] = [], isPublic: Bool = true) {
        let entry = DiaryEntry(
            petId: petId,
            petName: petName,
            authorId: authorId,
            authorName: authorName,
            title: title,
            content: content,
            mood: mood,
            images: images,
            isPublic: isPublic
        )
        entries.insert(entry, at: 0)
        saveEntries()
    }
    
    func toggleLike(entryId: String, userId: String) {
        guard let index = entries.firstIndex(where: { $0.id == entryId }) else { return }
        
        if entries[index].likedBy.contains(userId) {
            entries[index].likedBy.removeAll { $0 == userId }
            entries[index].likes -= 1
        } else {
            entries[index].likedBy.append(userId)
            entries[index].likes += 1
        }
        saveEntries()
    }
    
    func addComment(entryId: String, authorId: String, authorName: String, content: String) {
        guard let index = entries.firstIndex(where: { $0.id == entryId }) else { return }
        
        let comment = DiaryComment(authorId: authorId, authorName: authorName, content: content)
        entries[index].comments.append(comment)
        saveEntries()
    }
    
    func toggleSaveEntry(entryId: String) {
        if savedEntries.contains(entryId) {
            savedEntries.removeAll { $0 == entryId }
        } else {
            savedEntries.append(entryId)
        }
        saveSavedEntries()
    }
    
    func isEntrySaved(_ entryId: String) -> Bool {
        savedEntries.contains(entryId)
    }
    
    func deleteEntry(id: String) {
        entries.removeAll { $0.id == id }
        saveEntries()
    }
    
    func entriesForPet(_ petId: String) -> [DiaryEntry] {
        entries.filter { $0.petId == petId }
    }
    
    var publicEntries: [DiaryEntry] {
        entries.filter { $0.isPublic }
    }
    
    var savedDiaryEntries: [DiaryEntry] {
        entries.filter { savedEntries.contains($0.id) }
    }
}

// ============================================================
// MARK: - PET MATCHING MANAGER
// ============================================================

class PetMatchingManager: ObservableObject {
    @Published var matchRequests: [PetMatchRequest] = []
    @Published var playdates: [PetPlaydate] = []
    
    private let matchRequestsKey = "petMatchRequests"
    private let playdatesKey = "petPlaydates"
    
    init() {
        loadMatchRequests()
        loadPlaydates()
    }
    
    func loadMatchRequests() {
        if let data = UserDefaults.standard.data(forKey: matchRequestsKey),
           let saved = try? JSONDecoder().decode([PetMatchRequest].self, from: data) {
            matchRequests = saved
        }
    }
    
    func saveMatchRequests() {
        if let encoded = try? JSONEncoder().encode(matchRequests) {
            UserDefaults.standard.set(encoded, forKey: matchRequestsKey)
        }
    }
    
    func loadPlaydates() {
        if let data = UserDefaults.standard.data(forKey: playdatesKey),
           let saved = try? JSONDecoder().decode([PetPlaydate].self, from: data) {
            playdates = saved
        }
    }
    
    func savePlaydates() {
        if let encoded = try? JSONEncoder().encode(playdates) {
            UserDefaults.standard.set(encoded, forKey: playdatesKey)
        }
    }
    
    func sendMatchRequest(requestingPet: Pet, requestingOwnerId: String, requestingOwnerName: String, targetPet: Pet, targetOwnerId: String, message: String?) {
        let request = PetMatchRequest(
            requestingPetId: requestingPet.id,
            requestingPetName: requestingPet.name,
            requestingOwnerId: requestingOwnerId,
            requestingOwnerName: requestingOwnerName,
            targetPetId: targetPet.id,
            targetPetName: targetPet.name,
            targetOwnerId: targetOwnerId,
            message: message
        )
        matchRequests.insert(request, at: 0)
        saveMatchRequests()
    }
    
    func respondToRequest(requestId: String, accept: Bool) {
        guard let index = matchRequests.firstIndex(where: { $0.id == requestId }) else { return }
        
        matchRequests[index] = PetMatchRequest(
            id: matchRequests[index].id,
            requestingPetId: matchRequests[index].requestingPetId,
            requestingPetName: matchRequests[index].requestingPetName,
            requestingOwnerId: matchRequests[index].requestingOwnerId,
            requestingOwnerName: matchRequests[index].requestingOwnerName,
            targetPetId: matchRequests[index].targetPetId,
            targetPetName: matchRequests[index].targetPetName,
            targetOwnerId: matchRequests[index].targetOwnerId,
            status: accept ? .accepted : .declined,
            message: matchRequests[index].message,
            createdAt: matchRequests[index].createdAt,
            respondedAt: Date()
        )
        saveMatchRequests()
    }
    
    func schedulePlaydate(request: PetMatchRequest, date: Date, location: String?, notes: String?) {
        let playdate = PetPlaydate(
            pet1Id: request.requestingPetId,
            pet1Name: request.requestingPetName,
            owner1Id: request.requestingOwnerId,
            pet2Id: request.targetPetId,
            pet2Name: request.targetPetName,
            owner2Id: request.targetOwnerId,
            scheduledDate: date,
            location: location,
            notes: notes
        )
        playdates.insert(playdate, at: 0)
        savePlaydates()
    }
    
    func pendingRequestsForUser(_ userId: String) -> [PetMatchRequest] {
        matchRequests.filter { $0.targetOwnerId == userId && $0.status == .pending }
    }
    
    func upcomingPlaydates(for userId: String) -> [PetPlaydate] {
        playdates.filter {
            ($0.owner1Id == userId || $0.owner2Id == userId) &&
            $0.status == .scheduled &&
            $0.scheduledDate > Date()
        }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
}

// ============================================================
// MARK: - ACTIVITY TRACKING MANAGER
// ============================================================

class ActivityTrackingManager: ObservableObject {
    @Published var activities: [PetActivity] = []
    @Published var locationUpdates: [PetLocationUpdate] = []
    
    private let activitiesKey = "petActivities"
    
    init() {
        loadActivities()
        if activities.isEmpty {
            setupSampleActivities()
        }
    }
    
    func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let saved = try? JSONDecoder().decode([PetActivity].self, from: data) {
            activities = saved
        }
    }
    
    func saveActivities() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
    }
    
    func setupSampleActivities() {
        activities = [
            PetActivity(petId: "cat-1", petName: "Bibi", activityType: .playing, timestamp: Date().addingTimeInterval(-3600), location: "Cat Play Room"),
            PetActivity(petId: "cat-1", petName: "Bibi", activityType: .feeding, timestamp: Date().addingTimeInterval(-7200), location: "Gourmet Kitchen"),
            PetActivity(petId: "cat-2", petName: "Dudu", activityType: .resting, timestamp: Date().addingTimeInterval(-1800), location: "Cat Suite"),
        ]
        saveActivities()
    }
    
    func addActivity(petId: String, petName: String, type: PetActivity.ActivityType, location: String?, notes: String?) {
        let activity = PetActivity(
            petId: petId,
            petName: petName,
            activityType: type,
            location: location,
            notes: notes
        )
        activities.insert(activity, at: 0)
        saveActivities()
    }
    
    func activitiesForPet(_ petId: String) -> [PetActivity] {
        activities.filter { $0.petId == petId }
    }
    
    func recentActivities(limit: Int = 20) -> [PetActivity] {
        Array(activities.prefix(limit))
    }
    
    func updateLocation(petId: String, area: String, status: String) {
        let update = PetLocationUpdate(petId: petId, area: area, status: status)
        locationUpdates.removeAll { $0.petId == petId }
        locationUpdates.insert(update, at: 0)
    }
    
    func currentLocation(for petId: String) -> PetLocationUpdate? {
        locationUpdates.first { $0.petId == petId }
    }
}

// ============================================================
// MARK: - SAMPLE DATA (24 Pets matching asset folders)
// ============================================================

struct SampleData {
    // 24 pets matching the asset folders exactly:
    // bibi, caicai, chacha, chouchou, dudu, ergou, fifi, haha, jiujiu, loki, meimei, mia-cat
    // mia-dog, nana, neon, nova, oscar, richard, tata, toast, tutu, xiabao, xianbei, yaya
    
    static let pets: [Pet] = [
            // ===== CATS (13) =====
            Pet(id: "cat-1", name: "Bibi", type: .cat, breed: "Munchkin Silver Shaded", age: nil,
                status: .resident, personality: ["Playful", "Curious", "Affectionate"],
                favoriteActivities: ["Chasing toys", "Sunbathing", "Cuddles"],
                image: "bibi-1", images: ["bibi-1", "bibi-2", "bibi-3"],
                video: "Bibi",
                joinedDate: "2022-01-15"),
            
            Pet(id: "cat-2", name: "Dudu", type: .cat, breed: "British Shorthair Golden", age: nil,
                status: .resident, personality: ["Gentle", "Calm", "Friendly"],
                favoriteActivities: ["Napping", "Bird watching", "Treats"],
                image: "dudu-1", images: ["dudu-1", "dudu-2", "dudu-3"],
                video: "Dudu",
                joinedDate: "2022-03-20"),
            
            Pet(id: "cat-3", name: "Fifi", type: .cat, breed: "Golden British Shorthair", age: nil,
                status: .boarding, personality: ["Energetic", "Playful", "Adorable"],
                favoriteActivities: ["Playing with feathers", "Exploring", "Milk time"],
                image: "fifi-1", images: ["fifi-1", "fifi-2", "fifi-3"],
                video: "Fifi",
                joinedDate: "2024-09-01"),
            
            Pet(id: "cat-4", name: "Meimei", type: .cat, breed: "Ragdoll", age: nil,
                status: .boarding, personality: ["Sweet", "Docile", "Loving"],
                favoriteActivities: ["Being held", "Grooming", "Quiet play"],
                image: "meimei-1", images: ["meimei-1", "meimei-2", "meimei-3"],
                video: "Meimei",
                joinedDate: "2024-06-15"),
            
            Pet(id: "cat-5", name: "Neon", type: .cat, breed: "Ragdoll", age: nil,
                status: .boarding, personality: ["Independent", "Elegant", "Observant"],
                favoriteActivities: ["High perches", "Solo play", "Window watching"],
                image: "neon-1", images: ["neon-1", "neon-2", "neon-3"],
                video: "Neon",
                joinedDate: "2024-07-20"),
            
            Pet(id: "cat-6", name: "Xiabao", type: .cat, breed: "Ragdoll", age: nil,
                status: .boarding, personality: ["Playful", "Social", "Gentle"],
                favoriteActivities: ["Group play", "Feather wands", "Treats"],
                image: "xiabao-1", images: ["xiabao-1", "xiabao-2", "xiabao-3"],
                video: "XiaBao",
                joinedDate: "2024-08-10"),
            
            Pet(id: "cat-7", name: "Mia", type: .cat, breed: "Ragdoll", age: nil,
                status: .boarding, personality: ["Affectionate", "Quiet", "Sweet"],
                favoriteActivities: ["Lap sitting", "Soft toys", "Gentle pets"],
                image: "mia-cat-1", images: ["mia-cat-1", "mia-cat-2", "mia-cat-3"],
                video: "Mia_cat",
                joinedDate: "2024-08-25"),
            
            Pet(id: "cat-8", name: "Tutu", type: .cat, breed: "Siamese", age: nil,
                status: .boarding, personality: ["Vocal", "Active", "Intelligent"],
                favoriteActivities: ["Talking", "Puzzle toys", "Climbing"],
                image: "tutu-1", images: ["tutu-1", "tutu-2", "tutu-3"],
                video: "Tutu",
                joinedDate: "2024-09-05"),
            
            Pet(id: "cat-9", name: "Xianbei", type: .cat, breed: "Silver Shaded", age: nil,
                status: .boarding, personality: ["Calm", "Dignified", "Observant"],
                favoriteActivities: ["Quiet spaces", "Grooming", "Watching others"],
                image: "xianbei-1", images: ["xianbei-1", "xianbei-2", "xianbei-3"],
                video: "Xianbei",
                joinedDate: "2024-09-10"),
            
            Pet(id: "cat-10", name: "Chacha", type: .cat, breed: "Silver Shaded", age: nil,
                status: .boarding, personality: ["Friendly", "Curious", "Adaptable"],
                favoriteActivities: ["Exploring", "Making friends", "Cat TV"],
                image: "chacha-1", images: ["chacha-1", "chacha-2", "chacha-3"],
                video: "Chacha",
                joinedDate: "2024-09-15"),
            
            Pet(id: "cat-11", name: "Yaya", type: .cat, breed: "Black Cat", age: nil,
                status: .boarding, personality: ["Mysterious", "Playful", "Loyal"],
                favoriteActivities: ["Night play", "Hide and seek", "String toys"],
                image: "yaya-1", images: ["yaya-1", "yaya-2", "yaya-3"],
                video: "Yaya",
                joinedDate: "2024-09-20"),
            
            Pet(id: "cat-12", name: "Er Gou", type: .cat, breed: "Tuxedo Cat", age: nil,
                status: .boarding, personality: ["Mischievous", "Energetic", "Loving"],
                favoriteActivities: ["Running", "Playing with balls", "Attention"],
                image: "ergou-1", images: ["ergou-1", "ergou-2", "ergou-3"],
                video: "Ergou",
                joinedDate: "2024-09-25"),
            
            Pet(id: "cat-13", name: "Chouchou", type: .cat, breed: "Orange Tabby", age: nil,
                status: .boarding, personality: ["Laid-back", "Food-loving", "Cuddly"],
                favoriteActivities: ["Eating", "Sleeping", "Belly rubs"],
                image: "chouchou-1", images: ["chouchou-1", "chouchou-2", "chouchou-3"],
                video: "chouchou",
                joinedDate: "2024-10-01"),
            
            // ===== DOGS (11) =====
            Pet(id: "dog-1", name: "Oscar", type: .dog, breed: "Golden Retriever", age: nil,
                status: .boarding, personality: ["Puppy Energy", "Friendly", "Eager to Learn"],
                favoriteActivities: ["Fetch", "Puppy play", "Training treats"],
                image: "oscar-1", images: ["oscar-1", "oscar-2", "oscar-3"],
                video: "Oscar",
                joinedDate: "2024-09-01"),
            
            Pet(id: "dog-2", name: "Loki", type: .dog, breed: "Greyhound", age: nil,
                status: .boarding, personality: ["Fast", "Gentle", "Calm Indoors"],
                favoriteActivities: ["Running", "Couch lounging", "Gentle walks"],
                image: "loki-1", images: ["loki-1", "loki-2", "loki-3"],
                video: "Loki",
                joinedDate: "2024-07-15"),
            
            Pet(id: "dog-3", name: "Nana", type: .dog, breed: "Border Collie", age: nil,
                status: .boarding, personality: ["Intelligent", "Active", "Herding Instinct"],
                favoriteActivities: ["Agility", "Frisbee", "Problem solving"],
                image: "nana-1", images: ["nana-1", "nana-2", "nana-3"],
                video: "Nana",
                joinedDate: "2024-08-01"),
            
            Pet(id: "dog-4", name: "Richard", type: .dog, breed: "Border Collie", age: nil,
                status: .boarding, personality: ["Smart", "Energetic", "Focused"],
                favoriteActivities: ["Training", "Ball games", "Running"],
                image: "richard-1", images: ["richard-1", "richard-2", "richard-3"],
                video: "Richard",
                joinedDate: "2024-08-10"),
            
            Pet(id: "dog-5", name: "Tata", type: .dog, breed: "Border Collie", age: nil,
                status: .boarding, personality: ["Playful", "Alert", "Loyal"],
                favoriteActivities: ["Herding games", "Tricks", "Long walks"],
                image: "tata-1", images: ["tata-1", "tata-2", "tata-3"],
                video: "Tata",
                joinedDate: "2024-08-20"),
            
            Pet(id: "dog-6", name: "Caicai", type: .dog, breed: "Shiba Inu", age: nil,
                status: .boarding, personality: ["Independent", "Alert", "Spirited"],
                favoriteActivities: ["Exploring", "Tug of war", "Puzzle toys"],
                image: "caicai-1", images: ["caicai-1", "caicai-2", "caicai-3"],
                video: "Caicai",
                joinedDate: "2024-09-05"),
            
            Pet(id: "dog-7", name: "Mia", type: .dog, breed: "American Cocker Spaniel", age: nil,
                status: .boarding, personality: ["Gentle", "Happy", "Affectionate"],
                favoriteActivities: ["Grooming", "Gentle play", "Cuddles"],
                image: "mia-dog-1", images: ["mia-dog-1", "mia-dog-2", "mia-dog-3"],
                video: "Mia_dog",
                joinedDate: "2024-09-12"),
            
            Pet(id: "dog-8", name: "Nova", type: .dog, breed: "Golden Retriever", age: nil,
                status: .boarding, personality: ["Friendly", "Patient", "Loving"],
                favoriteActivities: ["Swimming", "Fetch", "Meeting friends"],
                image: "nova-1", images: ["nova-1", "nova-2", "nova-3"],
                video: "Nova",
                joinedDate: "2024-09-18"),
            
            Pet(id: "dog-9", name: "Haha", type: .dog, breed: "Samoyed", age: nil,
                status: .boarding, personality: ["Cheerful", "Friendly", "Fluffy"],
                favoriteActivities: ["Playing in snow", "Smiling", "Cuddles"],
                image: "haha-1", images: ["haha-1", "haha-2", "haha-3"],
                video: "Haha",
                joinedDate: "2024-10-05"),
            
            Pet(id: "dog-10", name: "Jiujiu", type: .dog, breed: "Samoyed", age: nil,
                status: .boarding, personality: ["Gentle", "Playful", "Sweet"],
                favoriteActivities: ["Running", "Being brushed", "Treats"],
                image: "jiujiu-1", images: ["jiujiu-1", "jiujiu-2", "jiujiu-3"],
                video: "Jiujiu",
                joinedDate: "2024-10-10"),
            
            Pet(id: "dog-11", name: "Toast", type: .dog, breed: "Standard Poodle", age: nil,
                status: .boarding, personality: ["Intelligent", "Elegant", "Active"],
                favoriteActivities: ["Learning tricks", "Swimming", "Agility"],
                image: "toast-1", images: ["toast-1", "toast-2", "toast-3"],
                video: "Toast",
                joinedDate: "2024-10-15")
        ]
    
    static let services: [Service] = [
        Service(icon: "house.fill", title: "Home Boarding",
                description: "Your pet stays in our cozy home environment with 24/7 supervision and care",
                price: "Cat: $25 | Dog: $40-60/night",
                features: ["Comfortable home environment", "24/7 supervision", "Separate spaces for cats and dogs", "Daily exercise and playtime"],
                isPopular: true, category: .essential),
        
        Service(icon: "heart.fill", title: "Personalized Care",
                description: "Customized care plans tailored to your pet's unique needs and preferences",
                price: "Included with boarding",
                features: ["Custom feeding schedules", "Special diet accommodation", "Individual attention", "Behavioral support", "Senior pet care"],
                category: .essential),
        
        Service(icon: "camera.fill", title: "Daily Updates",
                description: "Stay connected with photos and videos of your pet throughout the day",
                price: "Included with boarding",
                features: ["Morning & evening photos", "Video updates", "Activity reports", "Real-time messaging", "Emergency notifications"],
                isPopular: true, category: .essential),
        
        Service(icon: "car.fill", title: "Pick-up & Drop-off",
                description: "Convenient transportation service for your pet's comfort",
                price: "Free (within 10 miles) | From $20",
                features: ["Safe, comfortable vehicles", "Secured pet carriers", "Flexible scheduling", "Door-to-door service", "GPS tracking available"],
                category: .addon),
        
        Service(icon: "shower.fill", title: "Grooming Services",
                description: "Keep your pet clean and comfortable during their stay",
                price: "From $15/session",
                features: ["Brushing and combing", "Nail trimming", "Ear cleaning", "Teeth cleaning", "Bath (if needed)"],
                category: .addon),
        
        Service(icon: "pills.fill", title: "Medical Care",
                description: "Professional medication administration and health monitoring",
                price: "Included with boarding",
                features: ["Medication administration", "Health monitoring", "Vet coordination", "Special needs care", "Emergency protocols"],
                category: .essential),
        
        Service(icon: "play.fill", title: "Activities & Enrichment",
                description: "Fun activities to keep your pet engaged and happy",
                price: "Included with boarding",
                features: ["Interactive play sessions", "Puzzle toys", "Socialization time", "Indoor/outdoor play", "Training reinforcement"],
                category: .essential),
        
        Service(icon: "moon.fill", title: "Overnight Care",
                description: "Round-the-clock supervision for pets needing extra attention",
                price: "Included with boarding",
                features: ["Nighttime monitoring", "Comfort checks", "Anxiety support", "Emergency response", "Bedtime routines"],
                category: .essential)
    ]
    
    static let testimonials: [Testimonial] = [
        Testimonial(authorName: "Sarah M.", petName: "Whiskers", petType: .cat, rating: 5,
                   content: "Coco took amazing care of our cat. The daily photo updates were wonderful and Whiskers came home so happy!"),
        
        Testimonial(authorName: "Michael L.", petName: "Max", petType: .dog, rating: 5,
                   content: "Best pet boarding experience ever! Max was treated like family. Will definitely be back!"),
        
        Testimonial(authorName: "Jennifer K.", petName: "Luna", petType: .cat, rating: 5,
                   content: "So grateful we found Coco's Pet Paradise. Luna is usually anxious but she was so comfortable here."),
        
        Testimonial(authorName: "David W.", petName: "Buddy", petType: .dog, rating: 5,
                   content: "The personalized care and attention to detail is outstanding. Buddy had the time of his life!"),
        
        Testimonial(authorName: "Emily R.", petName: "Simba", petType: .cat, rating: 5,
                   content: "Coco is truly a pet whisperer. Simba, who usually hides from strangers, was playing and happy within hours.")
    ]
    
    static let virtualTourRooms: [VirtualTourRoom] = [
        VirtualTourRoom(name: "Welcome Entrance", category: .common, image: "entrance",
                       description: "A warm and inviting entrance where every pet feels at home",
                       features: ["Check-in Area", "Welcome Treats", "Photo Wall"]),
        VirtualTourRoom(name: "Living Room", category: .common, image: "living-room",
                       description: "Cozy common area for socializing and relaxation",
                       features: ["Plush Sofas", "Natural Light", "Play Area"]),
        VirtualTourRoom(name: "Cat Suite", category: .cats, image: "cat-suite",
                       description: "Luxurious private suites designed for feline comfort",
                       features: ["Climbing Trees", "Window Views", "Private Litter"]),
        VirtualTourRoom(name: "Cat Play Room", category: .cats, image: "cat-play",
                       description: "Interactive play space with toys and climbing structures",
                       features: ["Cat Trees", "Toys", "Scratching Posts"]),
        VirtualTourRoom(name: "Dog Suite", category: .dogs, image: "dog-suite",
                       description: "Spacious rooms with comfy beds for our canine guests",
                       features: ["Orthopedic Beds", "Climate Control", "Music"]),
        VirtualTourRoom(name: "Dog Activity Zone", category: .dogs, image: "dog-activity",
                       description: "Indoor play area for exercise and fun",
                       features: ["Agility Equipment", "Ball Pit", "Tug Toys"]),
        VirtualTourRoom(name: "Gourmet Kitchen", category: .services, image: "kitchen",
                       description: "Where we prepare fresh, nutritious meals",
                       features: ["Fresh Food", "Special Diets", "Treats"]),
        VirtualTourRoom(name: "Garden Patio", category: .outdoor, image: "garden",
                       description: "Beautiful outdoor space for fresh air and sunshine",
                       features: ["Grass Area", "Shade Trees", "Water Features"]),
        VirtualTourRoom(name: "Spa & Grooming", category: .services, image: "spa",
                       description: "Professional grooming and pampering services",
                       features: ["Bathing", "Grooming", "Nail Trim"]),
        VirtualTourRoom(name: "Rest Area", category: .common, image: "rest-area",
                       description: "Quiet space for naps and peaceful rest",
                       features: ["Soft Beds", "Dim Lighting", "White Noise"])
    ]
}
