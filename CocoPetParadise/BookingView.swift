//
//  BookingView.swift
//  CocoPetParadise
//
//  Booking calendar and form
//

import SwiftUI

struct BookingView: View {
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var currentMonth = Date()
    @State private var selectedStartDate: Date?
    @State private var selectedEndDate: Date?
    @State private var showBookingForm = false
    @State private var selectedPetType: Pet.PetType = .cat
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header info
                    BookingInfoCard()
                    
                    // Pet type selector
                    BookingPetTypeSelector(selectedType: $selectedPetType)
                    
                    // Calendar
                    BookingCalendarView(
                        currentMonth: $currentMonth,
                        selectedStartDate: $selectedStartDate,
                        selectedEndDate: $selectedEndDate
                    )
                    
                    // Availability Legend
                    AvailabilityLegend()
                    
                    // Selected dates summary
                    if selectedStartDate != nil || selectedEndDate != nil {
                        SelectedDatesSummary(
                            startDate: selectedStartDate,
                            endDate: selectedEndDate,
                            petType: selectedPetType,
                            onBook: { showBookingForm = true },
                            onClear: {
                                selectedStartDate = nil
                                selectedEndDate = nil
                            }
                        )
                    }
                    
                    // Upcoming bookings
                    if !bookingManager.upcomingBookings.isEmpty {
                        UpcomingBookingsSection()
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Book a Stay")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showBookingForm) {
                BookingFormView(
                    startDate: selectedStartDate ?? Date(),
                    endDate: selectedEndDate ?? Date(),
                    petType: selectedPetType
                ) { booking in
                    bookingManager.addBooking(booking)
                    notificationManager.scheduleBookingReminder(booking: booking)
                    notificationManager.addNotification(
                        AppNotification(
                            title: "Booking Confirmed! 🎉",
                            body: "Your booking for \(booking.petName) from \(formatDate(booking.startDate)) to \(formatDate(booking.endDate)) has been confirmed.",
                            type: .booking
                        )
                    )
                    selectedStartDate = nil
                    selectedEndDate = nil
                    showBookingForm = false
                }
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Booking Info Card with Decorations
struct BookingInfoCard: View {
    @State private var animateDecorations = false
    
    var body: some View {
        ZStack {
            // Large corner decorations
            VStack {
                HStack(alignment: .top) {
                    DecorationImage(name: "booking-decoration", fallbackIcon: "calendar.badge.clock")
                        .frame(width: 90, height: 90)
                        .opacity(animateDecorations ? 0.8 : 0)
                        .rotationEffect(.degrees(animateDecorations ? -10 : 0))
                        .offset(x: -20, y: 70)
                    
                    Spacer()
                    
                    DecorationImage(name: "booking-decoration2", fallbackIcon: "pawprint.fill")
                        .frame(width: 100, height: 100)
                        .opacity(animateDecorations ? 0.8 : 0)
                        .rotationEffect(.degrees(animateDecorations ? 10 : 0))
                        .offset(x: 10, y: 80)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primary700)
                    
                    Text("How to Book")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    BookingInfoRow(number: "1", text: "Select your check-in date")
                    BookingInfoRow(number: "2", text: "Select your check-out date")
                    BookingInfoRow(number: "3", text: "Fill in the booking form")
                    BookingInfoRow(number: "4", text: "We'll confirm within 24 hours")
                }
            }
            .padding()
            .padding(.top, 30) // Space for decorations
        }
        .background(AppColors.primary100)
        .cornerRadius(16)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateDecorations = true
            }
        }
    }
}

struct BookingInfoRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(AppFonts.bodySmall)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(AppColors.primary700)
                .clipShape(Circle())
            
            Text(text)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Booking Pet Type Selector (renamed to avoid conflicts)
struct BookingPetTypeSelector: View {
    @Binding var selectedType: Pet.PetType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet Type")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                BookingPetTypeButton(
                    type: .cat,
                    isSelected: selectedType == .cat,
                    price: "$25/night"
                ) {
                    selectedType = .cat
                }
                
                BookingPetTypeButton(
                    type: .dog,
                    isSelected: selectedType == .dog,
                    price: "$40-60/night"
                ) {
                    selectedType = .dog
                }
            }
        }
    }
}

struct BookingPetTypeButton: View {
    let type: Pet.PetType
    let isSelected: Bool
    let price: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : AppColors.primary700)
                
                Text(type.displayName)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                
                Text(price)
                    .font(AppFonts.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? AppColors.primary700 : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Booking Calendar View (renamed to avoid conflicts)
struct BookingCalendarView: View {
    @Binding var currentMonth: Date
    @Binding var selectedStartDate: Date?
    @Binding var selectedEndDate: Date?
    @EnvironmentObject var bookingManager: BookingManager
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(12)
                        .background(AppColors.neutral100)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthYearString())
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(12)
                        .background(AppColors.neutral100)
                        .clipShape(Circle())
                }
            }
            
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    if let day = day {
                        CalendarDayCell(
                            date: day,
                            isSelected: isDateSelected(day),
                            isInRange: isDateInRange(day),
                            isToday: calendar.isDateInToday(day),
                            availability: bookingManager.getAvailability(for: day)
                        ) {
                            selectDate(day)
                        }
                    } else {
                        Text("")
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
    }
    
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    func changeMonth(_ value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    func daysInMonth() -> [Date?] {
        var days: [Date?] = []
        
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        
        // Empty cells before first day
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // Days of month
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func isDateSelected(_ date: Date) -> Bool {
        if let start = selectedStartDate, calendar.isDate(date, inSameDayAs: start) {
            return true
        }
        if let end = selectedEndDate, calendar.isDate(date, inSameDayAs: end) {
            return true
        }
        return false
    }
    
    func isDateInRange(_ date: Date) -> Bool {
        guard let start = selectedStartDate, let end = selectedEndDate else { return false }
        return date > start && date < end
    }
    
    func selectDate(_ date: Date) {
        guard date >= Date() else { return }
        guard let avail = bookingManager.getAvailability(for: date), !avail.isFull else { return }
        
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

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isInRange: Bool
    let isToday: Bool
    let availability: DateAvailability?
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var isPast: Bool {
        date < calendar.startOfDay(for: Date())
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(AppFonts.bodyMedium)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(textColor)
                
                // Availability indicator
                if let avail = availability, !isPast {
                    Circle()
                        .fill(avail.statusColor)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isToday ? AppColors.primary700 : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isPast || (availability?.isFull ?? true))
    }
    
    var textColor: Color {
        if isPast {
            return AppColors.neutral300
        }
        if isSelected {
            return .white
        }
        if availability?.isFull ?? false {
            return AppColors.neutral400
        }
        return AppColors.textPrimary
    }
    
    var backgroundColor: Color {
        if isSelected {
            return AppColors.primary700
        }
        if isInRange {
            return AppColors.primary100
        }
        return Color.clear
    }
}

// MARK: - Availability Legend
struct AvailabilityLegend: View {
    var body: some View {
        HStack(spacing: 24) {
            AvailabilityLegendItem(color: AppColors.success, text: "Available")
            AvailabilityLegendItem(color: AppColors.warning, text: "Limited")
            AvailabilityLegendItem(color: AppColors.error, text: "Full")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct AvailabilityLegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Selected Dates Summary
struct SelectedDatesSummary: View {
    let startDate: Date?
    let endDate: Date?
    let petType: Pet.PetType
    let onBook: () -> Void
    let onClear: () -> Void
    
    var nights: Int {
        guard let start = startDate, let end = endDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    var estimatedPrice: Double {
        let basePrice = petType == .cat ? 25.0 : 40.0
        return basePrice * Double(nights) * 1.0625 // MA tax
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Selection")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: onClear) {
                    Text("Clear")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.error)
                }
            }
            
            // Date display
            HStack(spacing: 16) {
                DateDisplayCard(
                    label: "Check-in",
                    date: startDate,
                    icon: "arrow.right.circle"
                )
                
                Image(systemName: "arrow.right")
                    .foregroundColor(AppColors.textTertiary)
                
                DateDisplayCard(
                    label: "Check-out",
                    date: endDate,
                    icon: "arrow.left.circle"
                )
            }
            
            // Price estimate
            if nights > 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(nights) night\(nights > 1 ? "s" : "")")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Estimated total (incl. tax)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Text("$\(estimatedPrice, specifier: "%.2f")")
                        .font(AppFonts.title2)
                        .foregroundColor(AppColors.primary700)
                }
                .padding()
                .background(AppColors.primary100)
                .cornerRadius(12)
            }
            
            // Book button
            Button(action: onBook) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Continue Booking")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(isDisabled: endDate == nil))
            .disabled(endDate == nil)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppShadows.soft, radius: 8, x: 0, y: 2)
    }
}

struct DateDisplayCard: View {
    let label: String
    let date: Date?
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
            
            if let date = date {
                Text(formatDate(date))
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
            } else {
                Text("Select date")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.backgroundSecondary)
        .cornerRadius(12)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Upcoming Bookings Section
struct UpcomingBookingsSection: View {
    @EnvironmentObject var bookingManager: BookingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Upcoming Bookings")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(bookingManager.upcomingBookings) { booking in
                UpcomingBookingCard(booking: booking)
            }
        }
    }
}

struct UpcomingBookingCard: View {
    let booking: Booking
    
    var body: some View {
        HStack(spacing: 16) {
            // Pet type icon
            Image(systemName: booking.petType.icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primary700)
                .frame(width: 50, height: 50)
                .background(AppColors.primary100)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.petName)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(formatDate(booking.startDate)) - \(formatDate(booking.endDate))")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Status badge
            HStack(spacing: 4) {
                Image(systemName: booking.status.icon)
                    .font(.system(size: 10))
                Text(booking.status.displayName)
                    .font(AppFonts.captionSmall)
            }
            .foregroundColor(booking.status.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(booking.status.color.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppShadows.soft, radius: 4, x: 0, y: 2)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Booking Form View
struct BookingFormView: View {
    let startDate: Date
    let endDate: Date
    let petType: Pet.PetType
    let onComplete: (Booking) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var petName = ""
    @State private var ownerName = ""
    @State private var ownerEmail = ""
    @State private var ownerPhone = ""
    @State private var specialRequests = ""
    @State private var agreedToTerms = false
    
    var isFormValid: Bool {
        !petName.isEmpty && !ownerName.isEmpty && !ownerEmail.isEmpty && ownerEmail.contains("@") && agreedToTerms
    }
    
    var nights: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var totalPrice: Double {
        Pricing.calculateTotal(petType: petType, nights: nights)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Booking summary
                    BookingSummaryCard(
                        startDate: startDate,
                        endDate: endDate,
                        petType: petType,
                        nights: nights,
                        totalPrice: totalPrice
                    )
                    
                    // Pet info
                    BookingFormSection(title: "Pet Information") {
                        BookingFormTextField(
                            label: "Pet's Name",
                            placeholder: "Enter your pet's name",
                            text: $petName,
                            icon: "pawprint"
                        )
                    }
                    
                    // Owner info
                    BookingFormSection(title: "Your Information") {
                        BookingFormTextField(
                            label: "Your Name",
                            placeholder: "Enter your full name",
                            text: $ownerName,
                            icon: "person"
                        )
                        
                        BookingFormTextField(
                            label: "Email",
                            placeholder: "Enter your email",
                            text: $ownerEmail,
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        BookingFormTextField(
                            label: "Phone",
                            placeholder: "Enter your phone number",
                            text: $ownerPhone,
                            icon: "phone",
                            keyboardType: .phonePad
                        )
                    }
                    
                    // Special requests
                    BookingFormSection(title: "Special Requests") {
                        TextEditor(text: $specialRequests)
                            .frame(height: 100)
                            .padding(12)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                    }
                    
                    // Terms agreement
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the terms and conditions")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .tint(AppColors.primary700)
                    
                    // Submit button
                    Button(action: submitBooking) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Confirm Booking")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: !isFormValid))
                    .disabled(!isFormValid)
                }
                .padding()
                .padding(.bottom, 40)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Complete Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    func submitBooking() {
        let booking = Booking(
            petName: petName,
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

// MARK: - Booking Summary Card
struct BookingSummaryCard: View {
    let startDate: Date
    let endDate: Date
    let petType: Pet.PetType
    let nights: Int
    let totalPrice: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: petType.icon)
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.primary700)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(petType.displayName) Boarding")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(nights) night\(nights > 1 ? "s" : "")")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.primary700)
                    
                    Text("incl. tax")
                        .font(AppFonts.captionSmall)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check-in")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Text(formatDate(startDate))
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(AppColors.textTertiary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Check-out")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Text(formatDate(endDate))
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding()
        .background(AppColors.primary100)
        .cornerRadius(16)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Booking Form Components (renamed to avoid conflicts)
struct BookingFormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            content
        }
    }
}

struct BookingFormTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.textTertiary)
                
                TextField(placeholder, text: $text)
                    .font(AppFonts.bodyMedium)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 1)
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
