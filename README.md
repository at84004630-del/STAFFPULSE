# StaffPulse 💚

> **Anonymous Employee Pulse Check & Burnout Prevention App**  
> Built for the **RevenueCat Ship-a-ton 2026** Hackathon

---

## 🎯 Overview

StaffPulse is a Flutter mobile app that helps managers detect burnout risks early through **100% anonymous** daily employee pulse check-ins. Employees submit their mood, energy, and workload in under 10 seconds — their responses are immediately anonymized, and managers only ever see aggregated team wellness scores.

### Target Award Categories
- 🕊️ **RevenueCat Peace Prize** — Social Impact / Workplace Mental Health
- 💰 **HAMM Award** — Monetization mastery with Freemium + Pro tier
- 🏆 **RevenueCat Design Award** — Premium glassmorphism UI + animations

---

## 📱 App Store Target

**Samsung Galaxy Store** ← Primary (no 14-day tester requirement, free account)  
Apple App Store ← Secondary

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── config/
│   │   ├── app_config.dart      # Constants, API keys, tier limits
│   │   └── firebase_options.dart # Firebase config (run flutterfire configure)
│   ├── models/
│   │   └── pulse_models.dart    # PulseCheckin, Team, TeamAnalytics, enums
│   ├── router/
│   │   └── app_router.dart      # GoRouter + bottom nav shell
│   ├── services/
│   │   ├── revenuecat_service.dart  # RevenueCat SDK wrapper
│   │   └── notification_service.dart # Push notifications
│   └── theme/
│       └── app_theme.dart       # Light/dark themes, brand colors
└── features/
    ├── auth/                    # Onboarding, Login, Role Select
    ├── dashboard/               # Manager Dashboard, Employee Dashboard
    ├── pulse/                   # Pulse Check-in (4-step), Results
    ├── team/                    # Team screen, Invite screen
    ├── analytics/               # Charts & analytics
    ├── paywall/                 # RevenueCat paywall
    └── settings/                # Notifications, privacy, account
```

---

## 💰 Monetization (RevenueCat)

| Tier | Price | Features |
|------|-------|---------|
| **Free** | $0 | 3 team members, 7-day history, basic pulse |
| **Pro Monthly** | $4.99/mo | Unlimited members, 30-day history, AI insights, PDF export |
| **Pro Annual** | $39.99/yr | Everything in Pro (save 33%) |

### RevenueCat Integration
- `purchases_flutter` SDK initialized in `main.dart`
- `RevenueCatService` wrapper handles: `getOfferings()`, `purchasePackage()`, `restorePurchases()`
- Entitlement: `staffpulse_pro`
- ✅ **Restore Purchases** button on paywall (required by Apple/Samsung)
- ✅ **Privacy Policy** and **Terms of Service** links on paywall

---

## 🚀 Setup Instructions

### 1. Install Flutter
```bash
# Follow: https://docs.flutter.dev/get-started/install
flutter doctor
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

### 4. RevenueCat Setup
1. Create account at [app.revenuecat.com](https://app.revenuecat.com)
2. Create a new project → Add Android/iOS app
3. Create an Entitlement: `staffpulse_pro`
4. Create Products in Samsung Seller Portal / App Store Connect
5. Replace API keys in `lib/core/config/app_config.dart`:
   ```dart
   static const String revenueCatAndroidApiKey = 'goog_YOUR_KEY';
   static const String revenueCatIosApiKey = 'appl_YOUR_KEY';
   ```

### 5. Run the app
```bash
# Android / Samsung Galaxy
flutter run --release

# Build APK for Samsung Galaxy Store
flutter build apk --release
```

---

## 🔒 Privacy Architecture

- Employee check-in responses are **never linked to a person's identity**
- Each response is tagged with a **daily-rotating anonymous hash** (HMAC-SHA256)
- Managers require a **minimum of 3 responses** before any aggregate view is shown
- Notes are stored as plaintext but unlinked — cannot be traced back
- Firestore security rules enforce that employees can ONLY write, never read team data

---

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State | Riverpod 2 + GoRouter |
| Backend | Firebase (Auth + Firestore) |
| Monetization | RevenueCat `purchases_flutter` |
| Local Storage | Hive |
| Charts | fl_chart |
| Animations | flutter_animate |
| Notifications | flutter_local_notifications |
| PDF Export | pdf + printing (Pro) |

---

## 🗓️ Ship-a-ton Submission Checklist

- [x] New app (not published before August 1, 2026)
- [x] RevenueCat SDK integrated (`purchases_flutter`)
- [x] At least one IAP / subscription configured (`staffpulse_pro`)
- [x] Restore Purchases button on paywall & settings (Apple & Samsung requirement)
- [x] Privacy Policy & Terms of Service dialogs & web URLs in app
- [x] Executive PDF Report export engine implemented (`pdf` & `printing`)
- [x] Devpost submission writeup prepared (`STAFFPULSE_DEVPOST_SUBMISSION.md`)
- [x] Release APK compiled (`build\app\outputs\flutter-apk\app-release.apk`)
- [ ] Uploaded to Samsung Galaxy Store / TestFlight
- [ ] Demo video recorded (2 minutes max)
- [ ] RevenueCat dashboard screenshot showing sandbox / live events

