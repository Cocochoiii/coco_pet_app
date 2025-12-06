//
//  PetMatchingView.swift
//  CocoPetParadise
//
//  Pet matching and playdate scheduling features
//

import SwiftUI

struct PetMatchingView: View {
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                HStack(spacing: 0) {
                    MatchingTabButton(title: "Find Playmates", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    MatchingTabButton(title: "Requests", badge: petMatchingManager.pendingRequestsForUser(appState.currentUser?.id ?? "").count, isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    MatchingTabButton(title: "Playdates", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                TabView(selection: $selectedTab) {
                    FindPlaymatesView()
                        .tag(0)
                    
                    MatchRequestsView()
                        .tag(1)
                    
                    PlaydatesView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Pet Matching")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Matching Tab Button
struct MatchingTabButton: View {
    let title: String
    var badge: Int = 0
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(AppFonts.bodySmall)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? AppColors.primary700 : AppColors.textTertiary)
                    
                    if badge > 0 {
                        ZStack {
                            Circle()
                                .fill(AppColors.error)
                                .frame(width: 18, height: 18)
                            
                            Text("\(badge)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Rectangle()
                    .fill(isSelected ? AppColors.primary700 : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Find Playmates View
struct FindPlaymatesView: View {
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var appState: AppState
    @State private var selectedPetType: Pet.PetType? = nil
    @State private var showMatchRequest = false
    @State private var selectedPet: Pet?
    
    var filteredPets: [Pet] {
        var pets = petDataManager.allPets.filter { !$0.isUserPet }
        
        if let type = selectedPetType {
            pets = pets.filter { $0.type == type }
        }
        
        return pets
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Type filter
            HStack(spacing: 12) {
                PetTypeFilterButton(title: "All", icon: "pawprint.fill", isSelected: selectedPetType == nil) {
                    selectedPetType = nil
                }
                
                PetTypeFilterButton(title: "Cats", icon: "cat.fill", isSelected: selectedPetType == .cat) {
                    selectedPetType = .cat
                }
                
                PetTypeFilterButton(title: "Dogs", icon: "dog.fill", isSelected: selectedPetType == .dog) {
                    selectedPetType = .dog
                }
            }
            .padding()
            
            // Pets grid
            ScrollView(showsIndicators: false) {
                if petDataManager.userPets.isEmpty {
                    // Prompt to add pet first
                    VStack(spacing: 20) {
                        Spacer().frame(height: 60)
                        
                        Image(systemName: "pawprint.circle")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.neutral300)
                        
                        Text("Add Your Pet First")
                            .font(AppFonts.title3)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("To find playmates, you need to add your pet to your profile first.")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredPets) { pet in
                            PlaymatePetCard(pet: pet) {
                                selectedPet = pet
                                showMatchRequest = true
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showMatchRequest) {
            if let pet = selectedPet {
                SendMatchRequestView(targetPet: pet)
            }
        }
    }
}

// MARK: - Pet Type Filter Button
struct PetTypeFilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(AppFonts.bodySmall)
            }
            .foregroundColor(isSelected ? .white : AppColors.primary700)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.primary700 : AppColors.primary100)
            )
        }
    }
}

// MARK: - Playmate Pet Card
struct PlaymatePetCard: View {
    let pet: Pet
    let onMatch: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Pet image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary200, AppColors.primary100],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                
                Image(systemName: pet.type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primary500)
            }
            
            // Pet info
            VStack(spacing: 4) {
                Text(pet.name)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(pet.breed)
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(1)
                
                // Personality tags
                HStack(spacing: 4) {
                    ForEach(pet.personality.prefix(2), id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.primary700)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.primary100)
                            .cornerRadius(4)
                    }
                }
            }
            
            // Match button
            Button(action: onMatch) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                    Text("Match")
                        .font(AppFonts.bodySmall)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppColors.primary700)
                .cornerRadius(10)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Send Match Request View
struct SendMatchRequestView: View {
    let targetPet: Pet
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var petDataManager: PetDataManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gamificationManager: GamificationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPet: Pet?
    @State private var message = ""
    @State private var isSending = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Target pet display
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary200)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: targetPet.type.icon)
                                .font(.system(size: 36))
                                .foregroundColor(AppColors.primary700)
                        }
                        
                        Text(targetPet.name)
                            .font(AppFonts.title3)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(targetPet.breed)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.top)
                    
                    Divider()
                    
                    // Select your pet
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Your Pet")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if petDataManager.userPets.isEmpty {
                            Text("You haven't added any pets yet. Add a pet to send match requests.")
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                                .padding()
                                .background(AppColors.warning.opacity(0.1))
                                .cornerRadius(12)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(petDataManager.userPets) { pet in
                                        SelectablePetCard(pet: pet, isSelected: selectedPet?.id == pet.id) {
                                            selectedPet = pet
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message (Optional)")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextEditor(text: $message)
                            .font(AppFonts.bodyMedium)
                            .frame(height: 100)
                            .padding(12)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(12)
                        
                        Text("Introduce your pet and why you'd like them to meet!")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    // Send button
                    Button(action: sendRequest) {
                        HStack {
                            if isSending {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Send Request")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: selectedPet == nil))
                    .disabled(selectedPet == nil || isSending)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Match Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    func sendRequest() {
        guard let myPet = selectedPet else { return }
        
        isSending = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            petMatchingManager.sendMatchRequest(
                requestingPet: myPet,
                requestingOwnerId: appState.currentUser?.id ?? "guest",
                requestingOwnerName: appState.currentUser?.name ?? "Guest",
                targetPet: targetPet,
                targetOwnerId: "owner_\(targetPet.id)",
                message: message.isEmpty ? nil : message
            )
            
            gamificationManager.addPoints(10, reason: "Sent a match request")
            
            isSending = false
            HapticManager.notification(.success)
            dismiss()
        }
    }
}

// MARK: - Selectable Pet Card
struct SelectablePetCard: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primary700 : AppColors.neutral200)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: pet.type.icon)
                        .font(.system(size: 26))
                        .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.success)
                                    .background(Circle().fill(Color.white).frame(width: 16, height: 16))
                            }
                            Spacer()
                        }
                        .frame(width: 60, height: 60)
                    }
                }
                
                Text(pet.name)
                    .font(AppFonts.caption)
                    .foregroundColor(isSelected ? AppColors.primary700 : AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Match Requests View
struct MatchRequestsView: View {
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var appState: AppState
    
    var pendingRequests: [PetMatchRequest] {
        petMatchingManager.pendingRequestsForUser(appState.currentUser?.id ?? "")
    }
    
    var body: some View {
        if pendingRequests.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "tray")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.neutral300)
                
                Text("No pending requests")
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("When someone wants their pet to play with yours, you'll see it here.")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(pendingRequests) { request in
                        MatchRequestCard(request: request)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Match Request Card
struct MatchRequestCard: View {
    let request: PetMatchRequest
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @State private var showScheduler = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary200)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.primary700)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(request.requestingPetName) wants to play!")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("From \(request.requestingOwnerName)")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text(timeAgo(from: request.createdAt))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
            
            // Message
            if let message = request.message, !message.isEmpty {
                Text(message)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(12)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(12)
            }
            
            // Actions
            HStack(spacing: 12) {
                Button(action: declineRequest) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Decline")
                    }
                    .font(AppFonts.bodySmall)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.error)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.error.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button(action: { showScheduler = true }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Accept")
                    }
                    .font(AppFonts.bodySmall)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.success)
                    .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showScheduler) {
            SchedulePlaydateView(request: request)
        }
    }
    
    func declineRequest() {
        petMatchingManager.respondToRequest(requestId: request.id, accept: false)
        HapticManager.notification(.warning)
    }
    
    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

// MARK: - Schedule Playdate View
struct SchedulePlaydateView: View {
    let request: PetMatchRequest
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var gamificationManager: GamificationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate = Date()
    @State private var location = ""
    @State private var notes = ""
    @State private var isScheduling = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Playdate info
                    HStack(spacing: 20) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primary200)
                                    .frame(width: 60, height: 60)
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppColors.primary700)
                            }
                            Text(request.requestingPetName)
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.error)
                        
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primary200)
                                    .frame(width: 60, height: 60)
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppColors.primary700)
                            }
                            Text(request.targetPetName)
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .padding(.top)
                    
                    Divider()
                    
                    // Date picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Date & Time")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .tint(AppColors.primary700)
                    }
                    .padding(.horizontal)
                    
                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location (Optional)")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextField("Where will they meet?", text: $location)
                            .font(AppFonts.bodyMedium)
                            .padding(14)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextEditor(text: $notes)
                            .font(AppFonts.bodyMedium)
                            .frame(height: 80)
                            .padding(12)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    // Schedule button
                    Button(action: schedulePlaydate) {
                        HStack {
                            if isScheduling {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                Text("Schedule Playdate")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isScheduling)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Schedule Playdate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    func schedulePlaydate() {
        isScheduling = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            petMatchingManager.respondToRequest(requestId: request.id, accept: true)
            petMatchingManager.schedulePlaydate(
                request: request,
                date: selectedDate,
                location: location.isEmpty ? nil : location,
                notes: notes.isEmpty ? nil : notes
            )
            
            gamificationManager.addPoints(25, reason: "Scheduled a playdate")
            
            isScheduling = false
            HapticManager.notification(.success)
            dismiss()
        }
    }
}

// MARK: - Playdates View
struct PlaydatesView: View {
    @EnvironmentObject var petMatchingManager: PetMatchingManager
    @EnvironmentObject var appState: AppState
    
    var upcomingPlaydates: [PetPlaydate] {
        petMatchingManager.upcomingPlaydates(for: appState.currentUser?.id ?? "")
    }
    
    var body: some View {
        if upcomingPlaydates.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.neutral300)
                
                Text("No upcoming playdates")
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Accept match requests to schedule playdates for your pets.")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(upcomingPlaydates) { playdate in
                        PlaydateCard(playdate: playdate)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Playdate Card
struct PlaydateCard: View {
    let playdate: PetPlaydate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: -10) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary200)
                            .frame(width: 44, height: 44)
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary700)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(AppColors.primary300)
                            .frame(width: 44, height: 44)
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 44, height: 44)
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary700)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(playdate.pet1Name) & \(playdate.pet2Name)")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: playdate.status.rawValue == "Scheduled" ? "clock.fill" : "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text(playdate.status.rawValue)
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(playdate.status.color)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Details
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .foregroundColor(AppColors.primary700)
                        .frame(width: 20)
                    Text(playdate.scheduledDate.formatted(date: .abbreviated, time: .shortened))
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                if let location = playdate.location {
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppColors.primary700)
                            .frame(width: 20)
                        Text(location)
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                if let notes = playdate.notes {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "note.text")
                            .foregroundColor(AppColors.primary700)
                            .frame(width: 20)
                        Text(notes)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
struct PetMatchingView_Previews: PreviewProvider {
    static var previews: some View {
        PetMatchingView()
            .environmentObject(PetMatchingManager())
            .environmentObject(PetDataManager())
            .environmentObject(AppState())
            .environmentObject(GamificationManager())
    }
}
