//
//  BookingView_Enhanced.swift
//  CocoPetParadise
//
//  Premium Booking calendar and form with refined UI/UX
//

import SwiftUI

// MARK: - Pet Size Options
enum DogSize: String, CaseIterable {
    case small = "Small"
    case large = "Large"
    
    var weightLabel: String {
        switch self {
        case .small: return "Under 30 lbs"
        case .large: return "Over 30 lbs"
        }
    }
    
    var icon: String {
        return "dog.fill"
    }
}

// MARK: - Pet Count Options
enum PetCount: Int, CaseIterable {
    case one = 1
    case two = 2
    
    var label: String {
        switch self {
        case .one: return "1"
        case .two: return "2"
        }
    }
}

// MARK: - Pricing Calculator
struct PricingCalculator {
    static func calculateNightlyRate(petType: Pet.PetType, dogSize: DogSize, petCount: PetCount) -> Double {
        if petType == .cat {
            return petCount == .one ? 25.0 : 40.0
        } else {
            if petCount == .one {
                return dogSize == .small ? 40.0 : 60.0
            } else {
                return dogSize == .small ? 70.0 : 110.0
            }
        }
    }
    
    static func calculateTotal(petType: Pet.PetType, dogSize: DogSize, petCount: PetCount, nights: Int) -> Double {
        let nightlyRate = calculateNightlyRate(petType: petType, dogSize: dogSize, petCount: petCount)
        let subtotal = nightlyRate * Double(nights)
        let tax = subtotal * 0.0625
        return subtotal + tax
    }
    
    static func getPackagePrice(petType: Pet.PetType, dogSize: DogSize, petCount: PetCount, nights: Int) -> Double? {
        if petType == .cat && petCount == .one {
            if nights >= 60 { return 1400.0 * 1.0625 }
            if nights >= 30 { return 700.0 * 1.0625 }
        }
        if petType == .dog && petCount == .one {
            if nights >= 30 {
                return (dogSize == .small ? 1000.0 : 1500.0) * 1.0625
            }
        }
        return nil
    }
}

// MARK: - Main Booking View
struct BookingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var currentMonth = Date()
    @State private var selectedStartDate: Date?
    @State private var selectedEndDate: Date?
    @State private var showBookingForm = false
    @State private var selectedPetType: Pet.PetType = .cat
    @State private var selectedDogSize: DogSize = .small
    @State private var selectedPetCount: PetCount = .one
    @State private var animateContent = false
    @State private var showPricingGuide = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header info card
                    BookingInfoCard()
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 12)
                        .animation(.easeOut(duration: 0.35).delay(0.05), value: animateContent)
                    
                    // Pet configuration
                    PetConfigurationCard(
                        selectedPetType: $selectedPetType,
                        selectedDogSize: $selectedDogSize,
                        selectedPetCount: $selectedPetCount
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 12)
                    .animation(.easeOut(duration: 0.35).delay(0.1), value: animateContent)
                    
                    // Calendar
                    BookingCalendarCard(
                        currentMonth: $currentMonth,
                        selectedStartDate: $selectedStartDate,
                        selectedEndDate: $selectedEndDate
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 12)
                    .animation(.easeOut(duration: 0.35).delay(0.15), value: animateContent)
                    
                    // Selection summary
                    if selectedStartDate != nil || selectedEndDate != nil {
                        BookingSelectionCard(
                            startDate: selectedStartDate,
                            endDate: selectedEndDate,
                            petType: selectedPetType,
                            dogSize: selectedDogSize,
                            petCount: selectedPetCount,
                            onBook: {
                                HapticManager.impact(.medium)
                                showBookingForm = true
                            },
                            onClear: {
                                HapticManager.impact(.light)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedStartDate = nil
                                    selectedEndDate = nil
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .scale(scale: 0.98))
                        ))
                    }
                    
                    // Pricing guide
                    PricingGuideCard()
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.35).delay(0.2), value: animateContent)
                    
                    // Upcoming bookings
                    if !bookingManager.upcomingBookings.isEmpty {
                        UpcomingBookingsCard()
                            .opacity(animateContent ? 1 : 0)
                            .animation(.easeOut(duration: 0.35).delay(0.25), value: animateContent)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 100)
            }
            .background(AppColors.background)
            .navigationTitle("Book a Stay")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showBookingForm) {
                BookingFormSheet(
                    startDate: selectedStartDate ?? Date(),
                    endDate: selectedEndDate ?? Date(),
                    petType: selectedPetType,
                    dogSize: selectedDogSize,
                    petCount: selectedPetCount
                ) { booking in
                    bookingManager.addBooking(booking)
                    notificationManager.scheduleBookingReminder(booking: booking)
                    notificationManager.addNotification(
                        AppNotification(
                            title: "Booking Confirmed! 🎉",
                            body: "Your booking for \(booking.petName) has been confirmed.",
                            type: .booking
                        )
                    )
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedStartDate = nil
                        selectedEndDate = nil
                    }
                    showBookingForm = false
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                animateContent = true
            }
        }
    }
}

// MARK: - Booking Info Card
struct BookingInfoCard: View {
    @State private var showDecorations = false
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.primary50)
            
            // SVG Decorations
            VStack {
                HStack(alignment: .top) {
                    DecorationImage(name: "booking-decoration", fallbackIcon: "calendar.badge.clock")
                        .frame(width: 80, height: 80)
                        .opacity(showDecorations ? 0.6 : 0)
                        .rotationEffect(.degrees(showDecorations ? -5 : -15))
                        .offset(x: -8, y: showDecorations ? 60 : 70)
                    
                    Spacer()
                    
                    DecorationImage(name: "booking-decoration2", fallbackIcon: "pawprint.fill")
                        .frame(width: 120, height: 120)
                        .opacity(showDecorations ? 0.55 : 0)
                        .rotationEffect(.degrees(showDecorations ? 5 : 15))
                        .offset(x: 8, y: showDecorations ? 60 : 70)
                }
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.primary600)
                    
                    Text("How to Book")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    StepRow(number: 1, text: "Select your check-in date")
                    StepRow(number: 2, text: "Select your check-out date")
                    StepRow(number: 3, text: "Fill in the booking form")
                    StepRow(number: 4, text: "We'll confirm within 24 hours")
                }
            }
            .padding(16)
            .padding(.top, 8)
        }
        .frame(height: 180)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15)) {
                showDecorations = true
            }
        }
    }
}

struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text("\(number)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(AppColors.primary600)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Pet Configuration Card
struct PetConfigurationCard: View {
    @Binding var selectedPetType: Pet.PetType
    @Binding var selectedDogSize: DogSize
    @Binding var selectedPetCount: PetCount
    
    var nightlyRate: Double {
        PricingCalculator.calculateNightlyRate(petType: selectedPetType, dogSize: selectedDogSize, petCount: selectedPetCount)
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Pet Type
            ConfigSection(title: "Pet Type") {
                HStack(spacing: 10) {
                    ConfigOptionButton(
                        icon: "cat.fill",
                        title: "Cat",
                        isSelected: selectedPetType == .cat
                    ) {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedPetType = .cat
                        }
                    }
                    
                    ConfigOptionButton(
                        icon: "dog.fill",
                        title: "Dog",
                        isSelected: selectedPetType == .dog
                    ) {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedPetType = .dog
                        }
                    }
                }
            }
            
            // Dog Size (conditional)
            if selectedPetType == .dog {
                ConfigSection(title: "Size") {
                    HStack(spacing: 10) {
                        SizeOptionButton(
                            title: "Small",
                            subtitle: "Under 30 lbs",
                            isSelected: selectedDogSize == .small
                        ) {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                selectedDogSize = .small
                            }
                        }
                        
                        SizeOptionButton(
                            title: "Large",
                            subtitle: "Over 30 lbs",
                            isSelected: selectedDogSize == .large
                        ) {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                selectedDogSize = .large
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Pet Count
            ConfigSection(title: "Number of Pets") {
                HStack(spacing: 10) {
                    CountOptionButton(
                        count: 1,
                        petType: selectedPetType,
                        isSelected: selectedPetCount == .one
                    ) {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedPetCount = .one
                        }
                    }
                    
                    CountOptionButton(
                        count: 2,
                        petType: selectedPetType,
                        isSelected: selectedPetCount == .two
                    ) {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedPetCount = .two
                        }
                    }
                }
            }
            
            // Rate display
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Rate")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text(rateDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("$\(Int(nightlyRate))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary700)
                    
                    Text("/night")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .padding(12)
            .background(AppColors.primary50)
            .cornerRadius(10)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }
    
    var rateDescription: String {
        if selectedPetType == .cat {
            return selectedPetCount == .one ? "1 Cat" : "2 Cats"
        } else {
            let size = selectedDogSize == .small ? "Small" : "Large"
            return selectedPetCount == .one ? "1 \(size) Dog" : "2 \(size) Dogs"
        }
    }
}

struct ConfigSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            content
        }
    }
}

struct ConfigOptionButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppColors.primary600 : AppColors.neutral50)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.clear : AppColors.neutral200, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SizeOptionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppColors.primary600 : AppColors.neutral50)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.clear : AppColors.neutral200, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct CountOptionButton: View {
    let count: Int
    let petType: Pet.PetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text("\(count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                Text(petType == .cat ? (count == 1 ? "Cat" : "Cats") : (count == 1 ? "Dog" : "Dogs"))
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppColors.primary600 : AppColors.neutral50)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.clear : AppColors.neutral200, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Calendar Card
struct BookingCalendarCard: View {
    @Binding var currentMonth: Date
    @Binding var selectedStartDate: Date?
    @Binding var selectedEndDate: Date?
    @EnvironmentObject var bookingManager: BookingManager
    
    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 14) {
            // Month header
            HStack {
                Button(action: {
                    HapticManager.impact(.light)
                    changeMonth(-1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(AppColors.neutral100)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    HapticManager.impact(.light)
                    changeMonth(1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(AppColors.neutral100)
                        .clipShape(Circle())
                }
            }
            
            // Weekday header
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid
            let days = generateDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 4) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day = day {
                        DayCell(
                            date: day,
                            isSelected: isDateSelected(day),
                            isInRange: isInRange(day),
                            isRangeStart: isRangeStart(day),
                            isRangeEnd: isRangeEnd(day),
                            isToday: calendar.isDateInToday(day),
                            availability: bookingManager.getAvailability(for: day)
                        ) {
                            selectDate(day)
                        }
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                LegendDot(color: AppColors.success, text: "Available")
                LegendDot(color: AppColors.warning, text: "Limited")
                LegendDot(color: AppColors.error, text: "Full")
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    func changeMonth(_ value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentMonth = newMonth
            }
        }
    }
    
    func generateDays() -> [Date?] {
        var days: [Date?] = []
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        
        for _ in 0..<firstWeekday { days.append(nil) }
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    func isDateSelected(_ date: Date) -> Bool {
        if let start = selectedStartDate, calendar.isDate(date, inSameDayAs: start) { return true }
        if let end = selectedEndDate, calendar.isDate(date, inSameDayAs: end) { return true }
        return false
    }
    
    func isInRange(_ date: Date) -> Bool {
        guard let start = selectedStartDate, let end = selectedEndDate else { return false }
        return date > start && date < end
    }
    
    func isRangeStart(_ date: Date) -> Bool {
        guard let start = selectedStartDate else { return false }
        return calendar.isDate(date, inSameDayAs: start)
    }
    
    func isRangeEnd(_ date: Date) -> Bool {
        guard let end = selectedEndDate else { return false }
        return calendar.isDate(date, inSameDayAs: end)
    }
    
    func selectDate(_ date: Date) {
        guard date >= calendar.startOfDay(for: Date()) else { return }
        guard let avail = bookingManager.getAvailability(for: date), !avail.isFull else { return }
        
        HapticManager.impact(.light)
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if selectedStartDate == nil {
                selectedStartDate = date
            } else if selectedEndDate == nil {
                if date > selectedStartDate! {
                    selectedEndDate = date
                } else {
                    selectedStartDate = date
                }
            } else {
                selectedStartDate = date
                selectedEndDate = nil
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isInRange: Bool
    let isRangeStart: Bool
    let isRangeEnd: Bool
    let isToday: Bool
    let availability: DateAvailability?
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var isPast: Bool {
        date < calendar.startOfDay(for: Date())
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Range background
                if isInRange || isRangeStart || isRangeEnd {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(isRangeStart ? Color.clear : AppColors.primary100)
                        Rectangle()
                            .fill(isRangeEnd ? Color.clear : AppColors.primary100)
                    }
                }
                
                // Day circle
                Circle()
                    .fill(isSelected ? AppColors.primary600 : Color.clear)
                    .frame(width: 36, height: 36)
                
                // Today ring
                if isToday && !isSelected {
                    Circle()
                        .stroke(AppColors.primary500, lineWidth: 1.5)
                        .frame(width: 36, height: 36)
                }
                
                VStack(spacing: 1) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundColor(textColor)
                    
                    if let avail = availability, !isPast {
                        Circle()
                            .fill(avail.statusColor)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(height: 40)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isPast || (availability?.isFull ?? true))
    }
    
    var textColor: Color {
        if isPast { return AppColors.neutral300 }
        if isSelected { return .white }
        if availability?.isFull ?? false { return AppColors.neutral400 }
        return AppColors.textPrimary
    }
}

struct LegendDot: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.textTertiary)
        }
    }
}

// MARK: - Booking Selection Card
struct BookingSelectionCard: View {
    let startDate: Date?
    let endDate: Date?
    let petType: Pet.PetType
    let dogSize: DogSize
    let petCount: PetCount
    let onBook: () -> Void
    let onClear: () -> Void
    
    var nights: Int {
        guard let start = startDate, let end = endDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    var nightlyRate: Double {
        PricingCalculator.calculateNightlyRate(petType: petType, dogSize: dogSize, petCount: petCount)
    }
    
    var subtotal: Double {
        nightlyRate * Double(nights)
    }
    
    var tax: Double {
        subtotal * 0.0625
    }
    
    var regularTotal: Double {
        subtotal + tax
    }
    
    var packagePrice: Double? {
        PricingCalculator.getPackagePrice(petType: petType, dogSize: dogSize, petCount: petCount, nights: nights)
    }
    
    var finalPrice: Double {
        packagePrice ?? regularTotal
    }
    
    var savings: Double {
        guard let pkg = packagePrice else { return 0 }
        return regularTotal - pkg
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                Text("Your Selection")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: onClear) {
                    HStack(spacing: 3) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                        Text("Clear")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(AppColors.textTertiary)
                }
            }
            
            // Date selection
            HStack(spacing: 10) {
                DateSelectionBox(label: "Check-in", date: startDate)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
                
                DateSelectionBox(label: "Check-out", date: endDate)
            }
            
            // Price breakdown
            if nights > 0 {
                VStack(spacing: 8) {
                    PriceRow(label: "$\(Int(nightlyRate)) × \(nights) night\(nights > 1 ? "s" : "")", value: "$\(String(format: "%.2f", subtotal))")
                    PriceRow(label: "Tax (6.25%)", value: "$\(String(format: "%.2f", tax))")
                    
                    if packagePrice != nil {
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 10))
                                Text("Package Savings")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(AppColors.success)
                            
                            Spacer()
                            
                            Text("-$\(String(format: "%.2f", savings))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.success)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        if packagePrice != nil {
                            Text("$\(String(format: "%.2f", regularTotal))")
                                .font(.system(size: 13))
                                .strikethrough()
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.trailing, 4)
                        }
                        
                        Text("$\(String(format: "%.2f", finalPrice))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primary700)
                    }
                }
                .padding(12)
                .background(AppColors.neutral50)
                .cornerRadius(10)
            }
            
            // Book button
            Button(action: onBook) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 15))
                    Text("Continue Booking")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(endDate == nil ?
                              LinearGradient(colors: [AppColors.neutral300, AppColors.neutral400], startPoint: .leading, endPoint: .trailing) :
                              LinearGradient(colors: [AppColors.primary600, AppColors.primary700], startPoint: .leading, endPoint: .trailing))
                )
                .shadow(color: endDate == nil ? Color.clear : AppColors.primary700.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .disabled(endDate == nil)
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
    }
}

struct DateSelectionBox: View {
    let label: String
    let date: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColors.textTertiary)
            
            if let date = date {
                Text(formatDate(date))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            } else {
                Text("Select")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppColors.neutral50)
        .cornerRadius(8)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct PriceRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Pricing Guide Card
struct PricingGuideCard: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                HapticManager.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.primary600)
                    
                    Text("Pricing Guide")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(14)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(spacing: 10) {
                    Divider().padding(.horizontal, 14)
                    
                    PricingCategory(icon: "cat.fill", title: "Cat Boarding", items: [
                        ("1 Cat", "$25/night"),
                        ("2 Cats", "$40/night"),
                        ("30 Days", "$700"),
                        ("60 Days", "$1,400")
                    ])
                    
                    PricingCategory(icon: "dog.fill", title: "Dog Boarding", items: [
                        ("Small (<30 lbs)", "$40/night"),
                        ("Large (>30 lbs)", "$60/night"),
                        ("2 Small Dogs", "$70/night"),
                        ("2 Large Dogs", "$110/night")
                    ])
                    
                    PricingCategory(icon: "calendar", title: "30-Day Packages", items: [
                        ("Small Dog", "$1,000"),
                        ("Large Dog", "$1,500")
                    ])
                    
                    PricingCategory(icon: "sun.max.fill", title: "Dog Daycare (10 hrs)", items: [
                        ("Small Dog", "$25/day"),
                        ("Large Dog", "$30/day")
                    ])
                    
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.info)
                        Text("6.25% MA sales tax added to all bookings")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
        )
    }
}

struct PricingCategory: View {
    let icon: String
    let title: String
    let items: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.primary600)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            ForEach(items, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(item.1)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding(12)
        .background(AppColors.neutral50)
        .cornerRadius(10)
        .padding(.horizontal, 14)
    }
}

// MARK: - Upcoming Bookings Card
struct UpcomingBookingsCard: View {
    @EnvironmentObject var bookingManager: BookingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Bookings")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(bookingManager.upcomingBookings) { booking in
                BookingRow(booking: booking)
            }
        }
    }
}

struct BookingRow: View {
    let booking: Booking
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary100)
                    .frame(width: 44, height: 44)
                
                Image(systemName: booking.petType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primary700)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(booking.petName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(formatDate(booking.startDate)) - \(formatDate(booking.endDate))")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(booking.status.color)
                    .frame(width: 5, height: 5)
                Text(booking.status.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(booking.status.color)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(booking.status.color.opacity(0.1))
            .cornerRadius(6)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Booking Form Sheet
struct BookingFormSheet: View {
    let startDate: Date
    let endDate: Date
    let petType: Pet.PetType
    let dogSize: DogSize
    let petCount: PetCount
    let onComplete: (Booking) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var petName = ""
    @State private var petName2 = ""
    @State private var ownerName = ""
    @State private var ownerEmail = ""
    @State private var ownerPhone = ""
    @State private var specialRequests = ""
    @State private var agreedToTerms = false
    @FocusState private var focusedField: FormField?
    
    enum FormField: Hashable {
        case petName, petName2, ownerName, email, phone, requests
    }
    
    var isValid: Bool {
        let hasPetNames = !petName.isEmpty && (petCount == .one || !petName2.isEmpty)
        let hasOwnerInfo = !ownerName.isEmpty && !ownerEmail.isEmpty && ownerEmail.contains("@")
        return hasPetNames && hasOwnerInfo && agreedToTerms
    }
    
    var nights: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var totalPrice: Double {
        PricingCalculator.getPackagePrice(petType: petType, dogSize: dogSize, petCount: petCount, nights: nights) ??
        PricingCalculator.calculateTotal(petType: petType, dogSize: dogSize, petCount: petCount, nights: nights)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Summary
                    FormSummaryCard(
                        startDate: startDate,
                        endDate: endDate,
                        petType: petType,
                        dogSize: dogSize,
                        petCount: petCount,
                        nights: nights,
                        totalPrice: totalPrice
                    )
                    
                    // Pet info
                    FormSectionCard(title: "Pet Information", icon: "pawprint.fill") {
                        FormInputField(
                            label: petCount == .two ? "First Pet's Name" : "Pet's Name",
                            placeholder: "Enter name",
                            text: $petName,
                            icon: "pawprint",
                            focused: $focusedField,
                            field: .petName
                        )
                        
                        if petCount == .two {
                            FormInputField(
                                label: "Second Pet's Name",
                                placeholder: "Enter name",
                                text: $petName2,
                                icon: "pawprint",
                                focused: $focusedField,
                                field: .petName2
                            )
                        }
                        
                        // Pet summary
                        HStack(spacing: 10) {
                            Image(systemName: petType.icon)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary600)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text("\(petCount == .one ? "1" : "2") \(petType.displayName)\(petCount == .two ? "s" : "")")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                if petType == .dog {
                                    Text("\(dogSize.rawValue) (\(dogSize.weightLabel))")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(10)
                        .background(AppColors.primary50)
                        .cornerRadius(8)
                    }
                    
                    // Owner info
                    FormSectionCard(title: "Your Information", icon: "person.fill") {
                        FormInputField(
                            label: "Full Name",
                            placeholder: "Enter your name",
                            text: $ownerName,
                            icon: "person",
                            focused: $focusedField,
                            field: .ownerName
                        )
                        
                        FormInputField(
                            label: "Email",
                            placeholder: "Enter email",
                            text: $ownerEmail,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            focused: $focusedField,
                            field: .email
                        )
                        
                        FormInputField(
                            label: "Phone",
                            placeholder: "Enter phone",
                            text: $ownerPhone,
                            icon: "phone",
                            keyboardType: .phonePad,
                            focused: $focusedField,
                            field: .phone
                        )
                    }
                    
                    // Special requests
                    FormSectionCard(title: "Special Requests", icon: "text.bubble.fill") {
                        TextEditor(text: $specialRequests)
                            .font(.system(size: 14))
                            .frame(height: 80)
                            .padding(10)
                            .background(AppColors.neutral50)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.neutral200, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .requests)
                    }
                    
                    // Terms
                    Button(action: {
                        HapticManager.impact(.light)
                        agreedToTerms.toggle()
                    }) {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(agreedToTerms ? AppColors.primary600 : AppColors.neutral300, lineWidth: 1.5)
                                    .frame(width: 20, height: 20)
                                
                                if agreedToTerms {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(AppColors.primary600)
                                        .frame(width: 20, height: 20)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("I agree to the terms and conditions")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Submit
                    Button(action: submit) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Confirm Booking")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isValid ?
                                      LinearGradient(colors: [AppColors.primary600, AppColors.primary700], startPoint: .leading, endPoint: .trailing) :
                                      LinearGradient(colors: [AppColors.neutral300, AppColors.neutral400], startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: isValid ? AppColors.primary700.opacity(0.25) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isValid)
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(16)
                .padding(.bottom, 30)
            }
            .background(AppColors.background)
            .navigationTitle("Complete Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.impact(.light)
                        dismiss()
                    }
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .font(.system(size: 15, weight: .medium))
                }
            }
        }
    }
    
    func submit() {
        HapticManager.notification(.success)
        let name = petCount == .two ? "\(petName) & \(petName2)" : petName
        let booking = Booking(
            petName: name,
            petType: petType,
            ownerName: ownerName,
            ownerEmail: ownerEmail,
            ownerPhone: ownerPhone,
            startDate: startDate,
            endDate: endDate,
            specialRequests: specialRequests.isEmpty ? nil : specialRequests,
            totalPrice: totalPrice
        )
        onComplete(booking)
    }
}

struct FormSummaryCard: View {
    let startDate: Date
    let endDate: Date
    let petType: Pet.PetType
    let dogSize: DogSize
    let petCount: PetCount
    let nights: Int
    let totalPrice: Double
    
    var nightlyRate: Double {
        PricingCalculator.calculateNightlyRate(petType: petType, dogSize: dogSize, petCount: petCount)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(AppColors.primary200)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: petType.icon)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primary700)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(petType.displayName) Boarding")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(nights) night\(nights > 1 ? "s" : "")")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text("$\(String(format: "%.2f", totalPrice))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary700)
                    
                    Text("$\(Int(nightlyRate))/night")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Check-in")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                    Text(formatDate(startDate))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textTertiary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Check-out")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                    Text(formatDate(endDate))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding(14)
        .background(AppColors.primary50)
        .cornerRadius(14)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
}

struct FormSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.primary600)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            content
        }
    }
}

struct FormInputField<Field: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var focused: FocusState<Field?>.Binding
    let field: Field
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: 18)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .focused(focused, equals: field)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.neutral200, lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview
struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
            .environmentObject(BookingManager())
            .environmentObject(NotificationManager())
    }
}
