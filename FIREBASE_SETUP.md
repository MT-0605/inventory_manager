# Firebase Setup Guide

## ✅ Completed Steps

1. **Android Configuration**: ✅ Done
   - Google Services JSON file added to `android/app/google-services.json`
   - Google Services plugin added to `android/app/build.gradle.kts`
   - Google Services classpath added to `android/build.gradle.kts`
   - Firebase options updated with your project configuration

2. **Firebase Project Details**:
   - Project ID: `inventorymanager-bc334`
   - Project Number: `646857113286`
   - Storage Bucket: `inventorymanager-bc334.firebasestorage.app`

## 🔧 Next Steps Required

### 1. Enable Firebase Services

Go to your [Firebase Console](https://console.firebase.google.com/project/inventorymanager-bc334) and enable:

#### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. Save the configuration

#### Firestore Database
1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location close to your users
5. Click **Done**

#### Storage (Optional)
1. Go to **Storage**
2. Click **Get started**
3. Choose **Start in test mode**
4. Select the same location as Firestore
5. Click **Done**

### 2. Deploy Firestore Security Rules

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project:
   ```bash
   cd /Users/chintankasundra/Documents/inventorymanager
   firebase init firestore
   ```

4. Deploy the security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### 3. iOS Configuration (Optional)

If you plan to run on iOS:

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` directory
3. Update the iOS app ID in `lib/firebase_options.dart` with the actual iOS app ID

### 4. Test the Application

1. Run the app:
   ```bash
   flutter run
   ```

2. Test the following features:
   - User registration/login
   - Adding products
   - Creating bills
   - Generating PDFs

## 🔒 Security Rules

The Firestore security rules are already configured in `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products - authenticated users can read/write
    match /products/{productId} {
      allow read, write: if request.auth != null;
    }
    
    // Bills - authenticated users can read/write
    match /bills/{billId} {
      allow read, write: if request.auth != null;
    }
    
    // Sales records - authenticated users can read/write
    match /sales/{saleId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🚀 Ready to Run!

Once you've completed the Firebase Console setup, your app should be ready to run with full Firebase integration!

## 📱 Testing Checklist

- [ ] User can register a new account
- [ ] User can login with existing account
- [ ] User can add/edit/delete products
- [ ] User can create bills and generate PDFs
- [ ] Analytics dashboard shows data
- [ ] All data persists in Firestore

## 🆘 Troubleshooting

If you encounter issues:

1. **Firebase not initialized**: Check that all services are enabled in Firebase Console
2. **Authentication errors**: Verify Email/Password is enabled in Authentication
3. **Database errors**: Check Firestore security rules and ensure they're deployed
4. **Build errors**: Run `flutter clean && flutter pub get`

## 📞 Support

If you need help with any of these steps, refer to the [Firebase Documentation](https://firebase.google.com/docs) or create an issue in the project repository.
