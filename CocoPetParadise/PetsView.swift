//
//  PetsView.swift
//  CocoPetParadise
//
//  Pet gallery with filtering, detailed views, photo gallery, video playback,
//  and user pet creation functionality
//

import SwiftUI
import AVKit
import AVFoundation
import PhotosUI

struct PetsView: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @State private var selectedFilter: PetFilter = .all
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var animateDecorations = false
    @State private var showAddPet = false
    
    enum PetFilter: String, CaseIterable {
        case all = "All"
        case myPets = "My Pets"
        case cats = "Cats"
        case dogs = "Dogs"
        case residents = "Residents"
        case boarding = "Boarding"
    }
    
    var filteredPets: [Pet] {
        var pets: [Pet]
        
        switch selectedFilter {
        case .all:
            pets = petDataManager.allPets
        case .myPets:
            pets = petDataManager.userPets
        case .cats:
            pets = petDataManager.cats
        case .dogs:
            pets = petDataManager.dogs
        case .residents:
            pets = petDataManager.residentPets
        case .boarding:
            pets = petDataManager.boardingPets
        }
        
        if showFavoritesOnly {
            pets = pets.filter { $0.isFavorite }
        }
        
        if !searchText.isEmpty {
            pets = pets.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.breed.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return pets
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Decorations
                VStack {
                    HStack(alignment: .top) {
                        DecorationImage(name: "current-pets-left", fallbackIcon: "cat.fill")
                            .frame(width: 130, height: 130)
                            .opacity(animateDecorations ? 0.7 : 0)
                            .rotationEffect(.degrees(animateDecorations ? -10 : 0))
                            .offset(x: 15, y: 0)
                        
                        Spacer()
                        
                        DecorationImage(name: "current-pets-right", fallbackIcon: "dog.fill")
                            .frame(width: 125, height: 125)
                            .opacity(animateDecorations ? 0.7 : 0)
                            .rotationEffect(.degrees(animateDecorations ? 10 : 0))
                            .offset(x: -15, y: 5)
                    }
                    Spacer()
                }
                .padding(.top, 0)
                
                // Main content
                VStack(spacing: 0) {
                    Spacer().frame(height: 16)
                    
                    // Search bar
                    PetSearchBar(text: $searchText, placeholder: "Search pets...")
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            PetFilterChip(
                                title: "Favorites",
                                icon: "heart.fill",
                                isSelected: showFavoritesOnly
                            ) {
                                showFavoritesOnly.toggle()
                            }
                            
                            Divider().frame(height: 24)
                            
                            ForEach(PetFilter.allCases, id: \.self) { filter in
                                PetFilterChip(
                                    title: filter.rawValue,
                                    icon: iconForFilter(filter),
                                    isSelected: selectedFilter == filter && !showFavoritesOnly,
                                    badge: filter == .myPets ? petDataManager.userPets.count : nil
                                ) {
                                    selectedFilter = filter
                                    showFavoritesOnly = false
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
                    // Pet count & Add button
                    HStack {
                        Text("\(filteredPets.count) \(filteredPets.count == 1 ? "pet" : "pets")")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Button(action: { showAddPet = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 14))
                                Text("Add My Pet")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppColors.primary700)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Pet grid
                    if filteredPets.isEmpty {
                        if selectedFilter == .myPets {
                            EmptyMyPetsView(showAddPet: $showAddPet)
                        } else {
                            EmptyPetsView()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredPets) { pet in
                                    NavigationLink(destination: PetDetailView(pet: pet)) {
                                        PetGridCard(pet: pet)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Our Pets")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddPet) {
                AddPetView()
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    animateDecorations = true
                }
            }
        }
    }
    
    func iconForFilter(_ filter: PetFilter) -> String {
        switch filter {
        case .all: return "pawprint.fill"
        case .myPets: return "person.crop.circle"
        case .cats: return "cat.fill"
        case .dogs: return "dog.fill"
        case .residents: return "house.fill"
        case .boarding: return "bed.double.fill"
        }
    }
}

// MARK: - Pet Search Bar (renamed to avoid conflicts)
struct PetSearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textTertiary)
            
            TextField(placeholder, text: $text)
                .font(AppFonts.bodyMedium)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppShadows.soft, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Pet Filter Chip (renamed to avoid conflicts)
struct PetFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var badge: Int? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(AppFonts.bodySmall)
                
                if let badge = badge, badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? AppColors.primary700 : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white : AppColors.primary600)
                        .cornerRadius(8)
                }
            }
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.primary700 : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Pet Grid Card
struct PetGridCard: View {
    let pet: Pet
    @EnvironmentObject var petDataManager: PetDataManager
    @State private var showHeartAnimation = false
    
    var isUserPet: Bool {
        petDataManager.isUserPet(pet)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                // Image
                if isUserPet, let image = petDataManager.loadUserPetImage(named: pet.image) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .cornerRadius(16)
                } else if UIImage(named: pet.image) != nil {
                    Image(pet.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [AppColors.primary200, AppColors.primary100], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .aspectRatio(1, contentMode: .fit)
                    
                    Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primary400)
                }
                
                // Heart animation
                if showHeartAnimation {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Overlay controls
                VStack {
                    HStack {
                        if isUserPet {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10))
                                Text("My Pet")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.info.opacity(0.9))
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            petDataManager.toggleFavorite(pet: pet)
                            HapticManager.impact(.light)
                            
                            if !pet.isFavorite {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    showHeartAnimation = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation { showHeartAnimation = false }
                                }
                            }
                        }) {
                            Image(systemName: pet.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(pet.isFavorite ? .red : .white)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(pet.status.color)
                                .frame(width: 6, height: 6)
                            Text(pet.status.displayName)
                                .font(AppFonts.captionSmall)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                        
                        Spacer()
                        
                        if pet.video != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 8))
                                Image(systemName: "video.fill")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(AppColors.primary700.opacity(0.9))
                            .clipShape(Capsule())
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 10))
                            Text("\(pet.images.count)")
                                .font(AppFonts.captionSmall)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                    }
                }
                .padding(8)
            }
            
            // Pet info
            VStack(alignment: .leading, spacing: 6) {
                Text(pet.name)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(pet.breed)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    ForEach(pet.personality.prefix(2), id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.primary700)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.primary100)
                            .cornerRadius(4)
                    }
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Empty Views
struct EmptyPetsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "pawprint.circle")
                .font(.system(size: 60))
                .foregroundColor(AppColors.neutral300)
            Text("No pets found")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            Text("Try adjusting your filters or search terms")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(40)
    }
}

struct EmptyMyPetsView: View {
    @Binding var showAddPet: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 120, height: 120)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary400)
            }
            
            Text("No pets yet")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Add your furry friends to keep track of them and easily book their stays!")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showAddPet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add My First Pet")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AppColors.primary700)
                .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Add Pet View
struct AddPetView: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var petName = ""
    @State private var petBreed = ""
    @State private var petAge = ""
    @State private var petType: Pet.PetType = .cat
    @State private var selectedPersonalities: Set<String> = []
    @State private var customPersonality = ""
    @State private var selectedActivities: Set<String> = []
    @State private var customActivity = ""
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var selectedVideoURL: URL?
    
    @State private var isLoading = false
    @State private var showValidationError = false
    @State private var validationMessage = ""
    
    let personalityOptions = ["Playful", "Calm", "Energetic", "Gentle", "Curious", "Affectionate", "Independent", "Friendly", "Shy", "Loyal", "Smart", "Mischievous", "Sweet", "Active", "Relaxed"]
    
    let activityOptions = ["Playing with toys", "Cuddling", "Running", "Napping", "Exploring", "Treats", "Being brushed", "Window watching", "Fetch", "Swimming", "Walks", "Training", "Climbing"]
    
    var isValid: Bool {
        !petName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !petBreed.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedImages.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    photoSection
                    videoSection
                    basicInfoSection
                    personalitySection
                    activitiesSection
                    saveButton
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Add My Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .onChange(of: selectedPhotos) { oldValue, newValue in
                Task {
                    for item in newValue {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run { selectedImages.append(image) }
                        }
                    }
                    await MainActor.run { selectedPhotos = [] }
                }
            }
            .onChange(of: selectedVideoItem) { oldValue, newValue in
                Task {
                    if let item = newValue,
                       let movie = try? await item.loadTransferable(type: VideoTransferable.self) {
                        await MainActor.run { selectedVideoURL = movie.url }
                    }
                }
            }
            .alert("Missing Information", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("*").foregroundColor(AppColors.error)
                Spacer()
                Text("\(selectedImages.count)/10")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10 - selectedImages.count, matching: .images) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(AppColors.primary600)
                            Text("Add Photos")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(width: 100, height: 100)
                        .background(AppColors.primary50)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primary300, style: StrokeStyle(lineWidth: 2, dash: [5])))
                    }
                    
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(12)
                            
                            if index == 0 {
                                Text("Main")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.primary700)
                                    .cornerRadius(4)
                                    .offset(x: -4, y: 4)
                            }
                            
                            Button(action: { selectedImages.remove(at: index) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .offset(x: 6, y: -6)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Text("First photo will be the main profile picture")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Video Section
    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Video")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("(Optional)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
            
            if selectedVideoURL != nil {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "video.fill")
                            .foregroundColor(AppColors.primary700)
                        Text("Video selected")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                    Button(action: {
                        selectedVideoURL = nil
                        selectedVideoItem = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.error)
                    }
                }
                .padding()
                .background(AppColors.primary50)
                .cornerRadius(12)
            } else {
                PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
                    HStack(spacing: 8) {
                        Image(systemName: "video.badge.plus")
                            .font(.system(size: 20))
                        Text("Add Video")
                            .font(AppFonts.bodyMedium)
                    }
                    .foregroundColor(AppColors.primary700)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary50)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primary300, style: StrokeStyle(lineWidth: 2, dash: [5])))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Info")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            // Pet Type
            VStack(alignment: .leading, spacing: 8) {
                Text("Pet Type")
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 12) {
                    AddPetTypeSelector(type: .cat, isSelected: petType == .cat) { petType = .cat }
                    AddPetTypeSelector(type: .dog, isSelected: petType == .dog) { petType = .dog }
                }
            }
            
            // Name
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Name")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    Text("*").foregroundColor(AppColors.error)
                }
                TextField("Enter pet's name", text: $petName)
                    .font(AppFonts.bodyMedium)
                    .padding()
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(12)
            }
            
            // Breed
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Breed")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    Text("*").foregroundColor(AppColors.error)
                }
                TextField("Enter breed", text: $petBreed)
                    .font(AppFonts.bodyMedium)
                    .padding()
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(12)
            }
            
            // Age
            VStack(alignment: .leading, spacing: 8) {
                Text("Age (Optional)")
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                TextField("e.g., 2 years, 6 months", text: $petAge)
                    .font(AppFonts.bodyMedium)
                    .padding()
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Personality Section
    private var personalitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personality")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            PetFlowLayout(spacing: 8) {
                ForEach(personalityOptions, id: \.self) { trait in
                    PetSelectableChip(text: trait, isSelected: selectedPersonalities.contains(trait)) {
                        if selectedPersonalities.contains(trait) {
                            selectedPersonalities.remove(trait)
                        } else {
                            selectedPersonalities.insert(trait)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Add custom trait", text: $customPersonality)
                    .font(AppFonts.bodySmall)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(20)
                
                if !customPersonality.isEmpty {
                    Button(action: {
                        selectedPersonalities.insert(customPersonality)
                        customPersonality = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.primary700)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Activities Section
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Activities")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            PetFlowLayout(spacing: 8) {
                ForEach(activityOptions, id: \.self) { activity in
                    PetSelectableChip(text: activity, isSelected: selectedActivities.contains(activity)) {
                        if selectedActivities.contains(activity) {
                            selectedActivities.remove(activity)
                        } else {
                            selectedActivities.insert(activity)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Add custom activity", text: $customActivity)
                    .font(AppFonts.bodySmall)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(20)
                
                if !customActivity.isEmpty {
                    Button(action: {
                        selectedActivities.insert(customActivity)
                        customActivity = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.primary700)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: savePet) {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Pet")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValid ? AppColors.primary700 : AppColors.neutral400)
            .cornerRadius(14)
        }
        .disabled(!isValid || isLoading)
        .padding(.top, 8)
    }
    
    private func savePet() {
        guard isValid else {
            if petName.isEmpty { validationMessage = "Please enter your pet's name" }
            else if petBreed.isEmpty { validationMessage = "Please enter your pet's breed" }
            else if selectedImages.isEmpty { validationMessage = "Please add at least one photo" }
            showValidationError = true
            return
        }
        
        isLoading = true
        
        let petId = UUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let joinedDate = dateFormatter.string(from: Date())
        
        var imageNames: [String] = []
        for (index, image) in selectedImages.enumerated() {
            let imageName = petDataManager.saveUserPetImage(image, petId: petId, imageIndex: index)
            imageNames.append(imageName)
        }
        
        var videoName: String? = nil
        if let videoURL = selectedVideoURL {
            videoName = petDataManager.saveUserPetVideo(videoURL, petId: petId)
        }
        
        let pet = Pet(
            id: petId,
            name: petName.trimmingCharacters(in: .whitespaces),
            type: petType,
            breed: petBreed.trimmingCharacters(in: .whitespaces),
            age: petAge.isEmpty ? nil : petAge,
            status: .myPet,
            personality: Array(selectedPersonalities),
            favoriteActivities: Array(selectedActivities),
            image: imageNames.first ?? "",
            images: imageNames,
            video: videoName,
            joinedDate: joinedDate,
            isUserPet: true
        )
        
        petDataManager.addUserPet(pet)
        HapticManager.notification(.success)
        isLoading = false
        dismiss()
    }
}

// MARK: - Video Transferable
struct VideoTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let fileManager = FileManager.default
            let tempDirectory = fileManager.temporaryDirectory
            let fileName = "\(UUID().uuidString).mp4"
            let destinationURL = tempDirectory.appendingPathComponent(fileName)
            try fileManager.copyItem(at: received.file, to: destinationURL)
            return Self(url: destinationURL)
        }
    }
}

// MARK: - Add Pet Type Selector (renamed to avoid conflict with existing PetTypeButton)
struct AddPetTypeSelector: View {
    let type: Pet.PetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                Text(type.displayName)
                    .font(AppFonts.bodyMedium)
            }
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? AppColors.primary700 : AppColors.backgroundSecondary)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? AppColors.primary700 : AppColors.border, lineWidth: 1))
        }
    }
}

// MARK: - Pet Selectable Chip (renamed to avoid conflicts)
struct PetSelectableChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(AppFonts.bodySmall)
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.primary700 : AppColors.backgroundSecondary)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1))
        }
    }
}

// MARK: - Pet Detail View
struct PetDetailView: View {
    let pet: Pet
    @EnvironmentObject var petDataManager: PetDataManager
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false
    @State private var selectedImageIndex = 0
    @State private var showFullscreenGallery = false
    @State private var showVideoPlayer = false
    @State private var showDeleteConfirmation = false
    
    var isUserPet: Bool {
        petDataManager.isUserPet(pet)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Image Gallery Header
                ZStack(alignment: .top) {
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(pet.images.enumerated()), id: \.offset) { index, imageName in
                            ZStack {
                                if isUserPet, let image = petDataManager.loadUserPetImage(named: imageName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                } else if UIImage(named: imageName) != nil {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                } else {
                                    LinearGradient(colors: [AppColors.primary300, AppColors.primary200], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(AppColors.primary400.opacity(0.8))
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 350)
                    
                    // Top controls
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        if isUserPet {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                Text("My Pet")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppColors.info)
                            .cornerRadius(20)
                        }
                        
                        Button(action: {
                            petDataManager.toggleFavorite(pet: pet)
                            HapticManager.notification(.success)
                        }) {
                            Image(systemName: pet.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(pet.isFavorite ? .red : .white)
                                .padding(12)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        if isUserPet {
                            Menu {
                                Button(action: { showShareSheet = true }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                Divider()
                                Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                                    Label("Delete Pet", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        } else {
                            Button(action: { showShareSheet = true }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    .padding(.top, 40)
                    
                    // Bottom controls
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            HStack(spacing: 4) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 12))
                                Text("\(selectedImageIndex + 1)/\(pet.images.count)")
                                    .font(AppFonts.bodySmall)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(20)
                            
                            Spacer()
                            
                            if pet.video != nil {
                                Button(action: { showVideoPlayer = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Watch Video")
                                            .font(AppFonts.bodySmall)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(AppColors.primary700)
                                    .cornerRadius(20)
                                }
                            }
                            
                            Button(action: { showFullscreenGallery = true }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                    }
                }
                
                // Thumbnail strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(pet.images.enumerated()), id: \.offset) { index, imageName in
                            Button(action: { withAnimation { selectedImageIndex = index } }) {
                                ZStack {
                                    if isUserPet, let image = petDataManager.loadUserPetImage(named: imageName) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                            .cornerRadius(10)
                                    } else if UIImage(named: imageName) != nil {
                                        Image(imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                            .cornerRadius(10)
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppColors.primary200)
                                            .frame(width: 60, height: 60)
                                        Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.primary400)
                                    }
                                }
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedImageIndex == index ? AppColors.primary700 : Color.clear, lineWidth: 2))
                            }
                        }
                        
                        if pet.video != nil {
                            Button(action: { showVideoPlayer = true }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: [AppColors.primary700, AppColors.primary600], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 80, height: 60)
                                    
                                    VStack(spacing: 4) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.9))
                                                .frame(width: 28, height: 28)
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColors.primary700)
                                                .offset(x: 1)
                                        }
                                        Text("Video")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                // Pet info
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pet.name)
                                .font(AppFonts.largeTitle)
                                .foregroundColor(AppColors.textPrimary)
                            Text(pet.breed)
                                .font(AppFonts.bodyLarge)
                                .foregroundColor(AppColors.textSecondary)
                            if let age = pet.age {
                                Text(age)
                                    .font(AppFonts.bodySmall)
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(pet.status.color)
                                .frame(width: 8, height: 8)
                            Text(pet.status.displayName)
                                .font(AppFonts.bodySmall)
                                .foregroundColor(pet.status.color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(pet.status.color.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    // Media summary
                    HStack(spacing: 16) {
                        PetMediaBadge(icon: "photo.stack", text: "\(pet.images.count) Photos")
                        if pet.video != nil {
                            PetMediaBadge(icon: "video.fill", text: "1 Video", isHighlighted: true)
                        }
                    }
                    
                    // Personality
                    if !pet.personality.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Personality")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            PetFlowLayout(spacing: 8) {
                                ForEach(pet.personality, id: \.self) { trait in
                                    PetPersonalityTag(trait: trait)
                                }
                            }
                        }
                    }
                    
                    // Favorite Activities
                    if !pet.favoriteActivities.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Favorite Activities")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(pet.favoriteActivities, id: \.self) { activity in
                                    HStack(spacing: 12) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppColors.warning)
                                        Text(activity)
                                            .font(AppFonts.bodyMedium)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Joined date
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(AppColors.textTertiary)
                        Text("Joined \(formatDate(pet.joinedDate))")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textTertiary)
                    }
                    
                    // Delete button for user pets
                    if isUserPet {
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Pet")
                            }
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.error)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            }
            .padding(.bottom, 100)
        }
        .navigationBarHidden(true)
        .background(AppColors.backgroundSecondary)
        .sheet(isPresented: $showShareSheet) {
            PetShareSheet(items: ["Check out \(pet.name) at Coco's Pet Paradise! 🐾"])
        }
        .fullScreenCover(isPresented: $showFullscreenGallery) {
            PetFullscreenGalleryView(pet: pet, selectedIndex: selectedImageIndex)
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            PetVideoPlayerView(pet: pet)
        }
        .alert("Delete Pet", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                petDataManager.deleteUserPet(id: pet.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \(pet.name)? This action cannot be undone.")
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM yyyy"
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Pet Media Badge (renamed)
struct PetMediaBadge: View {
    let icon: String
    let text: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(AppFonts.bodySmall)
        }
        .foregroundColor(isHighlighted ? AppColors.primary700 : AppColors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHighlighted ? AppColors.primary100 : AppColors.neutral100)
        .cornerRadius(20)
    }
}

// MARK: - Pet Personality Tag (renamed)
struct PetPersonalityTag: View {
    let trait: String
    
    var body: some View {
        Text(trait)
            .font(AppFonts.bodySmall)
            .foregroundColor(AppColors.primary700)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppColors.primary100)
            .cornerRadius(20)
    }
}

// MARK: - Pet Fullscreen Gallery View (renamed)
struct PetFullscreenGalleryView: View {
    let pet: Pet
    @State var selectedIndex: Int
    @EnvironmentObject var petDataManager: PetDataManager
    @Environment(\.dismiss) var dismiss
    
    var isUserPet: Bool {
        petDataManager.isUserPet(pet)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedIndex) {
                ForEach(Array(pet.images.enumerated()), id: \.offset) { index, imageName in
                    ZStack {
                        if isUserPet, let image = petDataManager.loadUserPetImage(named: imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 100))
                                .foregroundColor(AppColors.primary400)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                Spacer()
                
                VStack(spacing: 8) {
                    Text(pet.name)
                        .font(AppFonts.title2)
                        .foregroundColor(.white)
                    Text("\(selectedIndex + 1) of \(pet.images.count)")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Pet Video Player View (renamed)
struct PetVideoPlayerView: View {
    let pet: Pet
    @EnvironmentObject var petDataManager: PetDataManager
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var isUserPet: Bool {
        petDataManager.isUserPet(pet)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(AppColors.primary500)
                    Text("Loading video...")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                VStack(spacing: 24) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.neutral400)
                    Text("Video Not Found")
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                    if let error = errorMessage {
                        Text(error)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppColors.primary700)
                            .cornerRadius(20)
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        player?.pause()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 60)
                }
                Spacer()
            }
        }
        .onAppear { loadVideo() }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func loadVideo() {
        guard let videoName = pet.video else {
            errorMessage = "No video specified for \(pet.name)"
            isLoading = false
            return
        }
        
        var url: URL?
        
        if isUserPet {
            url = petDataManager.getUserPetVideoURL(named: videoName)
        } else {
            url = findVideoURL(videoName: videoName, petName: pet.name)
        }
        
        guard let videoURL = url else {
            errorMessage = "Video '\(videoName)' not found"
            isLoading = false
            return
        }
        
        let avPlayer = AVPlayer(url: videoURL)
        player = avPlayer
        isLoading = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            avPlayer.play()
        }
    }
    
    private func findVideoURL(videoName: String, petName: String) -> URL? {
        let name = videoName
            .replacingOccurrences(of: ".mp4", with: "")
            .replacingOccurrences(of: ".mov", with: "")
            .replacingOccurrences(of: ".m4v", with: "")
        
        let extensions = ["mp4", "mov", "m4v", "MP4", "MOV", "M4V"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) { return url }
        }
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: name) { return url }
        }
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: petName) { return url }
        }
        
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                while let file = enumerator.nextObject() as? String {
                    let fileName = (file as NSString).lastPathComponent.lowercased()
                    let searchName = name.lowercased()
                    if fileName.hasPrefix(searchName) && (fileName.hasSuffix(".mp4") || fileName.hasSuffix(".mov") || fileName.hasSuffix(".m4v")) {
                        return URL(fileURLWithPath: resourcePath).appendingPathComponent(file)
                    }
                }
            }
        }
        
        return nil
    }
}

// MARK: - Pet Flow Layout (renamed to avoid conflicts)
struct PetFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, containerWidth: proposal.width ?? 0).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, containerWidth: bounds.width).offsets
        
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }
    
    private func layout(sizes: [CGSize], containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var offsets: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for size in sizes {
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            offsets.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX)
        }
        
        return (offsets, CGSize(width: maxWidth, height: currentY + lineHeight))
    }
}

// MARK: - Pet Share Sheet (renamed)
struct PetShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct PetsView_Previews: PreviewProvider {
    static var previews: some View {
        PetsView()
            .environmentObject(PetDataManager())
    }
}
