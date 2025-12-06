//
//  VirtualTourView.swift
//  CocoPetParadise
//
//  Interactive Virtual Tour Section - iOS version with SVG decorations
//

import SwiftUI

// MARK: - Virtual Tour Section (for embedding in HomeView)
struct VirtualTourSection: View {
    @State private var currentRoom = 0
    @State private var selectedCategory: VirtualTourRoom.RoomCategory = .all
    @State private var isAutoPlaying = false
    @State private var showFullscreen = false
    @State private var animateDecorations = false
    
    let timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()
    
    var filteredRooms: [VirtualTourRoom] {
        if selectedCategory == .all {
            return SampleData.virtualTourRooms
        }
        return SampleData.virtualTourRooms.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ZStack {
            // Large corner decorations - positioned at top corners
            VStack {
                HStack(alignment: .top) {
                    DecorationImage(name: "tour-decoration-left", fallbackIcon: "dog.fill")
                        .frame(width: 110, height: 110)
                        .opacity(animateDecorations ? 0.85 : 0)
                        .rotationEffect(.degrees(animateDecorations ? -10 : 0))
                        .offset(x: -20, y: -20)
                    
                    Spacer()
                    
                    DecorationImage(name: "tour-decoration-right", fallbackIcon: "cat.fill")
                        .frame(width: 100, height: 100)
                        .opacity(animateDecorations ? 0.85 : 0)
                        .rotationEffect(.degrees(animateDecorations ? 10 : 0))
                        .offset(x: 20, y: -15)
                }
                Spacer()
            }
            
            // Main content
            VStack(spacing: 20) {
                // Header text
                VStack(spacing: 8) {
                    Text("VIRTUAL EXPERIENCE")
                        .font(AppFonts.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary700)
                        .tracking(1.5)
                    
                    Text("Tour Our Pet Paradise")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppColors.primary)
                        Text("Wellesley Hills, MA")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.top, 50) // Space for decorations
            
            // Category Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(VirtualTourRoom.RoomCategory.allCases, id: \.self) { category in
                        CategoryPill(
                            category: category,
                            isSelected: selectedCategory == category,
                            count: category == .all ? SampleData.virtualTourRooms.count : SampleData.virtualTourRooms.filter { $0.category == category }.count
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedCategory = category
                                currentRoom = 0
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Main Carousel Card
            VStack(spacing: 0) {
                // Image Area
                ZStack {
                    // Room Image - Try actual image first, fallback to placeholder
                    if let room = filteredRooms[safe: currentRoom],
                       UIImage(named: room.image) != nil {
                        Image(room.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(16)
                    } else {
                        // Placeholder gradient background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary200, AppColors.primary100],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200)
                        
                        // Room icon placeholder
                        VStack(spacing: 12) {
                            Image(systemName: iconForRoom(filteredRooms[safe: currentRoom]?.name ?? ""))
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.primary400)
                            
                            Text(filteredRooms[safe: currentRoom]?.name ?? "")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.primary700)
                        }
                    }
                    
                    // Navigation overlay
                    HStack {
                        // Previous button
                        Button(action: previousRoom) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Next button
                        Button(action: nextRoom) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    // Room counter
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(currentRoom + 1)/\(filteredRooms.count)")
                                .font(AppFonts.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(20)
                        }
                        Spacer()
                    }
                    .padding(12)
                }
                .frame(height: 200)
                .cornerRadius(16, corners: [.topLeft, .topRight])
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                nextRoom()
                            } else if value.translation.width > 50 {
                                previousRoom()
                            }
                        }
                )
                
                // Info Area
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(filteredRooms[safe: currentRoom]?.name ?? "Room")
                                .font(AppFonts.title3)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(filteredRooms[safe: currentRoom]?.description ?? "")
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Category badge
                        if let category = filteredRooms[safe: currentRoom]?.category {
                            HStack(spacing: 4) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 10))
                                Text(category.displayName)
                                    .font(AppFonts.captionSmall)
                            }
                            .foregroundColor(category.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(category.color.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Features
                    if let features = filteredRooms[safe: currentRoom]?.features {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(features, id: \.self) { feature in
                                    Text(feature)
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppColors.backgroundSecondary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: { isAutoPlaying.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: isAutoPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 12))
                                Text(isAutoPlaying ? "Pause" : "Auto Play")
                                    .font(AppFonts.bodySmall)
                            }
                            .foregroundColor(isAutoPlaying ? .white : AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(isAutoPlaying ? AppColors.primary700 : AppColors.backgroundSecondary)
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: VirtualTourFullView()) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 12))
                                Text("Full Tour")
                                    .font(AppFonts.bodySmall)
                            }
                            .foregroundColor(AppColors.primary700)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(AppColors.primary100)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [AppColors.primary50, Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: AppShadows.soft, radius: 12, x: 0, y: 4)
            .padding(.horizontal)
            
            // Thumbnail Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(filteredRooms.enumerated()), id: \.element.id) { index, room in
                        ThumbnailButton(
                            room: room,
                            isSelected: index == currentRoom
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentRoom = index
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Progress Dots
            HStack(spacing: 6) {
                ForEach(0..<filteredRooms.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentRoom ? AppColors.primary700 : AppColors.neutral300)
                        .frame(width: index == currentRoom ? 20 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.2), value: currentRoom)
                }
            }
            .padding(.bottom, 8)
            }
        }
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [Color.white, AppColors.primary50, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateDecorations = true
            }
        }
        .onReceive(timer) { _ in
            if isAutoPlaying {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentRoom = (currentRoom + 1) % filteredRooms.count
                }
            }
        }
    }
    
    private func nextRoom() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoom = (currentRoom + 1) % filteredRooms.count
        }
        HapticManager.impact(.light)
    }
    
    private func previousRoom() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoom = (currentRoom - 1 + filteredRooms.count) % filteredRooms.count
        }
        HapticManager.impact(.light)
    }
    
    private func iconForRoom(_ name: String) -> String {
        switch name.lowercased() {
        case let n where n.contains("entrance"): return "door.left.hand.open"
        case let n where n.contains("living"): return "sofa.fill"
        case let n where n.contains("cat suite"): return "cat.fill"
        case let n where n.contains("cat play"): return "figure.play"
        case let n where n.contains("dog suite"): return "dog.fill"
        case let n where n.contains("dog activity"): return "figure.run"
        case let n where n.contains("kitchen"): return "fork.knife"
        case let n where n.contains("garden"): return "leaf.fill"
        case let n where n.contains("spa"): return "sparkles"
        case let n where n.contains("rest"): return "bed.double.fill"
        default: return "house.fill"
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let category: VirtualTourRoom.RoomCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                Text(category.displayName)
                    .font(AppFonts.bodySmall)
                Text("(\(count))")
                    .font(AppFonts.captionSmall)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.textTertiary)
            }
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.primary700 : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.primary200, lineWidth: 1)
            )
            .shadow(color: isSelected ? AppColors.primary.opacity(0.3) : AppShadows.soft, radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
    }
}

// MARK: - Thumbnail Button
struct ThumbnailButton: View {
    let room: VirtualTourRoom
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if UIImage(named: room.image) != nil {
                        Image(room.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 50)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary200, AppColors.primary100],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 50)
                        
                        Image(systemName: room.category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primary500)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? AppColors.primary700 : Color.clear, lineWidth: 2)
                )
                
                Text(room.name)
                    .font(.system(size: 9))
                    .foregroundColor(isSelected ? AppColors.primary700 : AppColors.textTertiary)
                    .lineLimit(1)
                    .frame(width: 70)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Full Virtual Tour View
struct VirtualTourFullView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentRoom = 0
    @State private var selectedCategory: VirtualTourRoom.RoomCategory = .all
    @State private var viewMode: ViewMode = .carousel
    @State private var animateDecorations = false
    
    enum ViewMode: String, CaseIterable {
        case carousel = "Carousel"
        case grid = "Gallery"
        case stack = "Stack"
        
        var icon: String {
            switch self {
            case .carousel: return "rectangle.stack"
            case .grid: return "square.grid.3x3"
            case .stack: return "sparkles"
            }
        }
    }
    
    var filteredRooms: [VirtualTourRoom] {
        if selectedCategory == .all {
            return SampleData.virtualTourRooms
        }
        return SampleData.virtualTourRooms.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundSecondary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with decorations
                ZStack {
                    HStack {
                        DecorationImage(name: "tour-decoration-left", fallbackIcon: "dog.fill")
                            .frame(width: 50, height: 50)
                            .opacity(animateDecorations ? 0.6 : 0)
                        Spacer()
                        DecorationImage(name: "tour-decoration-right", fallbackIcon: "cat.fill")
                            .frame(width: 50, height: 50)
                            .opacity(animateDecorations ? 0.6 : 0)
                    }
                    .padding(.horizontal, 30)
                }
                
                // View Mode Selector
                HStack(spacing: 12) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Button(action: { viewMode = mode }) {
                            HStack(spacing: 6) {
                                Image(systemName: mode.icon)
                                    .font(.system(size: 12))
                                Text(mode.rawValue)
                                    .font(AppFonts.bodySmall)
                            }
                            .foregroundColor(viewMode == mode ? .white : AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(viewMode == mode ? AppColors.neutral800 : Color.white)
                            .cornerRadius(20)
                            .shadow(color: AppShadows.soft, radius: 4, x: 0, y: 2)
                        }
                    }
                }
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(VirtualTourRoom.RoomCategory.allCases, id: \.self) { category in
                            CategoryPill(
                                category: category,
                                isSelected: selectedCategory == category,
                                count: category == .all ? SampleData.virtualTourRooms.count : SampleData.virtualTourRooms.filter { $0.category == category }.count
                            ) {
                                withAnimation {
                                    selectedCategory = category
                                    currentRoom = 0
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Content based on view mode
                switch viewMode {
                case .carousel:
                    CarouselView(rooms: filteredRooms, currentRoom: $currentRoom)
                case .grid:
                    GridView(rooms: filteredRooms)
                case .stack:
                    StackView(rooms: filteredRooms, currentRoom: $currentRoom)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Virtual Tour")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateDecorations = true
            }
        }
    }
}

// MARK: - Carousel View
struct CarouselView: View {
    let rooms: [VirtualTourRoom]
    @Binding var currentRoom: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Main card
            TabView(selection: $currentRoom) {
                ForEach(Array(rooms.enumerated()), id: \.element.id) { index, room in
                    RoomCard(room: room)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 400)
            
            // Page indicators
            HStack(spacing: 6) {
                ForEach(0..<rooms.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentRoom ? AppColors.primary700 : AppColors.neutral300)
                        .frame(width: index == currentRoom ? 20 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.2), value: currentRoom)
                }
            }
        }
    }
}

// MARK: - Grid View
struct GridView: View {
    let rooms: [VirtualTourRoom]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(rooms) { room in
                    RoomGridCard(room: room)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Stack View
struct StackView: View {
    let rooms: [VirtualTourRoom]
    @Binding var currentRoom: Int
    
    var body: some View {
        ZStack {
            ForEach(Array(rooms.enumerated().reversed()), id: \.element.id) { index, room in
                let offset = (index - currentRoom)
                let isVisible = offset >= 0 && offset < 5
                
                if isVisible {
                    RoomCard(room: room)
                        .offset(y: CGFloat(offset) * 15)
                        .scaleEffect(1 - CGFloat(offset) * 0.05)
                        .opacity(1 - Double(offset) * 0.15)
                        .zIndex(Double(rooms.count - offset))
                        .onTapGesture {
                            if offset == 0 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    currentRoom = (currentRoom + 1) % rooms.count
                                }
                            }
                        }
                }
            }
        }
        .frame(height: 400)
        .padding(.horizontal)
    }
}

// MARK: - Room Card
struct RoomCard: View {
    let room: VirtualTourRoom
    
    var body: some View {
        VStack(spacing: 0) {
            // Image area
            ZStack {
                if UIImage(named: room.image) != nil {
                    Image(room.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary200, AppColors.primary100],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 220)
                    
                    VStack(spacing: 12) {
                        Image(systemName: room.category.icon)
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary400)
                        
                        Text(room.name)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.primary700)
                    }
                }
                
                // Category badge overlay
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: room.category.icon)
                                .font(.system(size: 10))
                            Text(room.category.displayName)
                                .font(AppFonts.captionSmall)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(room.category.color.opacity(0.9))
                        .cornerRadius(12)
                    }
                    Spacer()
                }
                .padding(12)
            }
            .frame(height: 220)
            .cornerRadius(16, corners: [.topLeft, .topRight])
            
            // Info area
            VStack(alignment: .leading, spacing: 12) {
                Text(room.name)
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(room.description)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                
                // Features
                HStack(spacing: 8) {
                    ForEach(room.features, id: \.self) { feature in
                        Text(feature)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: AppShadows.soft, radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Room Grid Card
struct RoomGridCard: View {
    let room: VirtualTourRoom
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if UIImage(named: room.image) != nil {
                    Image(room.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary200, AppColors.primary100],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(1, contentMode: .fit)
                    
                    VStack(spacing: 8) {
                        Image(systemName: room.category.icon)
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.primary400)
                    }
                }
                
                // Category badge
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: room.category.icon)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(room.category.color)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(AppFonts.bodySmall)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(room.description)
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 6, x: 0, y: 2)
    }
}

// MARK: - Array Safe Subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview
struct VirtualTourSection_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VirtualTourSection()
        }
    }
}
