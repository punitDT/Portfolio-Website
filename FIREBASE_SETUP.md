# Firebase Setup Guide for Portfolio Admin

## 1. Firebase Project Configuration

Your Firebase project ID is: `portfolio-c1274`

### Steps to get your Firebase configuration:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `portfolio-c1274`
3. Click on the gear icon (Project Settings)
4. Scroll down to "Your apps" section
5. If you don't have a web app, click "Add app" and select Web
6. Copy the Firebase configuration object

### 2. Update Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
        apiKey: "AIzaSyAPhc5SNg1acyT_D_jo4edQD43PeR8GbZs",
        authDomain: "portfolio-c1274.firebaseapp.com",
        projectId: "portfolio-c1274",
        storageBucket: "portfolio-c1274.appspot.com",
        messagingSenderId: "40081637330",
        appId: "1:40081637330:web:5e49ab59e5f0755823120b"
);
```

### 3. Enable Firebase Services

In your Firebase Console, enable these services:

#### Authentication:
1. Go to Authentication > Sign-in method
2. Enable "Email/Password" provider
3. Save changes

#### Firestore Database:
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

#### Storage (Optional):
1. Go to Storage
2. Click "Get started"
3. Choose "Start in test mode"
4. Select the same location as Firestore
5. Click "Done"

### 4. Security Rules

#### Firestore Rules (for development):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to projects and services for all users
    match /projects/{document} {
      allow read: if true;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/admin_users/$(request.auth.uid));
    }
    
    match /services/{document} {
      allow read: if true;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/admin_users/$(request.auth.uid));
    }
    
    match /content/{document} {
      allow read: if true;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/admin_users/$(request.auth.uid));
    }
    
    // Admin users collection - only authenticated users can read their own data
    match /admin_users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Storage Rules (if using Storage):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/admin_users/$(request.auth.uid));
    }
  }
}
```

### 5. Admin Account Setup

Admin account should be created manually in Firebase Console:
- **Email**: `punit.mece@gmail.com`
- **Password**: Set securely in Firebase Console

**IMPORTANT**: Never hardcode passwords in your application code!

### 6. Production Security

For production deployment:

1. **Change Admin Credentials**:
   - Create a new admin account with a strong password
   - Delete or disable the demo account

2. **Update Security Rules**:
   - Implement proper role-based access control
   - Add rate limiting
   - Validate data structure

3. **Environment Variables**:
   - Store sensitive configuration in environment variables
   - Use different Firebase projects for development and production

### 7. Testing the Setup

1. Run the app: `flutter run -d chrome`
2. Navigate to `/admin/login`
3. Use the demo credentials to log in
4. Check if you can access the admin dashboard
5. Try adding a test project

### 8. Troubleshooting

**Common Issues**:

1. **Firebase not initialized**: Make sure Firebase configuration is correct
2. **Authentication failed**: Check if Email/Password provider is enabled
3. **Permission denied**: Verify Firestore security rules
4. **CORS errors**: Make sure your domain is authorized in Firebase Console

**Debug Steps**:
1. Check browser console for errors
2. Verify Firebase project settings
3. Test authentication in Firebase Console
4. Check Firestore data in Firebase Console

### 9. Next Steps

After basic setup:
1. Customize the admin dashboard
2. Add more content management features
3. Implement image upload functionality
4. Add analytics and monitoring
5. Set up automated backups

## Support

If you encounter issues:
1. Check the browser console for errors
2. Verify all Firebase services are enabled
3. Ensure security rules are properly configured
4. Test with the demo credentials first
