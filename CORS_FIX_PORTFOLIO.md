# Fix CORS for https://portfolio-c1274.web.app

## Problem
Your deployed app at `https://portfolio-c1274.web.app` cannot access Firebase Storage images due to CORS policy blocking the requests.

## Quick Solution

### Option 1: Automated Fix (Recommended)

**On Windows:**
```cmd
fix-cors.bat
```

**On Mac/Linux:**
```bash
chmod +x fix-cors.sh
./fix-cors.sh
```

### Option 2: Manual Commands

1. **Install Google Cloud SDK** (if not installed):
   - Download: https://cloud.google.com/sdk/docs/install

2. **Authenticate and set project:**
   ```bash
   gcloud auth login
   gcloud config set project portfolio-c1274
   ```

3. **Apply CORS configuration:**
   ```bash
   gsutil cors set cors.json gs://portfolio-c1274.appspot.com
   ```

4. **Make bucket publicly readable:**
   ```bash
   gsutil iam ch allUsers:objectViewer gs://portfolio-c1274.appspot.com
   ```

5. **Verify configuration:**
   ```bash
   gsutil cors get gs://portfolio-c1274.appspot.com
   ```

### Option 3: Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `portfolio-c1274`
3. Navigate to **Cloud Storage** → **Buckets**
4. Click on `portfolio-c1274.appspot.com`
5. Go to **Permissions** tab
6. Click **Grant Access**
7. Add principal: `allUsers`
8. Select role: **Cloud Storage** → **Storage Object Viewer**
9. Click **Save**

## What This Does

✅ **Allows CORS requests** from `https://portfolio-c1274.web.app`  
✅ **Enables public read access** to Firebase Storage images  
✅ **Includes proper headers** for image loading  
✅ **Supports both Firebase domains** (.web.app and .firebaseapp.com)  

## Expected Result

After applying the fix, your CORS configuration will look like:
```json
[
  {
    "origin": [
      "https://portfolio-c1274.web.app",
      "https://portfolio-c1274.firebaseapp.com"
    ],
    "method": ["GET", "HEAD", "OPTIONS"],
    "maxAgeSeconds": 3600,
    "responseHeader": [
      "Content-Type",
      "Access-Control-Allow-Origin",
      "Access-Control-Allow-Methods",
      "Access-Control-Allow-Headers",
      "Access-Control-Max-Age",
      "Cache-Control",
      "Content-Disposition",
      "Content-Encoding",
      "Content-Language",
      "Content-Range",
      "Date",
      "ETag",
      "Expires",
      "Last-Modified"
    ]
  }
]
```

## Testing

1. **Wait 5-10 minutes** for changes to propagate
2. **Clear browser cache** completely
3. **Open your app**: https://portfolio-c1274.web.app
4. **Check browser console** - CORS errors should be gone
5. **Verify images load** properly

## Troubleshooting

If images still don't load:

1. **Check bucket permissions:**
   ```bash
   gsutil iam get gs://portfolio-c1274.appspot.com
   ```

2. **Try permissive CORS (temporary):**
   ```bash
   gsutil cors set cors-permissive.json gs://portfolio-c1274.appspot.com
   ```

3. **Verify storage rules are deployed:**
   ```bash
   firebase deploy --only storage
   ```

4. **Test individual image URL** in browser:
   - Copy an image URL from the error
   - Open it directly in browser
   - Should load without issues

## Firebase Storage Rules

Make sure your `storage.rules` allows public read:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

Deploy with:
```bash
firebase deploy --only storage
```

## Success Indicators

✅ No CORS errors in browser console  
✅ Images load properly on https://portfolio-c1274.web.app  
✅ `gsutil cors get` shows your domain in allowed origins  
✅ `gsutil iam get` shows `allUsers` has `objectViewer` role  

This should completely resolve your CORS issue and allow your portfolio website to display Firebase Storage images properly!
