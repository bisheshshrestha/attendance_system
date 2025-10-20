# Attendance System

A Flutter-based mobile application prototype for managing employee attendance, built as part of the Week 2 deliverable for Excelerate’s internship program.

## GitHub Repository
https://github.com/bisheshshrestha/attendance_system

## Figma Design Reference
https://www.figma.com/design/fi74eVFunD5W6aqUe3Yx5W/Attendance_System?node-id=0-1&p=f&t=Mc6mkLfQ4tXU1rWc-0

---

## Week 2 Deliverables

1. **Login Screen**
    - Demo validation for `user@gmail.com` / `user123`
    - Error message on invalid input
    - Navigation to dashboard on success

2. **Home Screen (Dashboard)**
    - Attendance status card with circular progress indicator
    - Quick action buttons (Leave, News, Team, Report)
    - Schedule list of upcoming meetings

3. **Program Listing Screen (Meeting Calendar)**
    - Interactive calendar (TableCalendar)
    - Date selector header
    - List of meetings for selected date

4. **Program Details Screen (Profile & Settings)**
    - User profile view with logout
    - Settings page with various options and logout

5. **Navigation**
    - BottomNavigationBar to switch between Dashboard, Meeting, Profile, and Settings
    - Persistent navigation state
    - Logout clears navigation stack back to login page

6. **Screenshots**
    - Include screenshots of each screen under `screenshots/` directory

---

## Project Structure

```text
lib/
├── main.dart                  # App entry point and routes
├── login_page.dart            # Login screen with validation
├── main_navigation_page.dart  # Bottom navigation host
├── userdashboard_page.dart    # Dashboard screen
├── meeting_page.dart          # Meeting calendar screen
├── profile_page.dart          # Profile screen
├── settings_page.dart         # Settings screen
└── shared_pref.dart           # Shared preferences helper
```

---

## Setup Instructions

1. Clone the repository:
   ```bash
git clone https://github.com/bisheshshrestha/attendance_system.git
cd attendance_system
```

2. Install dependencies:
   ```bash
flutter pub get
```

3. Run the app:
   ```bash
flutter run
```

Demo credentials for login:
- Email: `user@gmail.com`
- Password: `user123`

```

## Screenshots

- **Login Screen**  
  ![Login Screen](screenshots/login%20page.jpeg)

- **Home Dashboard**  
  ![Dashboard](screenshots/dashboard%20page.jpeg)

- **Meeting Calendar**  
  ![Meeting](screenshots/meeting%20page.jpeg)

- **Profile**  
  ![Profile](screenshots/profile%20page.jpeg)

- **Settings**  
  ![Settings](screenshots/setting%20page.jpeg)


## Next Steps (Week 3)

- Integrate Firebase authentication and real backend  
- Implement check-in/check-out  
- Add push notifications for reminders
