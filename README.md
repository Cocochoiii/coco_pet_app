# 🐾 Coco's Pet Paradise - iOS App

A premium pet boarding iOS application for Coco's Pet Paradise, located in Wellesley Hills, Massachusetts.

## 📱 Overview

This is a native iOS app built with **SwiftUI** that mirrors the functionality of the [Coco's Pet Paradise website](https://coco-pets.vercel.app/). The app provides a seamless mobile experience for pet owners to browse boarding pets, make reservations, and stay connected with their furry friends.

## ✨ Features

### Core Features
- **🏠 Home Screen** - Beautiful hero section with animated statistics, featured pets carousel, and quick actions
- **🐱🐕 Pet Gallery** - Browse all cats and dogs with filtering, search, and favorites
- **📅 Booking Calendar** - Interactive calendar with real-time availability and booking form
- **⭐ Services** - Detailed service offerings with pricing and FAQ
- **👤 User Profile** - Account management, notifications, settings, and booking history

### App-Specific Features (Not in Website)
- **📲 Push Notifications** - Booking reminders and pet updates
- **❤️ Favorites** - Save your favorite pets locally
- **🔐 Face ID/Touch ID** - Secure admin login
- **📍 Map Integration** - Get directions to the facility
- **📤 Share** - Share pets and app with friends
- **🌙 Dark Mode** - System-wide dark mode support
- **📴 Offline Support** - Browse pets without internet

## 🎨 Design

The app follows the same cream-pink aesthetic as the website:

| Color | Hex Code | Usage |
|-------|----------|-------|
| Primary | `#D4A5A5` | Main accent color |
| Primary Light | `#EEE1DB` | Backgrounds, cards |
| Primary Dark | `#A67373` | Buttons, text emphasis |
| Neutral | `#8B7E78` | Secondary text |
| Success | `#7A9A82` | Available dates, confirmations |
| Warning | `#D4A574` | Limited availability |
| Error | `#C17B7B` | Full dates, errors |

## 🛠 Technical Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Architecture**: MVVM with Observable Objects
- **Data Persistence**: UserDefaults (local storage)
- **Maps**: MapKit

## 📁 Project Structure

```
CocoPetParadise/
├── CocoPetParadise.xcodeproj/
│   └── project.pbxproj
├── CocoPetParadise/
│   ├── CocoPetParadiseApp.swift    # App entry point
│   ├── ContentView.swift           # Main tab navigation
│   ├── AppColors.swift             # Theme colors & styles
│   ├── Models.swift                # Data models
│   ├── Managers.swift              # Data managers
│   ├── HomeView.swift              # Home screen
│   ├── PetsView.swift              # Pet gallery & details
│   ├── BookingView.swift           # Booking calendar & form
│   ├── ServicesView.swift          # Services showcase
│   ├── ProfileView.swift           # User profile & settings
│   ├── ContactView.swift           # Contact form & info
│   └── Assets.xcassets/            # App icons & colors
└── README.md
```

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- iOS 17.0+ device or simulator

### Installation

1. **Download the project files** - Copy all files to your Mac

2. **Open in Xcode** - Open `CocoPetParadise.xcodeproj` in Xcode

3. **Configure Signing** - Select your development team in project settings

4. **Add App Icon** (Optional) - Add a 1024x1024 PNG to Assets

5. **Build & Run** - Press `Cmd + R` to build and run

## 💰 Pricing

| Service | Price |
|---------|-------|
| Cat Boarding | $25/night |
| Dog Boarding (Small) | $40/night |
| Dog Boarding (Large) | $60/night |
| Dog Daycare | $25-30/day |
| Grooming | From $15 |
| Pickup (within 10 miles) | Free |

*Massachusetts tax (6.25%) applied to all services*

## 👤 Admin Access

For admin features, use:
- **Email**: `hcaicoco@gmail.com`
- **Password**: Any password

## 📱 App vs Website Comparison

| Feature | Website | iOS App |
|---------|---------|---------|
| Browse Pets | ✅ | ✅ |
| Booking Calendar | ✅ | ✅ |
| Push Notifications | ❌ | ✅ |
| Offline Access | ❌ | ✅ |
| Favorites | Session | Persistent |
| Native Maps | ❌ | ✅ |

---

Made with ❤️ for Coco's Pet Paradise 🐾
