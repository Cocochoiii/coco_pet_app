//
//  Models.swift
//  CocoPetParadise
//
//  Data models for pets, bookings, services, testimonials,
//  gamification, community, diary, and matching features
//

import Foundation
import SwiftUI

// MARK: - Pet Model
struct Pet: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: PetType
    let breed: String
    let age: String?
    let status: PetStatus
    let personality: [String]
    let favoriteActivities: [String]
    let image: String
    let images: [String]
    let video: String?
    let joinedDate: String
    var isFavorite: Bool = false
    var isUserPet: Bool = false
    
    enum PetType: String, Codable, CaseIterable {
        case cat = "cat"
        case dog = "dog"
        
        var icon: String {
            switch self {
            case .cat: return "cat.fill"
            case .dog: return "dog.fill"
            }
        }
        
        var displayName: String {
            switch self {
            case .cat: return "Cat"
            case .dog: return "Dog"
            }
        }
    }
    
    enum PetStatus: String, Codable {
        case resident = "resident"
        case boarding = "boarding"
        case myPet = "my_pet"
        
        var displayName: String {
            switch self {
            case .resident: return "Resident"
            case .boarding: return "Boarding"
            case .myPet: return "My Pet"
            }
        }
        
        var color: Color {
            switch self {
            case .resident: return AppColors.success
            case .boarding: return AppColors.info
            case .myPet: return AppColors.primary700
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         type: PetType,
         breed: String,
         age: String? = nil,
         status: PetStatus,
         personality: [String] = [],
         favoriteActivities: [String] = [],
         image: String,
         images: [String],
         video: String? = nil,
         joinedDate: String,
         isFavorite: Bool = false,
         isUserPet: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.breed = breed
        self.age = age
        self.status = status
        self.personality = personality
        self.favoriteActivities = favoriteActivities
        self.image = image
        self.images = images
        self.video = video
        self.joinedDate = joinedDate
        self.isFavorite = isFavorite
        self.isUserPet = isUserPet
    }
    
    static func == (lhs: Pet, rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Booking Model
struct Booking: Identifiable, Codable {
    let id: String
    var petName: String
    var petType: Pet.PetType
    var ownerName: String
    var ownerEmail: String
    var ownerPhone: String
    var startDate: Date
    var endDate: Date
    var status: BookingStatus
    var specialRequests: String?
    var totalPrice: Double
    var createdAt: Date
    
    enum BookingStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case confirmed = "confirmed"
        case inProgress = "in_progress"
        case completed = "completed"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .confirmed: return "Confirmed"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return AppColors.warning
            case .confirmed: return AppColors.info
            case .inProgress: return AppColors.primary
            case .completed: return AppColors.success
            case .cancelled: return AppColors.error
            }
        }
        
        var icon: String {
            switch self {
            case .pending: return "clock"
            case .confirmed: return "checkmark.circle"
            case .inProgress: return "pawprint.fill"
            case .completed: return "checkmark.seal.fill"
            case .cancelled: return "xmark.circle"
            }
        }
    }
    
    var numberOfNights: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    init(id: String = UUID().uuidString,
         petName: String,
         petType: Pet.PetType,
         ownerName: String,
         ownerEmail: String,
         ownerPhone: String,
         startDate: Date,
         endDate: Date,
         status: BookingStatus = .pending,
         specialRequests: String? = nil,
         totalPrice: Double = 0) {
        self.id = id
        self.petName = petName
        self.petType = petType
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.ownerPhone = ownerPhone
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.specialRequests = specialRequests
        self.totalPrice = totalPrice
        self.createdAt = Date()
    }
}

// MARK: - Service Model
struct Service: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let price: String
    let features: [String]
    let isPopular: Bool
    let category: ServiceCategory
    
    enum ServiceCategory: String, CaseIterable {
        case essential = "Essential"
        case addon = "Add-on"
        
        var color: Color {
            switch self {
            case .essential: return AppColors.primary
            case .addon: return AppColors.info
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         icon: String,
         title: String,
         description: String,
         price: String,
         features: [String],
         isPopular: Bool = false,
         category: ServiceCategory = .essential) {
        self.id = id
        self.icon = icon
        self.title = title
        self.description = description
        self.price = price
        self.features = features
        self.isPopular = isPopular
        self.category = category
    }
}

// MARK: - Testimonial Model
struct Testimonial: Identifiable, Codable {
    let id: String
    let authorName: String
    let authorImage: String?
    let petName: String
    let petType: Pet.PetType
    let rating: Int
    let content: String
    let date: Date
    
    init(id: String = UUID().uuidString,
         authorName: String,
         authorImage: String? = nil,
         petName: String,
         petType: Pet.PetType,
         rating: Int,
         content: String,
         date: Date = Date()) {
        self.id = id
        self.authorName = authorName
        self.authorImage = authorImage
        self.petName = petName
        self.petType = petType
        self.rating = rating
        self.content = content
        self.date = date
    }
}

// MARK: - Pricing
struct Pricing {
    static let catBoardingPerNight: Double = 25
    static let dogSmallBoardingPerNight: Double = 40
    static let dogLargeBoardingPerNight: Double = 60
    static let dogDaycarePerDay: Double = 25
    static let groomingBase: Double = 15
    static let pickupFreeRadius: Double = 10
    static let pickupBasePrice: Double = 20
    static let taxRate: Double = 0.0625
    
    static func calculateTotal(petType: Pet.PetType, nights: Int, includesGrooming: Bool = false, pickupDistance: Double = 0) -> Double {
        var total: Double = 0
        
        switch petType {
        case .cat:
            total = catBoardingPerNight * Double(nights)
        case .dog:
            total = dogSmallBoardingPerNight * Double(nights)
        }
        
        if includesGrooming {
            total += groomingBase
        }
        
        if pickupDistance > pickupFreeRadius {
            total += pickupBasePrice
        }
        
        total *= (1 + taxRate)
        
        return total
    }
}

// MARK: - Date Availability
struct DateAvailability {
    let date: Date
    let availableSpots: Int
    let totalSpots: Int
    
    var isFull: Bool {
        availableSpots == 0
    }
    
    var isLimitedAvailability: Bool {
        availableSpots > 0 && availableSpots <= 2
    }
    
    var statusColor: Color {
        if isFull {
            return AppColors.error
        } else if isLimitedAvailability {
            return AppColors.warning
        } else {
            return AppColors.success
        }
    }
}

// MARK: - Contact Form
struct ContactForm {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var petName: String = ""
    var petType: Pet.PetType = .cat
    var message: String = ""
    var preferredContactMethod: ContactMethod = .email
    
    enum ContactMethod: String, CaseIterable {
        case email = "Email"
        case phone = "Phone"
        case text = "Text Message"
    }
    
    var isValid: Bool {
        !name.isEmpty && !email.isEmpty && email.contains("@") && !message.isEmpty
    }
}

// MARK: - Notification
struct AppNotification: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let type: NotificationType
    let date: Date
    var isRead: Bool
    
    enum NotificationType: String, Codable {
        case booking = "booking"
        case reminder = "reminder"
        case update = "update"
        case promotion = "promotion"
        case achievement = "achievement"
        case community = "community"
        
        var icon: String {
            switch self {
            case .booking: return "calendar"
            case .reminder: return "bell.fill"
            case .update: return "pawprint.fill"
            case .promotion: return "tag.fill"
            case .achievement: return "trophy.fill"
            case .community: return "person.3.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .booking: return AppColors.info
            case .reminder: return AppColors.warning
            case .update: return AppColors.success
            case .promotion: return AppColors.primary
            case .achievement: return AppColors.warning
            case .community: return AppColors.primary600
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         body: String,
         type: NotificationType,
         date: Date = Date(),
         isRead: Bool = false) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        self.date = date
        self.isRead = isRead
    }
}

// MARK: - Virtual Tour Room
struct VirtualTourRoom: Identifiable {
    let id: String
    let name: String
    let category: RoomCategory
    let image: String
    let description: String
    let features: [String]
    
    enum RoomCategory: String, CaseIterable {
        case all = "All"
        case common = "Common Areas"
        case cats = "Cat Spaces"
        case dogs = "Dog Spaces"
        case outdoor = "Outdoor"
        case services = "Services"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .common: return "house.fill"
            case .cats: return "cat.fill"
            case .dogs: return "dog.fill"
            case .outdoor: return "leaf.fill"
            case .services: return "sparkles"
            }
        }
        
        var displayName: String {
            return self.rawValue
        }
        
        var color: Color {
            switch self {
            case .all: return AppColors.primary700
            case .common: return AppColors.info
            case .cats: return AppColors.primary600
            case .dogs: return AppColors.warning
            case .outdoor: return AppColors.success
            case .services: return AppColors.primary
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         category: RoomCategory,
         image: String,
         description: String,
         features: [String]) {
        self.id = id
        self.name = name
        self.category = category
        self.image = image
        self.description = description
        self.features = features
    }
}

// ============================================================
// MARK: - NEW GAMIFICATION MODELS
// ============================================================

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let pointsReward: Int
    let requirement: Int
    var progress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    enum AchievementCategory: String, Codable, CaseIterable {
        case booking = "Booking"
        case social = "Social"
        case loyalty = "Loyalty"
        case explorer = "Explorer"
        case special = "Special"
        
        var icon: String {
            switch self {
            case .booking: return "calendar.badge.checkmark"
            case .social: return "person.3.fill"
            case .loyalty: return "heart.fill"
            case .explorer: return "map.fill"
            case .special: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .booking: return AppColors.info
            case .social: return AppColors.primary600
            case .loyalty: return AppColors.error
            case .explorer: return AppColors.success
            case .special: return AppColors.warning
            }
        }
    }
    
    var progressPercent: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(progress) / Double(requirement), 1.0)
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         icon: String,
         category: AchievementCategory,
         pointsReward: Int,
         requirement: Int,
         progress: Int = 0,
         isUnlocked: Bool = false,
         unlockedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.pointsReward = pointsReward
        self.requirement = requirement
        self.progress = progress
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

// MARK: - Reward Model
struct Reward: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let type: RewardType
    let pointsCost: Int
    var isRedeemed: Bool
    var redeemedDate: Date?
    
    enum RewardType: String, Codable, CaseIterable {
        case discount = "Discount"
        case freeService = "Free Service"
        case virtualItem = "Virtual Item"
        case exclusive = "Exclusive"
        
        var color: Color {
            switch self {
            case .discount: return AppColors.success
            case .freeService: return AppColors.info
            case .virtualItem: return AppColors.primary600
            case .exclusive: return AppColors.warning
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         icon: String,
         type: RewardType,
         pointsCost: Int,
         isRedeemed: Bool = false,
         redeemedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.type = type
        self.pointsCost = pointsCost
        self.isRedeemed = isRedeemed
        self.redeemedDate = redeemedDate
    }
}

// MARK: - User Points & Level
struct UserGameProfile: Codable {
    var totalPoints: Int
    var currentPoints: Int
    var level: Int
    var streak: Int
    var lastActivityDate: Date?
    var unlockedAchievements: [String]
    var redeemedRewards: [String]
    var virtualItems: [String]
    
    var levelTitle: String {
        switch level {
        case 0...2: return "Pet Newcomer"
        case 3...5: return "Pet Lover"
        case 6...9: return "Pet Champion"
        case 10...14: return "Pet Master"
        default: return "Pet Legend"
        }
    }
    
    var pointsToNextLevel: Int {
        let nextLevelPoints = (level + 1) * 500
        return max(0, nextLevelPoints - totalPoints)
    }
    
    var levelProgress: Double {
        let currentLevelPoints = level * 500
        let nextLevelPoints = (level + 1) * 500
        let progressPoints = totalPoints - currentLevelPoints
        let requiredPoints = nextLevelPoints - currentLevelPoints
        return min(Double(progressPoints) / Double(requiredPoints), 1.0)
    }
    
    init() {
        self.totalPoints = 0
        self.currentPoints = 0
        self.level = 1
        self.streak = 0
        self.lastActivityDate = nil
        self.unlockedAchievements = []
        self.redeemedRewards = []
        self.virtualItems = []
    }
}

// ============================================================
// MARK: - PET DIARY MODELS
// ============================================================

// MARK: - Diary Entry
struct DiaryEntry: Identifiable, Codable {
    let id: String
    let petId: String
    let petName: String
    let authorId: String
    let authorName: String
    let title: String
    let content: String
    let mood: PetMood
    let images: [String]
    let createdAt: Date
    var likes: Int
    var likedBy: [String]
    var comments: [DiaryComment]
    var isPublic: Bool
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    enum PetMood: String, Codable, CaseIterable {
        case happy = "Happy"
        case playful = "Playful"
        case sleepy = "Sleepy"
        case hungry = "Hungry"
        case curious = "Curious"
        case relaxed = "Relaxed"
        case excited = "Excited"
        case cuddly = "Cuddly"
        
        var icon: String {
            switch self {
            case .happy: return "face.smiling.fill"
            case .playful: return "figure.run"
            case .sleepy: return "moon.zzz.fill"
            case .hungry: return "fork.knife"
            case .curious: return "eyes"
            case .relaxed: return "leaf.fill"
            case .excited: return "sparkles"
            case .cuddly: return "heart.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .happy: return AppColors.warning
            case .playful: return AppColors.success
            case .sleepy: return AppColors.info
            case .hungry: return AppColors.primary600
            case .curious: return AppColors.primary
            case .relaxed: return AppColors.success
            case .excited: return AppColors.warning
            case .cuddly: return AppColors.error
            }
        }
        
        var emoji: String {
            switch self {
            case .happy: return "😊"
            case .playful: return "🎮"
            case .sleepy: return "😴"
            case .hungry: return "🍽️"
            case .curious: return "🤔"
            case .relaxed: return "😌"
            case .excited: return "🎉"
            case .cuddly: return "🥰"
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         petId: String,
         petName: String,
         authorId: String,
         authorName: String,
         title: String,
         content: String,
         mood: PetMood,
         images: [String] = [],
         createdAt: Date = Date(),
         likes: Int = 0,
         likedBy: [String] = [],
         comments: [DiaryComment] = [],
         isPublic: Bool = true) {
        self.id = id
        self.petId = petId
        self.petName = petName
        self.authorId = authorId
        self.authorName = authorName
        self.title = title
        self.content = content
        self.mood = mood
        self.images = images
        self.createdAt = createdAt
        self.likes = likes
        self.likedBy = likedBy
        self.comments = comments
        self.isPublic = isPublic
    }
}

// MARK: - Diary Comment
struct DiaryComment: Identifiable, Codable {
    let id: String
    let authorId: String
    let authorName: String
    let content: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         authorId: String,
         authorName: String,
         content: String,
         createdAt: Date = Date()) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.createdAt = createdAt
    }
}

// ============================================================
// MARK: - COMMUNITY MODELS
// ============================================================

// MARK: - Community Post
struct CommunityPost: Identifiable, Codable {
    let id: String
    let authorId: String
    let authorName: String
    let authorImage: String?
    let content: String
    let images: [String]
    let category: PostCategory
    let createdAt: Date
    var likes: Int
    var likedBy: [String]
    var comments: [PostComment]
    var isPinned: Bool
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    enum PostCategory: String, Codable, CaseIterable {
        case experience = "Experience"
        case tips = "Tips & Advice"
        case question = "Question"
        case showcase = "Pet Showcase"
        case review = "Review"
        
        var icon: String {
            switch self {
            case .experience: return "book.fill"
            case .tips: return "lightbulb.fill"
            case .question: return "questionmark.circle.fill"
            case .showcase: return "photo.fill"
            case .review: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .experience: return AppColors.info
            case .tips: return AppColors.warning
            case .question: return AppColors.primary600
            case .showcase: return AppColors.success
            case .review: return AppColors.primary
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         authorId: String,
         authorName: String,
         authorImage: String? = nil,
         content: String,
         images: [String] = [],
         category: PostCategory,
         createdAt: Date = Date(),
         likes: Int = 0,
         likedBy: [String] = [],
         comments: [PostComment] = [],
         isPinned: Bool = false) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorImage = authorImage
        self.content = content
        self.images = images
        self.category = category
        self.createdAt = createdAt
        self.likes = likes
        self.likedBy = likedBy
        self.comments = comments
        self.isPinned = isPinned
    }
}

// MARK: - Post Comment
struct PostComment: Identifiable, Codable {
    let id: String
    let authorId: String
    let authorName: String
    let content: String
    let createdAt: Date
    var likes: Int
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    init(id: String = UUID().uuidString,
         authorId: String,
         authorName: String,
         content: String,
         createdAt: Date = Date(),
         likes: Int = 0) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.createdAt = createdAt
        self.likes = likes
    }
}

// ============================================================
// MARK: - PET MATCHING MODELS
// ============================================================

// MARK: - Pet Match Request
struct PetMatchRequest: Identifiable, Codable {
    let id: String
    let requestingPetId: String
    let requestingPetName: String
    let requestingOwnerId: String
    let requestingOwnerName: String
    let targetPetId: String
    let targetPetName: String
    let targetOwnerId: String
    let status: MatchStatus
    let message: String?
    let createdAt: Date
    var respondedAt: Date?
    
    enum MatchStatus: String, Codable {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
        
        var color: Color {
            switch self {
            case .pending: return AppColors.warning
            case .accepted: return AppColors.success
            case .declined: return AppColors.error
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         requestingPetId: String,
         requestingPetName: String,
         requestingOwnerId: String,
         requestingOwnerName: String,
         targetPetId: String,
         targetPetName: String,
         targetOwnerId: String,
         status: MatchStatus = .pending,
         message: String? = nil,
         createdAt: Date = Date(),
         respondedAt: Date? = nil) {
        self.id = id
        self.requestingPetId = requestingPetId
        self.requestingPetName = requestingPetName
        self.requestingOwnerId = requestingOwnerId
        self.requestingOwnerName = requestingOwnerName
        self.targetPetId = targetPetId
        self.targetPetName = targetPetName
        self.targetOwnerId = targetOwnerId
        self.status = status
        self.message = message
        self.createdAt = createdAt
        self.respondedAt = respondedAt
    }
}

// MARK: - Pet Playdate
struct PetPlaydate: Identifiable, Codable {
    let id: String
    let pet1Id: String
    let pet1Name: String
    let owner1Id: String
    let pet2Id: String
    let pet2Name: String
    let owner2Id: String
    let scheduledDate: Date
    let location: String?
    let notes: String?
    var status: PlaydateStatus
    
    enum PlaydateStatus: String, Codable {
        case scheduled = "Scheduled"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var color: Color {
            switch self {
            case .scheduled: return AppColors.info
            case .completed: return AppColors.success
            case .cancelled: return AppColors.error
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         pet1Id: String,
         pet1Name: String,
         owner1Id: String,
         pet2Id: String,
         pet2Name: String,
         owner2Id: String,
         scheduledDate: Date,
         location: String? = nil,
         notes: String? = nil,
         status: PlaydateStatus = .scheduled) {
        self.id = id
        self.pet1Id = pet1Id
        self.pet1Name = pet1Name
        self.owner1Id = owner1Id
        self.pet2Id = pet2Id
        self.pet2Name = pet2Name
        self.owner2Id = owner2Id
        self.scheduledDate = scheduledDate
        self.location = location
        self.notes = notes
        self.status = status
    }
}

// ============================================================
// MARK: - VIRTUAL PET SIMULATOR MODELS
// ============================================================

// MARK: - Virtual Pet State
struct VirtualPetState: Codable {
    var name: String
    var type: Pet.PetType
    var happiness: Int // 0-100
    var hunger: Int // 0-100
    var energy: Int // 0-100
    var cleanliness: Int // 0-100
    var lastFed: Date?
    var lastPlayed: Date?
    var lastCleaned: Date?
    var lastSlept: Date?
    var totalInteractions: Int
    var accessories: [String]
    
    var overallHealth: Int {
        (happiness + (100 - hunger) + energy + cleanliness) / 4
    }
    
    var moodIcon: String {
        switch overallHealth {
        case 80...100: return "face.smiling.fill"
        case 60..<80: return "face.smiling"
        case 40..<60: return "minus.circle"
        case 20..<40: return "cloud"
        default: return "cloud.rain"
        }
    }
    
    var moodColor: Color {
        switch overallHealth {
        case 80...100: return AppColors.success
        case 60..<80: return AppColors.info
        case 40..<60: return AppColors.warning
        default: return AppColors.error
        }
    }
    
    init(name: String = "My Virtual Pet", type: Pet.PetType = .cat) {
        self.name = name
        self.type = type
        self.happiness = 70
        self.hunger = 30
        self.energy = 80
        self.cleanliness = 90
        self.lastFed = nil
        self.lastPlayed = nil
        self.lastCleaned = nil
        self.lastSlept = nil
        self.totalInteractions = 0
        self.accessories = []
    }
    
    mutating func feed() {
        hunger = max(0, hunger - 30)
        happiness = min(100, happiness + 10)
        lastFed = Date()
        totalInteractions += 1
    }
    
    mutating func play() {
        happiness = min(100, happiness + 25)
        energy = max(0, energy - 20)
        hunger = min(100, hunger + 10)
        lastPlayed = Date()
        totalInteractions += 1
    }
    
    mutating func clean() {
        cleanliness = min(100, cleanliness + 40)
        happiness = min(100, happiness + 5)
        lastCleaned = Date()
        totalInteractions += 1
    }
    
    mutating func sleep() {
        energy = min(100, energy + 50)
        hunger = min(100, hunger + 15)
        lastSlept = Date()
        totalInteractions += 1
    }
    
    mutating func updatePassiveStats() {
        // Decay stats over time
        let currentTime = Date()
        
        // Hunger increases over time
        if let lastFed = lastFed {
            let hoursSinceFed = currentTime.timeIntervalSince(lastFed) / 3600
            hunger = min(100, hunger + Int(hoursSinceFed * 2))
        }
        
        // Energy decreases if played recently
        if let lastPlayed = lastPlayed {
            let hoursSincePlayed = currentTime.timeIntervalSince(lastPlayed) / 3600
            if hoursSincePlayed > 2 {
                energy = max(0, energy - Int((hoursSincePlayed - 2) * 3))
            }
        }
        
        // Cleanliness decreases over time
        if let lastCleaned = lastCleaned {
            let hoursSinceCleaned = currentTime.timeIntervalSince(lastCleaned) / 3600
            cleanliness = max(0, cleanliness - Int(hoursSinceCleaned * 1.5))
        }
        
        // Happiness affected by other stats
        if hunger > 70 || energy < 30 || cleanliness < 40 {
            happiness = max(0, happiness - 5)
        }
    }
}

// MARK: - Virtual Pet Accessory
struct VirtualPetAccessory: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let category: AccessoryCategory
    let pointsCost: Int
    var isOwned: Bool
    
    enum AccessoryCategory: String, Codable, CaseIterable {
        case hat = "Hat"
        case collar = "Collar"
        case toy = "Toy"
        case bed = "Bed"
        case bowl = "Bowl"
        
        var icon: String {
            switch self {
            case .hat: return "crown.fill"
            case .collar: return "circle.dashed"
            case .toy: return "tennisball.fill"
            case .bed: return "bed.double.fill"
            case .bowl: return "cup.and.saucer.fill"
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         icon: String,
         category: AccessoryCategory,
         pointsCost: Int,
         isOwned: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.category = category
        self.pointsCost = pointsCost
        self.isOwned = isOwned
    }
}

// ============================================================
// MARK: - AR FEATURE MODELS
// ============================================================

// MARK: - AR Photo Filter
struct ARPhotoFilter: Identifiable {
    let id: String
    let name: String
    let icon: String
    let overlayImage: String?
    let category: FilterCategory
    
    enum FilterCategory: String, CaseIterable {
        case cute = "Cute"
        case funny = "Funny"
        case seasonal = "Seasonal"
        case frames = "Frames"
        
        var icon: String {
            switch self {
            case .cute: return "heart.fill"
            case .funny: return "face.smiling.fill"
            case .seasonal: return "leaf.fill"
            case .frames: return "rectangle.on.rectangle"
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         icon: String,
         overlayImage: String? = nil,
         category: FilterCategory) {
        self.id = id
        self.name = name
        self.icon = icon
        self.overlayImage = overlayImage
        self.category = category
    }
}

// MARK: - AR Pet Preview
struct ARPetPreview: Identifiable, Codable {
    let id: String
    let petId: String
    let petName: String
    let petType: Pet.PetType
    let modelName: String
    var scale: Float
    var rotation: Float
    
    init(id: String = UUID().uuidString,
         petId: String,
         petName: String,
         petType: Pet.PetType,
         modelName: String,
         scale: Float = 1.0,
         rotation: Float = 0.0) {
        self.id = id
        self.petId = petId
        self.petName = petName
        self.petType = petType
        self.modelName = modelName
        self.scale = scale
        self.rotation = rotation
    }
}

// ============================================================
// MARK: - LIVE TRACKING MODELS
// ============================================================

// MARK: - Pet Activity
struct PetActivity: Identifiable, Codable {
    let id: String
    let petId: String
    let petName: String
    let activityType: ActivityType
    let timestamp: Date
    let location: String?
    let notes: String?
    let mediaURL: String?
    
    enum ActivityType: String, Codable, CaseIterable {
        case feeding = "Feeding"
        case playing = "Playing"
        case resting = "Resting"
        case grooming = "Grooming"
        case walking = "Walking"
        case socializing = "Socializing"
        
        var icon: String {
            switch self {
            case .feeding: return "fork.knife"
            case .playing: return "figure.run"
            case .resting: return "moon.zzz.fill"
            case .grooming: return "shower.fill"
            case .walking: return "figure.walk"
            case .socializing: return "person.2.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .feeding: return AppColors.primary600
            case .playing: return AppColors.success
            case .resting: return AppColors.info
            case .grooming: return AppColors.primary
            case .walking: return AppColors.warning
            case .socializing: return AppColors.primary700
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         petId: String,
         petName: String,
         activityType: ActivityType,
         timestamp: Date = Date(),
         location: String? = nil,
         notes: String? = nil,
         mediaURL: String? = nil) {
        self.id = id
        self.petId = petId
        self.petName = petName
        self.activityType = activityType
        self.timestamp = timestamp
        self.location = location
        self.notes = notes
        self.mediaURL = mediaURL
    }
}

// MARK: - Pet Location Update
struct PetLocationUpdate: Identifiable, Codable {
    let id: String
    let petId: String
    let area: String
    let timestamp: Date
    let status: String
    
    init(id: String = UUID().uuidString,
         petId: String,
         area: String,
         timestamp: Date = Date(),
         status: String = "Active") {
        self.id = id
        self.petId = petId
        self.area = area
        self.timestamp = timestamp
        self.status = status
    }
}
