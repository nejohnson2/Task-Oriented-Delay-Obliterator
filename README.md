# T.O.D.O — Task-Oriented Delay Obliterator

A native iOS app that fights procrastination through smart, escalating reminders. Instead of a single reminder you'll ignore, T.O.D.O sends randomized nudges that increase in frequency and urgency as your deadline approaches. You control the intensity — from a gentle tap on the shoulder to a relentless barrage that makes it harder to procrastinate than to just do the thing.

## Why I Built This

Every productivity app lets you set a reminder. One notification pops up, you swipe it away, and nothing changes. T.O.D.O takes a different approach: reminders are **random and escalating**. The closer you get to a deadline, the more aggressively the app reminds you — and because the timing is unpredictable, you can't just tune it out. The intensity is fully configurable per task (1–10 scale), so you decide how hard each task pushes back against your procrastination.

## How It Works

1. **Create a task** with a title, deadline, and intensity level (1–10)
2. **Choose reminder channels** — push notifications, email, or both
3. **T.O.D.O does the rest** — reminders arrive at random intervals that increase as the deadline approaches
4. **Mark it done** when you're finished and the reminders stop

### The Reminder Algorithm

Reminder frequency follows an exponential curve based on time remaining and your chosen intensity:

- **7+ days out:** Occasional nudges (1–2/day at intensity 5)
- **2–3 days out:** Noticeable increase (5–8/day at intensity 5)
- **Under 24 hours:** Aggressive (10–20/day at intensity 10)
- **Overdue:** Maximum frequency until you complete the task

The Cloud Function runs every 15 minutes, calculates a probability for each task based on `intensity * (1 / hoursRemaining) * scaleFactor`, and rolls the dice. Quiet hours (default 10 PM – 8 AM, configurable) are always respected.

## Features

- Email/password authentication
- Task management with deadlines, details, and per-task intensity
- Escalating random reminders via push notifications and email
- Configurable quiet hours (no reminders while you sleep)
- Overdue task tracking with visual indicators
- Collapsible completed tasks section
- Account deletion (App Store requirement)
- Local notification fallback when offline

## Tech Stack

| Layer | Technology |
|---|---|
| **UI** | SwiftUI (iOS 17+) |
| **Auth** | Firebase Authentication (email/password) |
| **Database** | Cloud Firestore |
| **Push Notifications** | APNs + Firebase Cloud Messaging (FCM) |
| **Email Reminders** | Firebase Trigger Email extension |
| **Backend Logic** | Firebase Cloud Functions (Node.js / TypeScript) |
| **Hosting** | Firebase Blaze plan (pay-as-you-go) |

## Project Structure

```
TODO/                              # iOS app (SwiftUI)
├── App/
│   ├── TODOApp.swift              # Entry point, Firebase init, auth routing
│   └── AppDelegate.swift          # Push notification registration
├── Models/
│   └── TaskItem.swift             # Task model, UserProfile, ReminderType
├── ViewModels/
│   ├── AuthViewModel.swift        # Auth state management
│   ├── TaskViewModel.swift        # Task CRUD + real-time sync
│   └── SettingsViewModel.swift    # User preferences
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift        # Sign in + forgot password
│   │   └── SignUpView.swift       # Registration
│   ├── Tasks/
│   │   ├── TaskListView.swift     # Main screen
│   │   ├── TaskRowView.swift      # Task row with intensity dots
│   │   └── TaskEditView.swift     # Add/edit task sheet
│   └── Settings/
│       └── SettingsView.swift     # Quiet hours, defaults, account
└── Services/
    ├── FirestoreService.swift     # Firestore operations
    └── NotificationService.swift  # FCM + local notifications

functions/                         # Firebase Cloud Functions
├── src/
│   ├── index.ts                   # Scheduled function entry point
│   ├── reminderScheduler.ts       # Core reminder algorithm
│   ├── notifications.ts           # FCM + email delivery
│   └── templates.ts               # Randomized reminder messages
├── package.json
└── tsconfig.json
```

## Setup

### Prerequisites

- Xcode 15+ with iOS 17 SDK
- A Firebase project on the [Blaze plan](https://console.firebase.google.com)
- Node.js 18+ and Firebase CLI (`npm install -g firebase-tools`)
- Apple Developer account ($99/year) for push notifications and App Store

### iOS App

1. Clone this repo
2. Create a Firebase project and enable **Email/Password** authentication
3. Create a Cloud Firestore database
4. Download `GoogleService-Info.plist` from Firebase Console and add it to `TODO/TODO/`
5. Open `TODO/TODO.xcodeproj` in Xcode
6. Build and run (Cmd+R)

### Cloud Functions

```bash
cd functions
npm install
firebase login
firebase deploy --only functions
```

### Push Notifications

1. Generate an APNs key in the [Apple Developer Portal](https://developer.apple.com)
2. Upload the key to Firebase Console → Project Settings → Cloud Messaging
3. Enable Push Notifications capability in Xcode

## Firestore Schema

```
users/{userId}/
  ├── profile/settings    # email, fcmToken, quietHours, defaults
  └── tasks/{taskId}      # title, details, deadline, intensity, reminderTypes
```

## License

All Rights Reserved. See [LICENSE](LICENSE) for details. Source code is available for viewing and educational reference only.
