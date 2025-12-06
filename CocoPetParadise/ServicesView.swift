//
//  ServicesView.swift
//  CocoPetParadise
//
//  Services page with Virtual Tour and Contact Us included
//

import SwiftUI

struct ServicesView: View {
    @State private var animateHeader = false
    @State private var animateContent = false
    @State private var showVirtualTour = false
    @State private var showContactForm = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header with decorations
                ServiceHeaderView(animate: $animateHeader)
                
                // Services Grid
                VStack(spacing: 24) {
                    // Main Services
                    ServicesSectionTitle(title: "Our Services", icon: "sparkles")
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)
                    
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        // Home Boarding with detailed pricing
                        HomeBoardingCard()
                        
                        ServiceCard(
                            icon: "camera.fill",
                            title: "Daily Photo Updates",
                            description: "Receive adorable photos and videos of your pet throughout their stay.",
                            price: "Included",
                            color: AppColors.primary600
                        )
                        
                        ServiceCard(
                            icon: "car.fill",
                            title: "Pick-up & Drop-off",
                            description: "Convenient transportation within Wellesley Hills and nearby areas.",
                            price: "Free (5mi)",
                            color: AppColors.primary500
                        )
                        
                        ServiceCard(
                            icon: "scissors",
                            title: "Grooming",
                            description: "Basic grooming services including brushing, nail trimming, and bathing.",
                            price: "From $15",
                            color: AppColors.primary400
                        )
                        
                        ServiceCard(
                            icon: "heart.fill",
                            title: "Special Care",
                            description: "Medication administration and special dietary needs accommodated.",
                            price: "Custom",
                            color: AppColors.error
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)
                    
                    // Virtual Tour Section
                    ServicesSectionTitle(title: "Explore Our Space", icon: "map.fill")
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)
                    
                    VirtualTourCard(showTour: $showVirtualTour)
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: animateContent)
                    
                    // Contact Us Section
                    ServicesSectionTitle(title: "Contact Us", icon: "envelope.fill")
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)
                    
                    ContactUsCard(showContact: $showContactForm)
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.45), value: animateContent)
                }
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .background(AppColors.backgroundSecondary)
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showVirtualTour) {
            VirtualTourFullScreen()
        }
        .sheet(isPresented: $showContactForm) {
            ContactView()
        }
        .onAppear {
            animateHeader = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateContent = true
            }
        }
    }
}

// MARK: - Service Header View
struct ServiceHeaderView: View {
    @Binding var animate: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [AppColors.primary200, AppColors.primary100, AppColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Corner decorations
            VStack {
                HStack(alignment: .top) {
                    DecorationImage(name: "service-area-hours", fallbackIcon: "sparkles")
                        .frame(width: 150, height: 150)
                        .opacity(animate ? 0.8 : 0)
                        .rotationEffect(.degrees(animate ? -15 : -30))
                        .offset(x: 10, y: animate ? 50 : 60)
                    
                    Spacer()
                    
                    DecorationImage(name: "testimonials-decoration2", fallbackIcon: "heart.fill")
                        .frame(width: 120, height: 120)
                        .opacity(animate ? 0.75 : 0)
                        .rotationEffect(.degrees(animate ? 15 : 30))
                        .offset(x: 0, y: animate ? 50 : 60)
                }
                Spacer()
            }
            
            // Content
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary100)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 45))
                        .foregroundColor(AppColors.primary700)
                }
                .scaleEffect(animate ? 1 : 0.5)
                .opacity(animate ? 1 : 0)
                
                Text("Premium Pet Care")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .opacity(animate ? 1 : 0)
                
                Text("Everything your furry friend needs")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .opacity(animate ? 1 : 0)
            }
            .padding(.top, 50)
        }
        .frame(height: 250)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
    }
}

// MARK: - Section Title
struct ServicesSectionTitle: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primary700)
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Home Boarding Card with Detailed Pricing
struct HomeBoardingCard: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary700.opacity(0.15))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primary700)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Home Boarding")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("From $25/night")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primary700)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(18)
            
            // Expanded content with detailed pricing
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Text("24/7 care in a loving home environment. Your pet will enjoy family-style attention.")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textSecondary)
                    
                    // Cat Pricing
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "cat.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary700)
                            Text("Cat Boarding")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.primary700)
                        }
                        
                        VStack(spacing: 6) {
                            PricingRow(label: "1 Cat", price: "$25/night")
                            PricingRow(label: "2 Cats", price: "$40/night")
                            PricingRow(label: "30 Days Package", price: "$700")
                            PricingRow(label: "60 Days Package", price: "$1,400")
                        }
                    }
                    .padding(12)
                    .background(AppColors.primary100.opacity(0.5))
                    .cornerRadius(12)
                    
                    // Dog Pricing
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "dog.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary700)
                            Text("Dog Boarding")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.primary700)
                        }
                        
                        VStack(spacing: 6) {
                            PricingRow(label: "Small (<30 lbs)", price: "$40/night")
                            PricingRow(label: "Large (>30 lbs)", price: "$60/night")
                            PricingRow(label: "2 Small Dogs", price: "$70/night")
                            PricingRow(label: "2 Large Dogs", price: "$110/night")
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("30-Day Packages")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.primary600)
                        
                        VStack(spacing: 6) {
                            PricingRow(label: "Small Dog", price: "$1,000")
                            PricingRow(label: "Large Dog", price: "$1,500")
                        }
                    }
                    .padding(12)
                    .background(AppColors.primary100.opacity(0.5))
                    .cornerRadius(12)
                    
                    // Dog Daycare
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.warning)
                            Text("Dog Daycare (10 Hours)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppColors.primary700)
                        }
                        
                        VStack(spacing: 6) {
                            PricingRow(label: "Small Dog", price: "$25/day")
                            PricingRow(label: "Large Dog", price: "$30/day")
                        }
                    }
                    .padding(12)
                    .background(AppColors.warning.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Included features
                    VStack(alignment: .leading, spacing: 6) {
                        IncludedFeature(text: "Daily photo updates included")
                        IncludedFeature(text: "Free pickup within 5 miles")
                        IncludedFeature(text: "Medication administration available")
                        IncludedFeature(text: "Special dietary needs accommodated")
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: AppColors.primary700.opacity(0.1), radius: 15, x: 0, y: 5)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Pricing Row
struct PricingRow: View {
    let label: String
    let price: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(price)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

// MARK: - Included Feature
struct IncludedFeature: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(AppColors.success)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Service Card
struct ServiceCard: View {
    let icon: String
    let title: String
    let description: String
    let price: String
    let color: Color
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(price)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding(18)
            
            // Expanded content
            if isExpanded {
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 15, x: 0, y: 5)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Virtual Tour Card (with cover image, no SVG decorations)
struct VirtualTourCard: View {
    @Binding var showTour: Bool
    @State private var animate = false
    
    var body: some View {
        Button(action: { showTour = true }) {
            VStack(spacing: 0) {
                // Preview image area - uses tour-cover image
                ZStack {
                    // Cover image - Add "tour-cover" to Assets.xcassets
                    if UIImage(named: "tour-cover") != nil {
                        Image("tour-cover")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    } else {
                        // Fallback gradient when no image
                        LinearGradient(
                            colors: [AppColors.primary400, AppColors.primary600],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    
                    // Dark overlay for better text visibility
                    LinearGradient(
                        colors: [Color.black.opacity(0.1), Color.black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Center content
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.95))
                                .frame(width: 70, height: 70)
                                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.primary700)
                                .scaleEffect(animate ? 1.1 : 1)
                        }
                        
                        Text("Take a Virtual Tour")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        Text("Explore 13 rooms")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                .frame(height: 180)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                
                // Bottom info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interactive Experience")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("See where your pet will stay")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primary700)
                }
                .padding(18)
                .background(Color.white)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            }
            .shadow(color: AppColors.primary700.opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
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
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Virtual Tour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Contact Us Card
struct ContactUsCard: View {
    @Binding var showContact: Bool
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Decorations
            ZStack {
                HStack {
                    DecorationImage(name: "contact-decoration", fallbackIcon: "envelope.fill")
                        .frame(width: 70, height: 70)
                        .opacity(0.7)
                        .rotationEffect(.degrees(-15))
                    Spacer()
                    DecorationImage(name: "contact-decoration2", fallbackIcon: "message.fill")
                        .frame(width: 80, height: 80)
                        .opacity(0.7)
                        .rotationEffect(.degrees(15))
                }
                
                VStack(spacing: 12) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primary700)
                        .scaleEffect(animate ? 1.05 : 1)
                    
                    Text("Have Questions?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("We're here to help with any questions about your pet's stay")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            // Quick contact buttons
            HStack(spacing: 12) {
                ContactButton(icon: "phone.fill", label: "Call", color: AppColors.success) {
                    if let url = URL(string: "tel:+16175551234") {
                        UIApplication.shared.open(url)
                    }
                }
                
                ContactButton(icon: "message.fill", label: "Text", color: AppColors.info) {
                    if let url = URL(string: "sms:+16175551234") {
                        UIApplication.shared.open(url)
                    }
                }
                
                ContactButton(icon: "envelope.fill", label: "Email", color: AppColors.primary700) {
                    if let url = URL(string: "mailto:hello@cocospetparadise.com") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            // Full contact form button
            Button(action: { showContact = true }) {
                HStack {
                    Image(systemName: "pencil.and.outline")
                    Text("Send a Message")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [AppColors.primary700, AppColors.primary600],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.primary100)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct ContactButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
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
