# iFound

A cross-platform Flutter app for reporting and finding lost documents, with Firebase authentication, Firestore, and localization (English, French, Kinyarwanda).

---

## 📦 GitHub Repository
[GitHub Repo Link](https://github.com/Ynthia16/iFound-project.git)

---

## 🚀 Description
**iFound** helps users report lost or found documents and connect with others securely. Features include:
- Email/password & Google authentication
- Multi-language support (EN, FR, RW)
- Firestore for lost/found reports
- Feedback wall
- Modern, responsive UI
- Dark mode toggle

---

## 🛠️ Setup Instructions
1. **Clone the repository:**
   ```sh
   git clone https://github.com/Ynthia16/iFound-project.git
   cd ifound-app/iFound_Project/ifound_app
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Firebase setup:**
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS/web apps as needed and download the config files (`google-services.json`, `GoogleService-Info.plist`, etc.)
   - Place config files in the appropriate directories.
   - Enable Email/Password and Google sign-in in Firebase Authentication.
   - Enable Firestore in Firebase.
4. **Localization:**
   - No extra steps needed; translations are in `assets/en.json`, `assets/fr.json`, `assets/rw.json`.
5. **Run the app:**
   ```sh
   flutter run
   ```

---

## 🎨 Designs & Screenshots
- Circuit Diagram: *Please refer to the assets folder and screenshoots folder in there, you can find the screenshoots of screens and the ERD diagram*

---

## 🚢 Deployment Plan
- **Web:** Deploy with [Firebase Hosting](https://firebase.google.com/docs/hosting) or [Vercel](https://vercel.com/).
- **Mobile:** Build APK/IPA and distribute via Play Store/TestFlight or direct download.
- **Environment:**
  - Flutter 3.x
  - Firebase (Auth, Firestore, Storage)
  - Easy Localization

---

## 🎥 Video Demo
- [Demo Video Link](https://drive.google.com/file/d/1SiFyUFd1JTaOgQ84xhDf8c2lHNyHEzbM/view?usp=drive_link)

---

## 📂 Code Files
- All main code is in `lib/`
- Assets in `assets/`
- Firebase configs in platform folders

---

**Focus:**
- This README is focused on demonstrating the app's setup and features.
- For any questions, please reach out
- Thank you so much
