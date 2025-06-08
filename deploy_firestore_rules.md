# Deploy Firestore Rules

## Quick Fix for Authorization Error

The "user is not authorized to perform this action" error is likely due to Firestore security rules not being deployed or being too restrictive.

## Option 1: Deploy Rules via Firebase CLI

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase in your project** (if not already done):
   ```bash
   firebase init firestore
   ```
   - Select your Firebase project
   - Choose `firestore.rules` as your rules file
   - Choose `firestore.indexes.json` as your indexes file

4. **Deploy the rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

## Option 2: Deploy Rules via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `portfolio-c1274`
3. Go to **Firestore Database** → **Rules**
4. Replace the existing rules with the content from `firestore.rules`
5. Click **Publish**

## Option 3: Use Very Permissive Rules (Development Only)

If you're still having issues, temporarily use these ultra-permissive rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Verification

After deploying rules, test by:
1. Going to admin dashboard
2. Clicking "Firebase Status" button
3. Trying to create/update a project

## Troubleshooting

If you still get authorization errors:

1. **Check Authentication**: Make sure you're logged in with `punit.mece@gmail.com`
2. **Check Project ID**: Verify the Firebase project ID matches in `firebase_options.dart`
3. **Check Rules**: Ensure rules are deployed and active
4. **Clear Browser Cache**: Sometimes cached auth tokens cause issues

## Current Rules Status

The current `firestore.rules` file has been updated to be very permissive for development:
- Allows all read/write operations
- No authentication required
- Should resolve authorization issues

Remember to tighten these rules for production!
