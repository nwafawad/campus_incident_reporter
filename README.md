# CampusCare

A Flutter app for reporting and tracking campus maintenance and safety incidents at ALU Kigali (Bumbogo). Students report problems such as a broken light or a leaking tap, and staff triage them and update their status.

## Features

**Students**
- Sign up with an `@alustudent.com` email and verify it before using the app
- Report an incident with a title (max 60 characters), description (max 500), category, urgency, campus zone and area, and up to 3 photos (5 MB each)
- Option to report anonymously, or hide your name by default
- Browse all reports, filter them, and use "Me too" to say you're affected by one
- Follow each report's status timeline
- Edit or delete your own report while it is still *Submitted*

**Staff** (`@alueducation.com`)
- Queue of all reports, filterable by building
- Update a report's status: Submitted, In progress, Resolved or Not actionable
- Each status change is added to the report's timeline
- Reports not resolved within 5 days are flagged as overdue

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart SDK ^3.13.2) |
| State management | `provider` |
| Auth | Firebase Authentication (email and password, with email verification) |
| Database | Cloud Firestore |
| Photo storage | Cloudinary (unsigned upload preset) |
| Other packages | `image_picker`, `http`, `intl` |

## Project structure

```
lib/
├── main.dart            # Firebase init, providers, AuthGate
├── firebase_options.dart
├── models/              # AppUser, Incident
├── providers/           # Auth, incident list, report form state
├── services/            # Auth, Firestore incidents, Cloudinary uploads
├── screens/             # Login, register, verify email, home, reports,
│                        # report form, details, profile, staff queue
├── widgets/             # Reusable UI (cards, chips, filters, timeline, ...)
├── theme/               # Colors and app theme
└── utils/               # Constants (categories, campus zones), validators
firestore.rules          # Firestore security rules
```

`AuthGate` in `main.dart` picks the screen from the auth state: loading, signed out (login), unverified (verify email) or signed in (main shell with bottom navigation).

## Roles and security

A user's role comes from their email domain: `@alueducation.com` is staff and everything else is a student. `firestore.rules` enforces this on the server using the verified sign-in token, not a field the client can set.

- Only verified `@alustudent.com` and staff emails can read reports
- Reporters can edit or delete their own report only while its status is `submitted`
- Anyone verified can add or remove only their own ID in `affectedBy` ("Me too")
- Only staff can change `status` or add entries to a report's `updates` timeline

> **Note:** `nwafawad49@gmail.com` is hard-coded as a demo staff account in both `lib/utils/constants.dart` and `firestore.rules`. Remove it before any real use.

## Getting started

### Prerequisites
- Flutter SDK (Dart ^3.13.2)
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled
- A [Cloudinary](https://cloudinary.com) account with an **unsigned** upload preset

### Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Connect Firebase (regenerates `lib/firebase_options.dart`):
   ```bash
   flutterfire configure
   ```
3. Set your Cloudinary details in `lib/utils/constants.dart`:
   ```dart
   const cloudinaryCloudName = 'your-cloud-name';
   const cloudinaryUploadPreset = 'your-unsigned-preset';
   ```
4. Deploy the security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Data model (Firestore)

- `users/{uid}`: `name`, `email`, `role` (`student` or `staff`), `hideNameByDefault`
- `incidents/{id}`: `title`, `description`, `category`, `urgency` (`low`, `medium`, `high`), `zone`, `area`, `landmark`, `photoUrls`, `status` (`submitted`, `inProgress`, `resolved`, `notActionable`), `reporterId`, `reporterName`, `anonymous`, `affectedBy`, `createdAt`, `updatedAt`
  - `updates/{updateId}`: `status`, `note`, `staffName`, `createdAt` (added by staff)
