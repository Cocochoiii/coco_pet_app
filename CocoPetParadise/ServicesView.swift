//
//  ServicesView_Enhanced.swift
//  CocoPetParadise
//
//  Premium Services page with refined UI/UX
//

import SwiftUI

struct ServicesView: View {
    @State private var animateContent = false
    @State private var showVirtualTour = false
    @State private var showContactForm = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Clean header
                ServicesHeaderView()
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : -10)
                    .animation(.easeOut(duration: 0.4), value: animateContent)
                
                VStack(spacing: 28) {
                    // Main Services Section
                    ServicesSectionView()
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: animateContent)
                    
                    // Virtual Tour Section
                    VirtualTourSectionView(showTour: $showVirtualTour)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: animateContent)
                    
                    // Contact Section
                    ContactSectionView(showContact: $showContactForm)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: animateContent)
                }
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .background(AppColors.background)
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showVirtualTour) {
            VirtualTourFullScreen()
        }
        .sheet(isPresented: $showContactForm) {
            ContactView()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateContent = true
            }
        }
    }
}

// MARK: - Services Header
struct ServicesHeaderView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [AppColors.primary100.opacity(0.5), AppColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Corner decorations
            VStack {
                HStack(alignment: .top) {
                    DecorationImage(name: "service-area-hours", fallbackIcon: "sparkles")
                        .frame(width: 150, height: 150)
                        .opacity(animate ? 0.75 : 0)
                        .rotationEffect(.degrees(animate ? -12 : -25))
                        .offset(x: 0, y: animate ? 20 : 35)
                    
                    Spacer()
                    
                    DecorationImage(name: "testimonials-decoration2", fallbackIcon: "heart.fill")
                        .frame(width: 110, height: 110)
                        .opacity(animate ? 0.7 : 0)
                        .rotationEffect(.degrees(animate ? 12 : 25))
                        .offset(x: -10, y: animate ? 25 : 40)
                }
                Spacer()
            }
            
            // Content
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary100)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(AppColors.primary700)
                }
                .scaleEffect(animate ? 1 : 0.7)
                .opacity(animate ? 1 : 0)
                
                VStack(spacing: 6) {
                    Text("Premium Pet Care")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .opacity(animate ? 1 : 0)
                    
                    Text("Everything your furry friend needs")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .opacity(animate ? 1 : 0)
                }
            }
            .padding(.top, 30)
        }
        .frame(height: 220)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Services Section
struct ServicesSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ServicePageSectionTitle(title: "Our Services", icon: "list.bullet.rectangle.portrait")
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                // Home Boarding - Main service
                HomeBoardingServiceCard()
                
                // Other services
                SimpleServiceCard(
                    icon: "camera.fill",
                    title: "Daily Photo Updates",
                    description: "Receive adorable photos and videos of your pet throughout their stay.",
                    price: "Included",
                    color: AppColors.primary600
                )
                
                SimpleServiceCard(
                    icon: "car.fill",
                    title: "Pick-up & Drop-off",
                    description: "Convenient transportation within Wellesley Hills and nearby areas.",
                    price: "Free (5mi)",
                    color: AppColors.info
                )
                
                SimpleServiceCard(
                    icon: "scissors",
                    title: "Grooming",
                    description: "Basic grooming including brushing, nail trimming, and bathing.",
                    price: "From $15",
                    color: AppColors.warning
                )
                
                SimpleServiceCard(
                    icon: "heart.fill",
                    title: "Special Care",
                    description: "Medication administration and special dietary needs accommodated.",
                    price: "Custom",
                    color: AppColors.error
                )
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Service Page Section Title
struct ServicePageSectionTitle: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.primary600)
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

// MARK: - Home Boarding Card
struct HomeBoardingServiceCard: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header - always visible
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticManager.impact(.light)
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary700.opacity(0.12))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "house.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.primary700)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Home Boarding")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("From $25/night")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.primary600)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    Text("24/7 care in a loving home environment with family-style attention.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 16)
                    
                    // Cat Pricing
                    PricingSection(
                        icon: "cat.fill",
                        title: "Cat Boarding",
                        color: AppColors.primary600,
                        items: [
                            ("1 Cat", "$25/night"),
                            ("2 Cats", "$40/night"),
                            ("30 Days", "$700"),
                            ("60 Days", "$1,400")
                        ]
                    )
                    
                    // Dog Pricing
                    PricingSection(
                        icon: "dog.fill",
                        title: "Dog Boarding",
                        color: AppColors.primary600,
                        items: [
                            ("Small (<30 lbs)", "$40/night"),
                            ("Large (>30 lbs)", "$60/night"),
                            ("2 Small Dogs", "$70/night"),
                            ("2 Large Dogs", "$110/night")
                        ]
                    )
                    
                    // Dog Daycare
                    PricingSection(
                        icon: "sun.max.fill",
                        title: "Dog Daycare (10 hrs)",
                        color: AppColors.warning,
                        items: [
                            ("Small Dog", "$25/day"),
                            ("Large Dog", "$30/day")
                        ]
                    )
                    
                    // Included features
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's Included")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        FeatureItem(text: "Daily photo updates")
                        FeatureItem(text: "Free pickup within 5 miles")
                        FeatureItem(text: "Medication administration")
                        FeatureItem(text: "Special dietary needs")
                    }
                    .padding(14)
                    .background(AppColors.success.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Pricing Section
struct PricingSection: View {
    let icon: String
    let title: String
    let color: Color
    let items: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 6) {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(item.1)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
        .padding(14)
        .background(AppColors.neutral100)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Feature Item
struct FeatureItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppColors.success)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Simple Service Card
struct SimpleServiceCard: View {
    let icon: String
    let title: String
    let description: String
    let price: String
    let color: Color
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticManager.impact(.light)
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(price)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, -4)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Virtual Tour Section
struct VirtualTourSectionView: View {
    @Binding var showTour: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ServicePageSectionTitle(title: "Explore Our Space", icon: "map")
                .padding(.horizontal, 20)
            
            Button(action: {
                showTour = true
                HapticManager.impact(.medium)
            }) {
                VStack(spacing: 0) {
                    // Image area
                    ZStack {
                        // Cover image or gradient fallback
                        if UIImage(named: "tour-cover") != nil {
                            Image("tour-cover")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 160)
                                .clipped()
                        } else {
                            LinearGradient(
                                colors: [AppColors.primary500, AppColors.primary700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(height: 160)
                        }
                        
                        // Overlay
                        LinearGradient(
                            colors: [Color.black.opacity(0.1), Color.black.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Play button
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.primary700)
                                    .offset(x: 2)
                            }
                            
                            Text("Virtual Tour")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                    }
                    .frame(height: 160)
                    
                    // Info bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Interactive Experience")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("13 rooms to explore")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primary600)
                            .padding(10)
                            .background(AppColors.primary100)
                            .clipShape(Circle())
                    }
                    .padding(16)
                    .background(Color.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: AppColors.primary700.opacity(0.1), radius: 15, x: 0, y: 6)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Contact Section
struct ContactSectionView: View {
    @Binding var showContact: Bool
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ServicePageSectionTitle(title: "Get in Touch", icon: "envelope")
                .padding(.horizontal, 20)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.primary50)
                
                // Decorations
                VStack {
                    HStack(alignment: .top) {
                        DecorationImage(name: "contact-decoration", fallbackIcon: "envelope.fill")
                            .frame(width: 100, height: 100)
                            .opacity(0.65)
                            .rotationEffect(.degrees(-15))
                            .offset(x: 20, y: 10)
                        
                        Spacer()
                        
                        DecorationImage(name: "contact-decoration2", fallbackIcon: "message.fill")
                            .frame(width: 120, height: 120)
                            .opacity(0.6)
                            .rotationEffect(.degrees(15))
                            .offset(x: -20, y: 5)
                    }
                    Spacer()
                }
                
                // Content
                VStack(spacing: 16) {
                    // Icon and text
                    VStack(spacing: 10) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(AppColors.primary700)
                            .scaleEffect(animate ? 1.05 : 1)
                        
                        Text("Have Questions?")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("We're here to help with any questions")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    // Quick contact options
                    HStack(spacing: 12) {
                        ServiceContactButton(
                            icon: "phone.fill",
                            label: "Call",
                            color: AppColors.success
                        ) {
                            if let url = URL(string: "tel:+16175551234") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        ServiceContactButton(
                            icon: "message.fill",
                            label: "Text",
                            color: AppColors.info
                        ) {
                            if let url = URL(string: "sms:+16175551234") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        ServiceContactButton(
                            icon: "envelope.fill",
                            label: "Email",
                            color: AppColors.primary600
                        ) {
                            if let url = URL(string: "mailto:hello@cocospetparadise.com") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    // Send message button
                    Button(action: {
                        showContact = true
                        HapticManager.impact(.medium)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.line")
                                .font(.system(size: 16, weight: .medium))
                            Text("Send a Message")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primary600, AppColors.primary700],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                }
                .padding(20)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Service Contact Button
struct ServiceContactButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.neutral50)
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Virtual Tour Full Screen
struct VirtualTourFullScreen: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VirtualTourSection()
            }
            .background(AppColors.background)
            .navigationTitle("Virtual Tour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary600)
                }
            }
        }
    }
}

// MARK: - Preview
struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ServicesView()
        }
    }
}
