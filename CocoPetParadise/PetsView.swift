//
//  PetsView.swift
//  CocoPetParadise
//
//  Pet gallery with filtering, detailed views, photo gallery, video playback,
//  and user pet creation functionality - Enhanced UI/UX
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
    @State private var animateContent = false
    
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
                // Background
                AppColors.backgroundSecondary
                    .ignoresSafeArea()
                
                // Decorations - PRESERVED EXACTLY AS ORIGINAL
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
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 10)
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            PetFilterChip(
                                title: "Favorites",
                                icon: "heart.fill",
                                isSelected: showFavoritesOnly
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showFavoritesOnly.toggle()
                                }
                                HapticManager.impact(.light)
                            }
                            
                            Rectangle()
                                .fill(AppColors.neutral200)
                                .frame(width: 1, height: 24)
                                .padding(.horizontal, 4)
                            
                            ForEach(PetFilter.allCases, id: \.self) { filter in
                                PetFilterChip(
                                    title: filter.rawValue,
                                    icon: iconForFilter(filter),
                                    isSelected: selectedFilter == filter && !showFavoritesOnly,
                                    badge: filter == .myPets ? petDataManager.userPets.count : nil
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedFilter = filter
                                        showFavoritesOnly = false
                                    }
                                    HapticManager.impact(.light)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 14)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 10)
                    
                    // Pet count & Add button
                    HStack(alignment: .center) {
                        HStack(spacing: 6) {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.primary500)
                            Text("\(filteredPets.count) \(filteredPets.count == 1 ? "pet" : "pets")")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showAddPet = true
                            HapticManager.impact(.medium)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Add Pet")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.primary600, AppColors.primary700],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: AppColors.primary700.opacity(0.25), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(PetScaleButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 10)
                    
                    // Pet grid
                    if filteredPets.isEmpty {
                        if selectedFilter == .myPets {
                            EmptyMyPetsView(showAddPet: $showAddPet)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else {
                            EmptyPetsView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 14),
                                    GridItem(.flexible(), spacing: 14)
                                ],
                                spacing: 16
                            ) {
                                ForEach(Array(filteredPets.enumerated()), id: \.element.id) { index, pet in
                                    NavigationLink(destination: PetDetailView(pet: pet)) {
                                        PetGridCard(pet: pet)
                                            .opacity(animateContent ? 1 : 0)
                                            .offset(y: animateContent ? 0 : 20)
                                            .animation(
                                                .spring(response: 0.4, dampingFraction: 0.75)
                                                .delay(Double(index) * 0.04),
                                                value: animateContent
                                            )
                                    }
                                    .buttonStyle(PetCardButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 120)
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .navigationTitle("Our Pets")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddPet) {
                AddPetView()
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    animateDecorations = true
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                    animateContent = true
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

// MARK: - Button Styles
struct PetScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PetCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Pet Search Bar
struct PetSearchBar: View {
    @Binding var text: String
    let placeholder: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isFocused ? AppColors.primary600 : AppColors.textTertiary)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textPrimary)
                .focused($isFocused)
            
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
                .stroke(isFocused ? AppColors.primary400 : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Pet Filter Chip
struct PetFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var badge: Int? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                
                if let badge = badge, badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? AppColors.primary700 : .white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white : AppColors.primary500)
                        )
                }
            }
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [AppColors.primary600, AppColors.primary700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.neutral200, lineWidth: 1)
            )
            .shadow(
                color: isSelected ? AppColors.primary700.opacity(0.2) : Color.black.opacity(0.03),
                radius: isSelected ? 6 : 4,
                x: 0,
                y: isSelected ? 3 : 2
            )
        }
        .buttonStyle(PetScaleButtonStyle())
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
            // Image container
            ZStack {
                // Pet Image
                Group {
                    if isUserPet, let image = petDataManager.loadUserPetImage(named: pet.image) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if UIImage(named: pet.image) != nil {
                        Image(pet.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        LinearGradient(
                            colors: [AppColors.primary100, AppColors.primary200],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay(
                            Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.primary400)
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                
                // Heart animation
                if showHeartAnimation {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.4), radius: 10)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Gradient overlay for better text visibility
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                }
                
                // Overlay controls
                VStack {
                    HStack(alignment: .top) {
                        if isUserPet {
                            HStack(spacing: 3) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 8, weight: .semibold))
                                Text("My Pet")
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(AppColors.info)
                            )
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
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(pet.isFavorite ? .red : .white)
                                .frame(width: 30, height: 30)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.25))
                                        .blur(radius: 0.5)
                                )
                        }
                        .buttonStyle(PetScaleButtonStyle())
                    }
                    
                    Spacer()
                    
                    HStack {
                        // Status badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(pet.status.color)
                                .frame(width: 5, height: 5)
                            Text(pet.status.displayName)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.35))
                        )
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            if pet.video != nil {
                                HStack(spacing: 3) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 7))
                                    Image(systemName: "video.fill")
                                        .font(.system(size: 9))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppColors.primary600)
                                )
                            }
                            
                            HStack(spacing: 3) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 9))
                                Text("\(pet.images.count)")
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.35))
                            )
                        }
                    }
                }
                .padding(10)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // Pet info
            VStack(alignment: .leading, spacing: 6) {
                Text(pet.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(pet.breed)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
                if !pet.personality.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(pet.personality.prefix(2), id: \.self) { trait in
                            Text(trait)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(AppColors.primary700)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(AppColors.primary50)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Empty Views
struct EmptyPetsView: View {
    @State private var animatePulse = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.neutral100)
                    .frame(width: 100, height: 100)
                    .scaleEffect(animatePulse ? 1.1 : 1)
                    .opacity(animatePulse ? 0.5 : 0.8)
                
                Image(systemName: "pawprint.circle")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(AppColors.neutral400)
            }
            
            VStack(spacing: 8) {
                Text("No pets found")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Try adjusting your filters or search terms")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(40)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
        }
    }
}

struct EmptyMyPetsView: View {
    @Binding var showAddPet: Bool
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
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary500)
            }
            
            VStack(spacing: 10) {
                Text("No pets yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Add your furry friends to keep track of them\nand easily book their stays!")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            
            Button(action: {
                showAddPet = true
                HapticManager.impact(.medium)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Add My First Pet")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
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
            .buttonStyle(PetScaleButtonStyle())
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                animateIcon = true
            }
        }
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
    @State private var animateContent = false
    
    @FocusState private var focusedField: AddPetField?
    
    enum AddPetField {
        case name, breed, age, customPersonality, customActivity
    }
    
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
                VStack(spacing: 20) {
                    photoSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                    
                    videoSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.35).delay(0.05), value: animateContent)
                    
                    basicInfoSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.35).delay(0.1), value: animateContent)
                    
                    personalitySection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.35).delay(0.15), value: animateContent)
                    
                    activitiesSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.35).delay(0.2), value: animateContent)
                    
                    saveButton
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.35).delay(0.25), value: animateContent)
                }
                .padding(16)
                .padding(.bottom, 40)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Add My Pet")
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
                        focusedField = nil
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.primary600)
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
            .onAppear {
                withAnimation(.easeOut(duration: 0.35)) {
                    animateContent = true
                }
            }
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        AddPetFormCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primary600)
                        Text("Photos")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("*")
                            .foregroundColor(AppColors.error)
                    }
                    Spacer()
                    Text("\(selectedImages.count)/10")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppColors.neutral100)
                        .cornerRadius(8)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: 10 - selectedImages.count,
                            matching: .images
                        ) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary100)
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.primary600)
                                }
                                Text("Add")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .frame(width: 90, height: 90)
                            .background(AppColors.primary50)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.primary300, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            )
                        }
                        
                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 90)
                                    .clipped()
                                    .cornerRadius(12)
                                
                                if index == 0 {
                                    Text("Main")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(AppColors.primary600)
                                        )
                                        .offset(x: -4, y: 4)
                                }
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.25)) {
                                        selectedImages.remove(at: index)
                                    }
                                    HapticManager.impact(.light)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2)
                                }
                                .offset(x: 6, y: -6)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                Text("First photo will be the main profile picture")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }
    
    // MARK: - Video Section
    private var videoSection: some View {
        AddPetFormCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.primary600)
                        Text("Video")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Text("(Optional)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                }
                
                if selectedVideoURL != nil {
                    HStack {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.success.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.success)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Video selected")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Ready to upload")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.25)) {
                                selectedVideoURL = nil
                                selectedVideoItem = nil
                            }
                            HapticManager.impact(.light)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.neutral400)
                        }
                    }
                    .padding(12)
                    .background(AppColors.success.opacity(0.08))
                    .cornerRadius(12)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
                        HStack(spacing: 8) {
                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 18))
                            Text("Add Video")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(AppColors.primary600)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primary50)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.primary300, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        AddPetFormCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary600)
                    Text("Basic Info")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                // Pet Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pet Type")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: 10) {
                        AddPetTypeSelector(
                            type: .cat,
                            isSelected: petType == .cat
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                petType = .cat
                            }
                            HapticManager.impact(.light)
                        }
                        
                        AddPetTypeSelector(
                            type: .dog,
                            isSelected: petType == .dog
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                petType = .dog
                            }
                            HapticManager.impact(.light)
                        }
                    }
                }
                
                // Name
                AddPetTextField(
                    title: "Name",
                    placeholder: "Enter pet's name",
                    text: $petName,
                    isRequired: true,
                    icon: "pawprint.fill"
                )
                .focused($focusedField, equals: .name)
                
                // Breed
                AddPetTextField(
                    title: "Breed",
                    placeholder: "Enter breed",
                    text: $petBreed,
                    isRequired: true,
                    icon: "tag.fill"
                )
                .focused($focusedField, equals: .breed)
                
                // Age
                AddPetTextField(
                    title: "Age",
                    placeholder: "e.g., 2 years, 6 months",
                    text: $petAge,
                    isRequired: false,
                    icon: "calendar"
                )
                .focused($focusedField, equals: .age)
            }
        }
    }
    
    // MARK: - Personality Section
    private var personalitySection: some View {
        AddPetFormCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary600)
                    Text("Personality")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                PetFlowLayout(spacing: 8) {
                    ForEach(personalityOptions, id: \.self) { trait in
                        PetSelectableChip(
                            text: trait,
                            isSelected: selectedPersonalities.contains(trait)
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if selectedPersonalities.contains(trait) {
                                    selectedPersonalities.remove(trait)
                                } else {
                                    selectedPersonalities.insert(trait)
                                }
                            }
                            HapticManager.impact(.light)
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    TextField("Add custom trait", text: $customPersonality)
                        .font(.system(size: 13))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.neutral50)
                        .cornerRadius(20)
                        .focused($focusedField, equals: .customPersonality)
                    
                    if !customPersonality.isEmpty {
                        Button(action: {
                            withAnimation(.spring(response: 0.25)) {
                                selectedPersonalities.insert(customPersonality)
                                customPersonality = ""
                            }
                            HapticManager.impact(.light)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary600)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }
    
    // MARK: - Activities Section
    private var activitiesSection: some View {
        AddPetFormCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.warning)
                    Text("Favorite Activities")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                PetFlowLayout(spacing: 8) {
                    ForEach(activityOptions, id: \.self) { activity in
                        PetSelectableChip(
                            text: activity,
                            isSelected: selectedActivities.contains(activity)
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if selectedActivities.contains(activity) {
                                    selectedActivities.remove(activity)
                                } else {
                                    selectedActivities.insert(activity)
                                }
                            }
                            HapticManager.impact(.light)
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    TextField("Add custom activity", text: $customActivity)
                        .font(.system(size: 13))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.neutral50)
                        .cornerRadius(20)
                        .focused($focusedField, equals: .customActivity)
                    
                    if !customActivity.isEmpty {
                        Button(action: {
                            withAnimation(.spring(response: 0.25)) {
                                selectedActivities.insert(customActivity)
                                customActivity = ""
                            }
                            HapticManager.impact(.light)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary600)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: savePet) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Save Pet")
                        .font(.system(size: 16, weight: .semibold))
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
        .disabled(!isValid || isLoading)
        .buttonStyle(PetScaleButtonStyle())
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
        HapticManager.impact(.medium)
        
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

// MARK: - Add Pet Form Card
struct AddPetFormCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(16)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Add Pet Text Field
struct AddPetTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool = false
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                if isRequired {
                    Text("*")
                        .foregroundColor(AppColors.error)
                }
            }
            
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.neutral400)
                }
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppColors.neutral50)
            .cornerRadius(10)
        }
    }
}

// MARK: - Add Pet Type Selector
struct AddPetTypeSelector: View {
    let type: Pet.PetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 18))
                Text(type.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [AppColors.primary600, AppColors.primary700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color(AppColors.neutral50)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : AppColors.neutral200, lineWidth: 1)
            )
            .shadow(
                color: isSelected ? AppColors.primary700.opacity(0.2) : Color.clear,
                radius: 6,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(PetScaleButtonStyle())
    }
}

// MARK: - Pet Selectable Chip
struct PetSelectableChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [AppColors.primary600, AppColors.primary700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color(AppColors.neutral50)
                        }
                    }
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : AppColors.neutral200, lineWidth: 1)
                )
        }
        .buttonStyle(PetScaleButtonStyle())
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
    @State private var animateContent = false
    
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
                                    LinearGradient(
                                        colors: [AppColors.primary200, AppColors.primary300],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                        .font(.system(size: 70))
                                        .foregroundColor(AppColors.primary400.opacity(0.8))
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 380)
                    
                    // Gradient overlays
                    VStack {
                        LinearGradient(
                            colors: [.black.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        
                        Spacer()
                        
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    }
                    
                    // Top controls
                    HStack(spacing: 10) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .blur(radius: 0.5)
                                )
                        }
                        .buttonStyle(PetScaleButtonStyle())
                        
                        Spacer()
                        
                        if isUserPet {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("My Pet")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppColors.info)
                            )
                        }
                        
                        Button(action: {
                            petDataManager.toggleFavorite(pet: pet)
                            HapticManager.notification(.success)
                        }) {
                            Image(systemName: pet.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(pet.isFavorite ? .red : .white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .blur(radius: 0.5)
                                )
                        }
                        .buttonStyle(PetScaleButtonStyle())
                        
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
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .blur(radius: 0.5)
                                    )
                            }
                        } else {
                            Button(action: { showShareSheet = true }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .blur(radius: 0.5)
                                    )
                            }
                            .buttonStyle(PetScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 56)
                    
                    // Bottom controls
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            HStack(spacing: 4) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 11))
                                Text("\(selectedImageIndex + 1)/\(pet.images.count)")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.4))
                            )
                            
                            Spacer()
                            
                            if pet.video != nil {
                                Button(action: { showVideoPlayer = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Watch Video")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(AppColors.primary600)
                                    )
                                }
                                .buttonStyle(PetScaleButtonStyle())
                            }
                            
                            Button(action: { showFullscreenGallery = true }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                                    .frame(width: 34, height: 34)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.4))
                                    )
                            }
                            .buttonStyle(PetScaleButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                
                // Thumbnail strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(pet.images.enumerated()), id: \.offset) { index, imageName in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedImageIndex = index
                                }
                                HapticManager.impact(.light)
                            }) {
                                ZStack {
                                    if isUserPet, let image = petDataManager.loadUserPetImage(named: imageName) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 56, height: 56)
                                            .clipped()
                                            .cornerRadius(10)
                                    } else if UIImage(named: imageName) != nil {
                                        Image(imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 56, height: 56)
                                            .clipped()
                                            .cornerRadius(10)
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppColors.primary200)
                                            .frame(width: 56, height: 56)
                                        Image(systemName: pet.type == .cat ? "cat.fill" : "dog.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(AppColors.primary400)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            selectedImageIndex == index ? AppColors.primary600 : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .scaleEffect(selectedImageIndex == index ? 1.05 : 1)
                            }
                            .buttonStyle(PetScaleButtonStyle())
                        }
                        
                        if pet.video != nil {
                            Button(action: { showVideoPlayer = true }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.primary600, AppColors.primary700],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 72, height: 56)
                                    
                                    VStack(spacing: 3) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 26, height: 26)
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppColors.primary700)
                                                .offset(x: 1)
                                        }
                                        Text("Video")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(PetScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                // Pet info
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pet.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text(pet.breed)
                                .font(.system(size: 15))
                                .foregroundColor(AppColors.textSecondary)
                            if let age = pet.age {
                                Text(age)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(x: animateContent ? 0 : -10)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(pet.status.color)
                                .frame(width: 7, height: 7)
                            Text(pet.status.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(pet.status.color)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(pet.status.color.opacity(0.12))
                        .cornerRadius(16)
                        .opacity(animateContent ? 1 : 0)
                        .offset(x: animateContent ? 0 : 10)
                    }
                    
                    // Media summary
                    HStack(spacing: 12) {
                        PetMediaBadge(icon: "photo.stack", text: "\(pet.images.count) Photos")
                        if pet.video != nil {
                            PetMediaBadge(icon: "video.fill", text: "1 Video", isHighlighted: true)
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 10)
                    
                    // Personality
                    if !pet.personality.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.primary600)
                                Text("Personality")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            PetFlowLayout(spacing: 8) {
                                ForEach(pet.personality, id: \.self) { trait in
                                    PetPersonalityTag(trait: trait)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 10)
                    }
                    
                    // Favorite Activities
                    if !pet.favoriteActivities.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.warning)
                                Text("Favorite Activities")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(pet.favoriteActivities, id: \.self) { activity in
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(AppColors.warning.opacity(0.2))
                                            .frame(width: 6, height: 6)
                                        Text(activity)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 10)
                    }
                    
                    // Joined date
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textTertiary)
                        Text("Joined \(formatDate(pet.joinedDate))")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .opacity(animateContent ? 1 : 0)
                    
                    // Delete button for user pets
                    if isUserPet {
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                Text("Delete Pet")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(AppColors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.error.opacity(0.08))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PetScaleButtonStyle())
                        .opacity(animateContent ? 1 : 0)
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                animateContent = true
            }
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

// MARK: - Pet Media Badge
struct PetMediaBadge: View {
    let icon: String
    let text: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(isHighlighted ? AppColors.primary700 : AppColors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(isHighlighted ? AppColors.primary100 : AppColors.neutral100)
        .cornerRadius(16)
    }
}

// MARK: - Pet Personality Tag
struct PetPersonalityTag: View {
    let trait: String
    
    var body: some View {
        Text(trait)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(AppColors.primary700)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(AppColors.primary50)
            .cornerRadius(14)
    }
}

// MARK: - Pet Fullscreen Gallery View
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
                                .font(.system(size: 80))
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
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                Spacer()
                
                VStack(spacing: 6) {
                    Text(pet.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(selectedIndex + 1) of \(pet.images.count)")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Pet Video Player View
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
                        .scaleEffect(1.3)
                        .tint(AppColors.primary500)
                    Text("Loading video...")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppColors.neutral800)
                            .frame(width: 80, height: 80)
                        Image(systemName: "video.slash")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.neutral500)
                    }
                    
                    VStack(spacing: 6) {
                        Text("Video Not Found")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(AppColors.primary600)
                            .cornerRadius(20)
                    }
                    .buttonStyle(PetScaleButtonStyle())
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
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 4)
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

// MARK: - Pet Flow Layout
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

// MARK: - Pet Share Sheet
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
