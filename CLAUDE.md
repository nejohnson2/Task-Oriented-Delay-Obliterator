# T.O.D.O — Task-Oriented Delay Obliterator

## What This Is
A native iOS app (SwiftUI, iOS 17+) that fights procrastination through smart, escalating reminders. Reminders are random but increase in frequency as deadlines approach. Users control the "intensity" (1–10 scale) per task.

## Tech Stack
- **Frontend:** SwiftUI (iOS 17+)
- **Backend:** Firebase (Blaze plan)
  - Firebase Auth (email/password)
  - Cloud Firestore (task & user data)
  - Cloud Functions (Node.js/TypeScript — reminder scheduler)
  - Firebase Cloud Messaging (push notifications)
  - Firebase Trigger Email extension (email reminders)

## Project Structure
```
TODO/                          # iOS app source
├── App/
│   ├── TODOApp.swift          # Entry point, Firebase init, auth routing
│   └── AppDelegate.swift      # Push notification registration
├── Models/
│   └── TaskItem.swift         # Task data model + ReminderType enum
├── ViewModels/
│   ├── AuthViewModel.swift    # Auth state management
│   ├── TaskViewModel.swift    # Task CRUD operations
│   └── SettingsViewModel.swift # User settings management
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── SignUpView.swift
│   ├── Tasks/
│   │   ├── TaskListView.swift  # Main screen — task list
│   │   ├── TaskRowView.swift   # Individual task row
│   │   └── TaskEditView.swift  # Add/edit task sheet
│   └── Settings/
│       └── SettingsView.swift
├── Services/
│   ├── FirestoreService.swift  # Firestore CRUD operations
│   └── NotificationService.swift # APNs + FCM token management
└── Resources/
    └── GoogleService-Info.plist # Firebase config (NOT in git)

functions/                      # Firebase Cloud Functions
├── src/
│   ├── index.ts               # Cloud Functions entry point
│   ├── reminderScheduler.ts   # Core scheduling algorithm
│   ├── notifications.ts       # FCM + email delivery
│   └── templates.ts           # Randomized reminder messages
├── package.json
└── tsconfig.json
```

## Key Architecture Decisions
- **Auth:** Email/password only (no social login, no Sign in with Apple required)
- **Reminder algorithm:** Exponential curve — `remindersPerDay = intensity * (1 / hoursRemaining) * scaleFactor`. Cloud Function runs every 15 minutes and rolls random chance per task.
- **Quiet hours:** Default 10 PM – 8 AM, configurable per user
- **No tabs UI:** Single-screen task list with sheet modals for add/edit/settings

## Firestore Schema
```
users/{userId}/
  ├─ profile: { email, fcmToken, quietHoursStart, quietHoursEnd, defaultIntensity, defaultReminderTypes }
  └─ tasks/{taskId}: { title, details, deadline, isCompleted, intensity, reminderTypes, createdAt, userId }
```

## Setup Requirements
1. **Xcode 15+** with iOS 17 SDK
2. **Firebase project** created at console.firebase.google.com (Blaze plan)
3. **GoogleService-Info.plist** downloaded from Firebase Console into `TODO/Resources/`
4. **Firebase CLI** (`npm install -g firebase-tools`) for deploying Cloud Functions
5. **Apple Developer account** ($99/year) needed for App Store submission and APNs

## Commands
- Deploy Cloud Functions: `cd functions && npm run deploy`
- Install function dependencies: `cd functions && npm install`
- Build iOS: Open `TODO.xcodeproj` in Xcode, build with Cmd+B

## .gitignore Notes
- Never commit `GoogleService-Info.plist` (contains API keys)
- Never commit `.env` files in `functions/`
