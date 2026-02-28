# PeerPicks

PeerPicks is a modern, location-aware social review platform where users discover places, post picks, interact with community content, and personalize their app experience with smart device features.

The project includes:
- A Flutter mobile app (this folder)
- A Node.js backend API (sibling folder: ../server)

---

## Project Highlights

- Community-driven place picks and reviews
- Discovery feed with media-rich posts
- Authentication with secure session handling
- Social interactions: votes, favorites, comments, follow/unfollow
- Profile management and user activity views
- Nearby picks using location services
- Notification support
- Smart sensor features:
  - Shake to refresh
  - Tilt to open latest pick
  - Ambient light based auto-theme
- Biometric sign-in support (Face ID / Fingerprint) when enabled

---

## Tech Stack

### Mobile App
- Flutter (Dart)
- Riverpod for state management
- Dio for API networking
- SharedPreferences + Secure Storage for session data
- Sensors and device integrations (location, brightness, motion, biometrics)

### Backend API
- Node.js + TypeScript
- Express
- Database connection via server configuration

---

## Repository Structure

This workspace commonly contains:

- peerpicks/           Flutter mobile app
- server/              Backend API
- client/              Web/Next.js client (optional in this setup)

---

## Prerequisites

Install these before running:

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Android Studio and/or Xcode (for mobile builds)
- Node.js (LTS recommended)
- npm
- A running backend database configured for the server

---

## Clone the Project

1. Clone repository

	git clone <your-repository-url>

2. Move into workspace

	cd dev

---

## Backend Setup (Server)

1. Go to backend folder

	cd server

2. Install dependencies

	npm install

3. Configure environment variables

	Create a .env file in server/ and set required values (database URL, JWT secret, port, etc.).

4. Start backend

	npm run dev

5. Confirm server is reachable on your machine and LAN

	Example: http://<your-local-ip>:3000

---

## Mobile Setup (Flutter App)

1. Go to app folder

	cd peerpicks

2. Install Flutter packages

	flutter pub get

3. Configure API host in app

	Update file: lib/core/api/api_endpoints.dart

	For physical device testing, set:
- isPhysicalDevice = true
- compIpAddress = your machine LAN IP (same network as phone)

4. Run app

	flutter run

---

## Run on Physical Device

To connect your phone to local backend:

1. Phone and development machine must be on the same Wi-Fi.
2. Backend must listen on 0.0.0.0 and correct port.
3. App base URL must use LAN IP (not localhost).
4. Android cleartext HTTP access must be enabled for local development if using http.

If calls fail:
- Verify server is running.
- Verify LAN IP has not changed.
- Test port reachability from machine and network.

---

## Feature Notes

### Biometric Sign-In
- Users can enable or disable biometric sign-in from Settings.
- First successful credential login stores secure credentials for biometric unlock.
- Normal logout clears active session but can preserve biometric credentials for next sign-in.

### Sensor-Based Smart UX
- Ambient light can switch light/dark theme automatically.
- Shake and tilt gestures are configurable in settings.

---

## Common Commands

### Flutter App
- flutter pub get
- flutter run
- flutter analyze
- flutter test

### Backend
- npm install
- npm run dev
- npm test

---

## Troubleshooting

- App not hitting backend on device:
  - Use LAN IP instead of localhost.
  - Check firewall/port access.
  - Ensure backend and app are on same network.

- Biometric button not showing:
  - Enable biometric option in Settings.
  - Ensure device has biometrics configured.
  - Ensure credentials were saved by at least one successful login.

- Sensor features feel inconsistent:
  - Confirm relevant toggles are enabled in Settings.
  - Test on real device (some emulators provide limited sensor data).

---

## Credits and Attribution

If you use this project, or any substantial part of it, in your own app, course project, publication, or portfolio, please provide clear credit.

Recommended attribution:

Based on PeerPicks project by the original contributors.

Please include attribution in at least one of the following:
- Your project README
- App about page
- Documentation or report

If you adapt or extend this project, mention what was changed from the original codebase.

---

## License

Add your license information here (for example MIT, Apache-2.0, or private/internal use).

