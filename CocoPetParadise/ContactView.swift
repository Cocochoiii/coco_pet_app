//
//  ContactView.swift
//  CocoPetParadise
//
//  Contact form and business information
//

import SwiftUI
import MapKit

struct ContactView: View {
    @Environment(\.dismiss) var dismiss
    @State private var contactForm = ContactForm()
    @State private var showSuccessAlert = false
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    ContactHeader()
                    
                    // Quick contact buttons
                    QuickContactButtons()
                    
                    // Contact form
                    ContactFormSection(form: $contactForm, isSubmitting: $isSubmitting) {
                        submitForm()
                    }
                    
                    // Business info
                    BusinessInfoSection()
                    
                    // Map
                    MapSection()
                    
                    // Hours
                    BusinessHoursSection()
                }
                .padding()
                .padding(.bottom, 40)
            }
            .background(AppColors.backgroundSecondary)
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .alert("Message Sent!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    contactForm = ContactForm()
                }
            } message: {
                Text("Thank you for reaching out! We'll get back to you within 24 hours.")
            }
        }
    }
    
    func submitForm() {
        isSubmitting = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccessAlert = true
        }
    }
}

// MARK: - Contact Header with Decorations
struct ContactHeader: View {
    @State private var animateDecorations = false
    
    var body: some View {
        ZStack {
            // Large corner decorations
            VStack {
                HStack(alignment: .top) {
                    DecorationImage(name: "contact-decoration", fallbackIcon: "message.fill")
                        .frame(width: 120, height: 120)
                        .opacity(animateDecorations ? 0.85 : 0)
                        .rotationEffect(.degrees(animateDecorations ? -12 : 0))
                        .offset(x: 20, y: 50)
                    
                    Spacer()
                    
                    DecorationImage(name: "contact-decoration2", fallbackIcon: "envelope.fill")
                        .frame(width: 130, height: 130)
                        .opacity(animateDecorations ? 0.85 : 0)
                        .rotationEffect(.degrees(animateDecorations ? 12 : 0))
                        .offset(x: -20, y: 50)
                }
                Spacer()
            }
            
            VStack(spacing: 12) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary700)
                
                Text("Get in Touch")
                    .font(AppFonts.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We'd love to hear from you! Reach out with any questions about boarding your furry friend.")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            .padding(.top, 40) // Space for decorations
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateDecorations = true
            }
        }
    }
}

// MARK: - Quick Contact Buttons
struct QuickContactButtons: View {
    var body: some View {
        HStack(spacing: 16) {
            QuickContactButton(
                icon: "phone.fill",
                title: "Call",
                subtitle: "(617) 555-1234",
                color: AppColors.success
            ) {
                if let url = URL(string: "tel:+16175551234") {
                    UIApplication.shared.open(url)
                }
            }
            
            QuickContactButton(
                icon: "message.fill",
                title: "Text",
                subtitle: "(617) 555-1234",
                color: AppColors.info
            ) {
                if let url = URL(string: "sms:+16175551234") {
                    UIApplication.shared.open(url)
                }
            }
            
            QuickContactButton(
                icon: "envelope.fill",
                title: "Email",
                subtitle: "hello@cocopets.com",
                color: AppColors.primary700
            ) {
                if let url = URL(string: "mailto:hello@cocopets.com") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct QuickContactButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(AppFonts.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: AppShadows.soft, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Contact Form Section
struct ContactFormSection: View {
    @Binding var form: ContactForm
    @Binding var isSubmitting: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Send a Message")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 16) {
                // Name
                ContactTextField(
                    label: "Your Name",
                    placeholder: "Enter your name",
                    text: $form.name,
                    icon: "person"
                )
                
                // Email
                ContactTextField(
                    label: "Email",
                    placeholder: "Enter your email",
                    text: $form.email,
                    icon: "envelope",
                    keyboardType: .emailAddress
                )
                
                // Phone (optional)
                ContactTextField(
                    label: "Phone (optional)",
                    placeholder: "Enter your phone",
                    text: $form.phone,
                    icon: "phone",
                    keyboardType: .phonePad
                )
                
                // Pet info
                HStack(spacing: 12) {
                    ContactTextField(
                        label: "Pet's Name",
                        placeholder: "Pet name",
                        text: $form.petName,
                        icon: "pawprint"
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pet Type")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Picker("Pet Type", selection: $form.petType) {
                            Text("Cat").tag(Pet.PetType.cat)
                            Text("Dog").tag(Pet.PetType.dog)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                // Message
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextEditor(text: $form.message)
                        .font(AppFonts.bodyMedium)
                        .frame(height: 120)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
                
                // Preferred contact method
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Contact Method")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: 12) {
                        ForEach(ContactForm.ContactMethod.allCases, id: \.self) { method in
                            ContactMethodChip(
                                method: method,
                                isSelected: form.preferredContactMethod == method
                            ) {
                                form.preferredContactMethod = method
                            }
                        }
                    }
                }
                
                // Submit button
                Button(action: onSubmit) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Send Message")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: !form.isValid || isSubmitting))
                .disabled(!form.isValid || isSubmitting)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

struct ContactTextField: View {
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
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(AppFonts.bodyMedium)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            }
            .padding()
            .background(AppColors.backgroundSecondary)
            .cornerRadius(12)
        }
    }
}

struct ContactMethodChip: View {
    let method: ContactForm.ContactMethod
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch method {
        case .email: return "envelope"
        case .phone: return "phone"
        case .text: return "message"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(method.rawValue)
                    .font(AppFonts.bodySmall)
            }
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.primary700 : AppColors.backgroundSecondary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Business Info Section
struct BusinessInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visit Us")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                InfoRow2(icon: "mappin.circle.fill", title: "Address", value: "Wellesley Hills, MA 02481")
                InfoRow2(icon: "phone.circle.fill", title: "Phone", value: "(617) 555-1234")
                InfoRow2(icon: "envelope.circle.fill", title: "Email", value: "hello@cocopets.com")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

struct InfoRow2: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primary700)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textTertiary)
                Text(value)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Map Section
struct MapSection: View {
    let businessLocation = CLLocationCoordinate2D(latitude: 42.3108, longitude: -71.2765) // Wellesley Hills
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Map {
                Annotation("Coco's Pet Paradise", coordinate: businessLocation) {
                    VStack {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.primary700)
                        
                        Text("Coco's Pet Paradise")
                            .font(AppFonts.captionSmall)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(16)
            
            Button(action: openInMaps) {
                HStack {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond")
                    Text("Get Directions")
                }
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.primary700)
            }
        }
    }
    
    func openInMaps() {
        let placemark = MKPlacemark(coordinate: businessLocation)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Coco's Pet Paradise"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Business Hours Section
struct BusinessHoursSection: View {
    let hours = [
        ("Monday - Friday", "8:00 AM - 6:00 PM"),
        ("Saturday", "9:00 AM - 5:00 PM"),
        ("Sunday", "10:00 AM - 4:00 PM")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hours")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(hours, id: \.0) { day, time in
                    HStack {
                        Text(day)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(time)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            
            // Emergency note
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(AppColors.warning)
                
                Text("24/7 emergency care available for boarding pets")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .background(AppColors.warning.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}
