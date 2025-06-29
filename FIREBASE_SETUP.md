# Firebase Setup Guide

## 🔥 Firebase Configuration

### **Project Setup:**
Both the **mobile app** and **admin dashboard** use the same Firebase project for data consistency.

### **Configuration Files:**
- `ifound_app/lib/firebase_options.dart` - Mobile app configuration
- `admin_dashboard/lib/firebase_options.dart` - Admin dashboard configuration

### **How to Set Up Firebase:**

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project
   - Enable Authentication, Firestore, and Storage

2. **Configure Mobile App:**
   ```bash
   cd ifound_app
   flutterfire configure
   ```

3. **Configure Admin Dashboard:**
   ```bash
   cd admin_dashboard
   flutterfire configure
   ```
   *Select the same Firebase project as the mobile app*

4. **Set Up Security Rules:**
   - Configure Firestore security rules
   - Set up Storage security rules
   - Enable Authentication methods

### **Services Used:**
- **Firestore Database** - User data, reports, analytics
- **Firebase Authentication** - User login/registration
- **Firebase Storage** - File uploads
- **Firebase Cloud Messaging** - Push notifications

### **Security Notes:**
- API keys in `firebase_options.dart` are **public keys** (safe for client-side use)
- **Never commit** service account keys or admin credentials
- Use Firebase security rules to control data access
- All sensitive data is protected by Firebase's built-in security

### **Troubleshooting:**
- Ensure Firebase project ID matches in both apps
- Check that all required services are enabled
- Verify security rules are properly configured
- Test authentication flow in both apps

---

**For detailed security information, see SECURITY_SUMMARY.md** 