 StaffPulse 💚

> **Workforce Attendance, Intelligent Shift Management & Anonymous Pulse AI Platform**  
> Built for the BHARATCODE HACKATHON 
> 🌐 **Live Web Deployment:** [https://staffpulse-hr-2024.web.app/](https://staffpulse-hr-2024.web.app/)  
> ⚡ **Evaluator Access:** One-click instant demo mode with full enterprise shifts & live attendance records (or Admin `admin` / `admin123`)

---

## 🎯 Overview

StaffPulse is a Flutter mobile app that helps managers detect burnout risks early through **100% anonymous** daily employee pulse check-ins. Employees submit their mood, energy, and workload in under 10 seconds — their responses are immediately anonymized, and managers only ever see aggregated team wellness score.

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
│   │   ├── revenuecat_service.dart  # 
│   │   └── notification_service.dart # Push notifications
│   └── theme/
│       └── app_theme.dart       # Light/dark themes, brand colors
└── features/
    ├── auth/                    # Onboarding, Login, Role Select
    ├── dashboard/               # Manager Dashboard, Employee Dashboard
    ├── pulse/                   # Pulse Check-in (4-step), Results
    ├── team/                    # Team screen, Invite screen
    ├── analytics/               # Charts & analytics
    ├── paywall/                         # Notifications, privacy, account
```

---

## 💰 Monetization (RevenueCat)

| Tier | Price | Features |
|------|-------|---------|
| **Free** | $0 | 3 team members, 7-day history, basic pulse |
| **Pro Monthly** | $4.99/mo | Unlimited members, 30-day history, AI insights, PDF export |
| **Pro Annual** | $39.99/yr | Everything in Pro (save 33%) |

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
flutterfire configure --project=YOUR_FIREBASE_PROJECT Run the app
```bash
# Android / Samsung Galaxy
flutter run --release
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

##  Submission Checklist

- [x] New app (not published before August 1, 2026)(`purchases_flutter`)
- [x] At least one IAP / subscription configured (`staffpulse_pro`)
- [x] Restore Purchases button on paywall & settings (Apple & Samsung requirement)
- [x] Privacy Policy & Terms of Service dialogs & web URLs in app
- [x] Executive PDF Report export engine implemented (`pdf` & `printing`
