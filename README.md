<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS_17+-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 17+"/>
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift"/>
  <img src="https://img.shields.io/badge/SwiftUI-Framework-0071E3?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/License-All_Rights_Reserved-red?style=for-the-badge" alt="License"/>
</p>

<h1 align="center">T.O.D.O</h1>
<h3 align="center">Task-Oriented Delay Obliterator</h3>

<p align="center">
  <em>Stop procrastinating. Start obliterating.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Status-In_Development-orange?style=flat-square" alt="Status"/>
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square" alt="Version"/>
  <img src="https://img.shields.io/badge/Built_with-Claude_Code-blueviolet?style=flat-square" alt="Claude Code"/>
</p>

---

## What Is This?

A native iOS app that fights procrastination through **smart, escalating reminders**. Instead of a single notification you swipe away, T.O.D.O sends randomized nudges that increase in frequency and urgency as your deadline approaches. You control the intensity — from a gentle tap on the shoulder to a relentless barrage that makes it harder to procrastinate than to just do the thing.

## Why I Built This

Every productivity app lets you set a reminder. One notification pops up, you swipe it away, and nothing changes.

T.O.D.O takes a different approach: reminders are **random and escalating**. The closer you get to a deadline, the more aggressively the app reminds you — and because the timing is unpredictable, you can't just tune it out. The intensity is fully configurable per task (1–10 scale), so you decide how hard each task pushes back against your procrastination.

---

## How It Works

```
1. Create a task       →  Title, deadline, intensity (1–10)
2. Choose channels     →  Push notifications, email, or both
3. T.O.D.O takes over  →  Random reminders that escalate as the deadline nears
4. Get it done         →  Mark complete and the reminders stop
```

### The Reminder Algorithm

> Reminder frequency follows an **exponential curve** based on time remaining and your chosen intensity.

| Time Remaining | Intensity 5 | Intensity 10 |
|:---|:---:|:---:|
| 🟢 **7+ days** | 1–2/day | 3–4/day |
| 🟡 **2–3 days** | 5–8/day | 10–15/day |
| 🟠 **Under 24 hours** | 8–12/day | 15–20/day |
| 🔴 **Overdue** | Max frequency | Max frequency |

The Cloud Function runs every 15 minutes, calculates a probability for each task based on `intensity * (1 / hoursRemaining) * scaleFactor`, and rolls the dice. Quiet hours (default 10 PM – 8 AM, configurable) are always respected.

---

## Features

| Feature | Description |
|:---|:---|
| 🔐 **Authentication** | Email/password sign up, sign in, and password reset |
| 📋 **Task Management** | Create, edit, delete tasks with deadlines and details |
| 🎚️ **Intensity Control** | Per-task slider (1–10) controls reminder aggressiveness |
| 🔔 **Push Notifications** | Randomized reminders via APNs + Firebase Cloud Messaging |
| 📧 **Email Reminders** | Optional email channel for extra accountability |
| 🌙 **Quiet Hours** | Configurable do-not-disturb window |
| ⚠️ **Overdue Tracking** | Visual indicators for missed deadlines |
| ✅ **Completion Tracking** | Collapsible completed tasks section |
| 🗑️ **Account Deletion** | Full data deletion (App Store requirement) |
| 📱 **Local Fallback** | Local notifications when offline |

---

## Tech Stack

<table>
  <tr>
    <td><img src="https://img.shields.io/badge/UI-SwiftUI-0071E3?style=flat-square&logo=swift&logoColor=white"/></td>
    <td>SwiftUI with iOS 17+ features</td>
  </tr>
  <tr>
    <td><img src="https://img.shields.io/badge/Auth-Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black"/></td>
    <td>Firebase Authentication (email/password)</td>
  </tr>
  <tr>
    <td><img src="https://img.shields.io/badge/Database-Firestore-FFCA28?style=flat-square&logo=firebase&logoColor=black"/></td>
    <td>Cloud Firestore (real-time sync)</td>
  </tr>
  <tr>
    <td><img src="https://img.shields.io/badge/Push-APNs_+_FCM-000000?style=flat-square&logo=apple&logoColor=white"/></td>
    <td>Apple Push Notification service + Firebase Cloud Messaging</td>
  </tr>
  <tr>
    <td><img src="https://img.shields.io/badge/Email-Firebase_Trigger-FFCA28?style=flat-square&logo=firebase&logoColor=black"/></td>
    <td>Firebase Trigger Email extension</td>
  </tr>
  <tr>
    <td><img src="https://img.shields.io/badge/Backend-Cloud_Functions-FFCA28?style=flat-square&logo=firebase&logoColor=black"/></td>
    <td>Node.js / TypeScript scheduled functions</td>
  </tr>
</table>

---

## Project Structure

```
TODO/                              # iOS App (SwiftUI)
├── 📁 App/
│   ├── TODOApp.swift              # Entry point, Firebase init, auth routing
│   └── AppDelegate.swift          # Push notification registration
├── 📁 Models/
│   └── TaskItem.swift             # Task model, UserProfile, ReminderType
├── 📁 ViewModels/
│   ├── AuthViewModel.swift        # Auth state management
│   ├── TaskViewModel.swift        # Task CRUD + real-time sync
│   └── SettingsViewModel.swift    # User preferences
├── 📁 Views/
│   ├── Auth/
│   │   ├── LoginView.swift        # Sign in + forgot password
│   │   └── SignUpView.swift       # Registration
│   ├── Tasks/
│   │   ├── TaskListView.swift     # Main screen
│   │   ├── TaskRowView.swift      # Task row with intensity dots
│   │   └── TaskEditView.swift     # Add/edit task sheet
│   └── Settings/
│       └── SettingsView.swift     # Quiet hours, defaults, account
└── 📁 Services/
    ├── FirestoreService.swift     # Firestore CRUD operations
    └── NotificationService.swift  # FCM + local notifications

functions/                         # Firebase Cloud Functions
├── 📁 src/
│   ├── index.ts                   # Scheduled function entry point
│   ├── reminderScheduler.ts       # Core reminder algorithm
│   ├── notifications.ts           # FCM + email delivery
│   └── templates.ts               # Randomized reminder messages
├── package.json
└── tsconfig.json
```

---

## Getting Started

### Prerequisites

- **Xcode 15+** with iOS 17 SDK
- **Firebase project** on the [Blaze plan](https://console.firebase.google.com)
- **Node.js 18+** and Firebase CLI (`npm install -g firebase-tools`)
- **Apple Developer account** ($99/year) for push notifications and App Store

### iOS App

```bash
# 1. Clone this repo
git clone https://github.com/yourusername/Task-Oriented-Delay-Obliterator.git

# 2. Open in Xcode
open TODO/TODO.xcodeproj
```

3. Create a Firebase project and enable **Email/Password** authentication
4. Create a **Cloud Firestore** database
5. Download `GoogleService-Info.plist` from Firebase Console and add it to `TODO/TODO/`
6. Build and run (**Cmd+R**)

### Cloud Functions

```bash
cd functions
npm install
firebase login
firebase deploy --only functions
```

### Push Notifications

1. Generate an APNs key in the [Apple Developer Portal](https://developer.apple.com)
2. Upload the key to **Firebase Console → Project Settings → Cloud Messaging**
3. Enable **Push Notifications** capability in Xcode

---

## Firestore Schema

```
users/{userId}/
  ├── profile/settings    # email, fcmToken, quietHours, defaults
  └── tasks/{taskId}      # title, details, deadline, intensity, reminderTypes
```

---

<p align="center">
  <img src="https://img.shields.io/badge/License-All_Rights_Reserved-red?style=for-the-badge" alt="License"/>
</p>

<p align="center">
  All Rights Reserved. See <a href="LICENSE">LICENSE</a> for details.<br/>
  Source code is available for viewing and educational reference only.
</p>

<p align="center">
  <sub>Built with SwiftUI + Firebase | Powered by procrastination-fueled determination</sub>
</p>
