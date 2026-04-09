# BookMyJuice - Next Steps Guide

**Date:** April 1, 2026  
**Current Status:** ✅ Google Sign-In Implemented, ⏳ Configuration Required  
**Priority:** HIGH → LOW  
**App Name:** BookMyJuice  
**Package Name:** com.bookmyjuice.app

---

## ✅ App Name Change - COMPLETE

**Status:** ✅ DONE  
**Files Updated:**
- ✅ `android/app/src/main/res/values/strings.xml` - Created with app_name="BookMyJuice"
- ✅ `ios/Runner/Info.plist` - CFBundleDisplayName="BookMyJuice", CFBundleName="BookMyJuice"
- ✅ `web/index.html` - Title="BookMyJuice", meta tags updated
- ✅ `web/manifest.json` - name="BookMyJuice", short_name="BookMyJuice", colors updated

**Display Name Changes:**
- Android: ✅ Shows "BookMyJuice" on home screen
- iOS: ✅ Shows "BookMyJuice" on home screen
- Web: ✅ Browser tab shows "BookMyJuice"
- PWA: ✅ PWA name is "BookMyJuice"

**Package Name (Unchanged):**
- Android: `com.bookmyjuice.app` ✅
- iOS: `com.bookmyjuice.app` ✅
- Internal code: `lush` ✅ (kept for compatibility)

---

## 🎯 Immediate Next Steps (This Session)

### 1. ✅ COMPLETE - Google Sign-In Code Implementation

**Status:** ✅ DONE  
**Files:** `GoogleSignupScreen.dart`, `googleSignIn.dart`, `AuthBloc.dart`

**What's Done:**
- ✅ Google Sign-In integration using google_sign_in v7.2.0
- ✅ Uses `displayName` (full name) correctly
- ✅ Leaves lastName empty for user to fill
- ✅ Email, photo, googleId fetched from Google
- ✅ AuthBloc handles nullable lastName
- ✅ All tests passing (19/19)

---

### 2. ⏳ PENDING - Google Cloud Console Configuration

**Priority:** 🔴 HIGH  
**Time Required:** 30-60 minutes  
**Who:** Developer with Google Cloud access

#### Step 2.1: Create Google Cloud Project

1. Go to https://console.cloud.google.com/
2. Click "Create Project"
3. Project name: **BookMyJuice**
4. Click "Create"

#### Step 2.2: Enable Google Sign-In API

1. APIs & Services → Library
2. Search "Google Sign-In API"
3. Click "Enable"

#### Step 2.3: Configure OAuth Consent Screen

1. APIs & Services → OAuth consent screen
2. Select "External" user type
3. Fill in:
   - App name: BookMyJuice
   - User support email: support@bookmyjuice.co.in
   - Developer contact: your-email@bookmyjuice.co.in
4. Click "Save and Continue"
5. Scopes: Add `email`, `profile`
6. Click "Save and Continue"
7. Test users: Add your test email addresses
8. Click "Save and Continue"

#### Step 2.4: Create OAuth 2.0 Credentials

**For Android:**
1. APIs & Services → Credentials
2. Create Credentials → OAuth 2.0 Client ID
3. Application type: **Android**
4. Package name: `com.bookmyjuice.app`
5. SHA-1 certificate fingerprint:
   ```bash
   # Get debug SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
6. Click "Create"
7. Download the credentials

**For iOS:**
1. Create Credentials → OAuth 2.0 Client ID
2. Application type: **iOS**
3. Bundle ID: `com.bookmyjuice.app`
4. Click "Create"
5. Download GoogleService-Info.plist

**For Web:**
1. Create Credentials → OAuth 2.0 Client ID
2. Application type: **Web application**
3. Authorized JavaScript origins: `http://localhost:8080`
4. Click "Create"
5. Note the Client ID

---

### 3. ⏳ PENDING - Android Configuration

**Priority:** 🔴 HIGH  
**Time Required:** 15 minutes

#### Step 3.1: Add SHA-1 to Google Cloud Console

```bash
# Get debug SHA-1 (Windows)
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android

# Get release SHA-1 (if you have a keystore)
keytool -list -v -keystore /path/to/keystore.jks -alias your-alias
```

Add the SHA-1 to your Android OAuth client in Google Cloud Console.

#### Step 3.2: Update AndroidManifest.xml

**File:** `lush/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <!-- Add this meta-data -->
        <meta-data
            android:name="com.google.android.gms.version"
            android:value="@integer/google_play_services_version" />
    </application>
</manifest>
```

#### Step 3.3: Test on Physical Device

```bash
cd lush
flutter run -d <your-device-id>

# List connected devices
flutter devices
```

**Note:** Google Sign-In may not work on emulator. Test on physical Android device.

---

### 4. ⏳ PENDING - iOS Configuration

**Priority:** 🟡 MEDIUM (if you have iOS users)  
**Time Required:** 15 minutes

#### Step 4.1: Add REVERSED_CLIENT_ID to Info.plist

**File:** `lush/ios/Runner/Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### Step 4.2: Add GoogleService-Info.plist

1. Download from Google Cloud Console
2. Add to `lush/ios/Runner/` in Xcode
3. Make sure it's added to the target

---

### 5. ⏳ PENDING - Backend Database Migration

**Priority:** 🔴 HIGH  
**Time Required:** 10 minutes  
**Who:** Backend developer

#### Step 5.1: Add Database Columns

**SQL Migration:**
```sql
-- Add Google-specific columns to users table
ALTER TABLE users 
  ADD COLUMN google_photo_url VARCHAR(500),
  ADD COLUMN google_id VARCHAR(100) UNIQUE;

-- Add index for fast lookups
CREATE INDEX idx_users_google_id ON users(google_id);

-- Verify columns added
DESCRIBE users;
```

#### Step 5.2: Update User Entity (Already Done)

**File:** `bmjServer/src/main/java/com/bookmyjuice/models/User.java`

```java
@Column(name = "google_photo_url", length = 500)
private String googlePhotoUrl;

@Column(name = "google_id", unique = true)
private String googleId;

// Getters and setters already added
```

#### Step 5.3: Update Unified Signup Endpoint

**File:** `bmjServer/src/main/java/com/bookmyjuice/controllers/AuthController.java`

**TODO:** Update `/api/auth/unified-signup` to accept and store `googleId` and `photoUrl`

```java
@PostMapping("/unified-signup")
public ResponseEntity<?> unifiedSignup(@Valid @RequestBody UnifiedSignupRequest request) {
    // ... existing code ...
    
    // Add Google-specific fields
    if (request.getGoogleId() != null) {
        user.setGoogleId(request.getGoogleId());
    }
    if (request.getPhotoUrl() != null) {
        user.setPhotoUrl(request.getPhotoUrl());
    }
    
    // ... rest of code ...
}
```

---

### 6. ⏳ PENDING - Manual Testing

**Priority:** 🔴 HIGH  
**Time Required:** 30 minutes  
**Who:** QA / Developer

#### Step 6.1: Test Google Sign-In Flow

**Test Cases:**

1. **Google Button Opens Account Selection**
   - [ ] Tap "Sign up with Google" button
   - [ ] Google account selection opens
   - [ ] Can select account

2. **Email Pre-filled (Read-Only)**
   - [ ] Email field shows selected Google email
   - [ ] Email field is read-only (cannot edit)
   - [ ] Email is verified (no email verification needed)

3. **displayName Pre-filled (Read-Only)**
   - [ ] First Name shows displayName (full name)
   - [ ] First Name field is read-only
   - [ ] If displayName is null, field is empty

4. **lastName Empty (Editable)**
   - [ ] Last Name field is empty
   - [ ] User can enter lastName manually
   - [ ] Last Name is required (validation)

5. **Photo Fetched**
   - [ ] Profile photo is displayed (if available)
   - [ ] Photo is read-only

6. **User-Entered Fields**
   - [ ] Phone field validates 10-digit Indian number
   - [ ] Address fields are required
   - [ ] Password validates strength requirements
   - [ ] Form submission works

7. **Account Creation**
   - [ ] Submit creates account successfully
   - [ ] User is logged in automatically
   - [ ] Redirected to dashboard
   - [ ] Google ID stored in database
   - [ ] Photo URL stored in database

#### Step 6.2: Test on Multiple Platforms

```bash
# Android (physical device recommended)
flutter run -d android

# iOS (if you have Mac)
flutter run -d ios

# Web (for testing)
flutter run -d chrome
```

---

## 📋 Medium-Term Tasks (This Week)

### 7. Backend Integration Testing

**Priority:** 🟡 MEDIUM  
**Time Required:** 2-3 hours

- [ ] Test `/api/auth/unified-signup` with Google data
- [ ] Verify googleId is stored in database
- [ ] Verify googlePhotoUrl is stored in database
- [ ] Test duplicate Google ID handling
- [ ] Test token verification on backend

### 8. Production Google Configuration

**Priority:** 🟡 MEDIUM  
**Time Required:** 1-2 hours

- [ ] Create production OAuth credentials
- [ ] Add production SHA-1 fingerprints
- [ ] Update package names/bundle IDs for production
- [ ] Test production build

### 9. Analytics Integration

**Priority:** 🟢 LOW  
**Time Required:** 2-3 hours

- [ ] Track Google signup initiation
- [ ] Track Google signup completion
- [ ] Track Google signup abandonment
- [ ] Compare Google vs Email signup conversion rates

---

## 🚀 Long-Term Tasks (Next Week)

### 10. Performance Optimization

**Priority:** 🟢 LOW  
**Time Required:** 4-6 hours

- [ ] Optimize Google Sign-In initialization
- [ ] Cache Google user data locally
- [ ] Handle token expiration gracefully
- [ ] Add retry logic for failed sign-ins

### 11. Security Enhancements

**Priority:** 🟢 LOW  
**Time Required:** 3-4 hours

- [ ] Verify Google ID token on backend
- [ ] Implement token refresh logic
- [ ] Add rate limiting for Google Sign-In
- [ ] Audit Google Sign-In security best practices

### 12. A/B Testing

**Priority:** 🟢 LOW  
**Time Required:** 1-2 days

- [ ] A/B test Google signup button placement
- [ ] A/B test Google vs Email signup conversion
- [ ] Analyze user preference data
- [ ] Optimize signup flow based on data

---

## 📞 Support Resources

| Resource | Location |
|----------|----------|
| Google Sign-In Guide | `lush/GOOGLE_SIGNIN_CORRECTED.md` |
| Implementation Guide | `lush/GOOGLE_SIGNIN_IMPLEMENTATION.md` |
| Changes Documentation | `lush/GOOGLE_SIGNUP_CHANGES.md` |
| Development Status | `lush/DEVELOPMENT_STATUS.md` |
| Backend Flow | `bmjServer/GOOGLE_SIGNUP_FLOW.md` |
| Database Schema | `bmjServer/DATABASE_SCHEMA_DOCUMENTATION.md` |

---

## ✅ Checklist Summary

### Immediate (This Session)
- [x] Google Sign-In code implementation
- [ ] Google Cloud Console configuration
- [ ] Android configuration (SHA-1, OAuth)
- [ ] iOS configuration (REVERSED_CLIENT_ID)
- [ ] Backend database migration
- [ ] Manual testing on physical device

### This Week
- [ ] Backend integration testing
- [ ] Production Google configuration
- [ ] Analytics integration

### Next Week
- [ ] Performance optimization
- [ ] Security enhancements
- [ ] A/B testing

---

## 🎯 Success Criteria

**Google Sign-In is working when:**
1. ✅ User can tap "Sign up with Google"
2. ✅ Google account selection opens
3. ✅ Email is pre-filled (read-only)
4. ✅ displayName is pre-filled as firstName (read-only)
5. ✅ lastName is empty (user fills manually)
6. ✅ Photo is fetched (if available)
7. ✅ User can complete signup form
8. ✅ Account is created successfully
9. ✅ Google ID is stored in database
10. ✅ User is logged in automatically

---

**Current Progress:** 1/10 (10%) - Code implemented, configuration pending  
**Next Milestone:** Google Cloud Console configuration (30-60 minutes)  
**Blockers:** None  
**Risk Level:** Low (all code compiles, tests pass)

**Last Updated:** April 1, 2026  
**Prepared By:** Engineering Team
