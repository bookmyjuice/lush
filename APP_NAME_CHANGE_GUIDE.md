# BookMyJuice App Name Change Guide

**Date:** April 1, 2026  
**Current Name:** lush  
**New Name:** BookMyJuice (or bookmyjuice)  
**Priority:** MEDIUM  
**Time Required:** 2-3 hours

---

## ⚠️ Important Notes

### Before You Start

1. **This is a breaking change** - All existing installations will need to reinstall
2. **Package name change** - If you change the package name, it's a different app to Android/iOS
3. **Recommendation** - Keep internal name as 'lush' for code, only change display name to 'BookMyJuice'

### Recommended Approach

**Option 1: Change Display Name Only (RECOMMENDED)**
- ✅ Keep package name as `com.bookmyjuice.app`
- ✅ Keep internal code name as `lush`
- ✅ Only change the app display name that users see
- ✅ No breaking changes for existing users

**Option 2: Change Everything (NOT RECOMMENDED)**
- ❌ Change package name
- ❌ Change all imports
- ❌ Breaks existing installations
- ❌ Requires new app store listing

---

## ✅ Option 1: Change Display Name Only (RECOMMENDED)

### Step 1: Update Android App Name

**File:** `lush/android/app/src/main/res/values/strings.xml`

```xml
<resources>
    <string name="app_name">BookMyJuice</string>
</resources>
```

### Step 2: Update iOS App Name

**File:** `lush/ios/Runner/Info.plist`

```xml
<key>CFBundleName</key>
<string>BookMyJuice</string>
<key>CFBundleDisplayName</key>
<string>BookMyJuice</string>
```

### Step 3: Update Web App Name

**File:** `lush/web/index.html`

```html
<head>
  <title>BookMyJuice</title>
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="BookMyJuice">
</head>
```

### Step 4: Update Documentation

Update all documentation to reflect the display name:
- ✅ `NEXT_STEPS.md` - Already updated
- ✅ `GOOGLE_SIGNIN_IMPLEMENTATION.md` - Already uses BookMyJuice
- ✅ All other docs - Already use BookMyJuice

---

## ❌ Option 2: Change Package Name (NOT RECOMMENDED)

If you still want to change the package name from `com.bookmyjuice.app` to something else, follow these steps:

### Step 1: Update pubspec.yaml

**File:** `lush/pubspec.yaml`

```yaml
name: bookmyjuice  # Change from 'lush' to 'bookmyjuice'
description: BookMyJuice - Cold-pressed juice subscription and ordering platform
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
```

### Step 2: Update Android Package Name

**File:** `lush/android/app/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.bookmyjuice.app"
        // ...
    }
}
```

**Update Android directory structure:**
```
lush/android/app/src/main/java/com/bookmyjuice/app/
```

**Update AndroidManifest.xml:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.bookmyjuice.app">
```

### Step 3: Update iOS Bundle ID

**File:** `lush/ios/Runner.xcodeproj/project.pbxproj`

Search and replace:
- `com.bookmyjuice.lush` → `com.bookmyjuice.app`

**File:** `lush/ios/Runner/Info.plist`

```xml
<key>CFBundleIdentifier</key>
<string>com.bookmyjuice.app</string>
```

### Step 4: Update All Imports

**Find and replace in all Dart files:**
```dart
// Old
import 'package:lush/...';

// New
import 'package:bookmyjuice/...';
```

**Command (Mac/Linux):**
```bash
cd lush
find lib -name "*.dart" -type f -exec sed -i '' 's/package:lush/package:bookmyjuice/g' {} \;
find test -name "*.dart" -type f -exec sed -i '' 's/package:lush/package:bookmyjuice/g' {} \;
find integration_test -name "*.dart" -type f -exec sed -i '' 's/package:lush/package:bookmyjuice/g' {} \;
```

**Command (Windows PowerShell):**
```powershell
cd lush
(Get-Content -Path (Get-ChildItem -Path lib, test, integration_test -Filter *.dart -Recurse).FullName) -replace 'package:lush', 'package:bookmyjuice' | Set-Content
```

### Step 5: Clean and Rebuild

```bash
cd lush
flutter clean
flutter pub get
flutter run
```

---

## 📊 Impact Analysis

| Change | Impact | Breaking | Recommendation |
|--------|--------|----------|----------------|
| Display Name Only | Low | ❌ No | ✅ DO THIS |
| Package Name | High | ✅ Yes | ❌ Don't do this |
| Internal Code Name | Medium | ❌ No | ⚠️ Optional |

---

## ✅ Verification Checklist

After changing the display name:

### Android
- [ ] App name shows "BookMyJuice" on home screen
- [ ] App name shows "BookMyJuice" in app switcher
- [ ] Package name is `com.bookmyjuice.app`
- [ ] App builds without errors
- [ ] Google Sign-In still works

### iOS
- [ ] App name shows "BookMyJuice" on home screen
- [ ] App name shows "BookMyJuice" in app switcher
- [ ] Bundle ID is `com.bookmyjuice.app`
- [ ] App builds without errors
- [ ] Google Sign-In still works

### Web
- [ ] Browser tab shows "BookMyJuice"
- [ ] PWA name is "BookMyJuice"
- [ ] App loads without errors

---

## 🚀 Quick Start (Display Name Only)

### 1. Update Android

**File:** `lush/android/app/src/main/res/values/strings.xml`

```xml
<resources>
    <string name="app_name">BookMyJuice</string>
</resources>
```

### 2. Update iOS

**File:** `lush/ios/Runner/Info.plist`

```xml
<key>CFBundleName</key>
<string>BookMyJuice</string>
<key>CFBundleDisplayName</key>
<string>BookMyJuice</string>
```

### 3. Update Web

**File:** `lush/web/index.html`

```html
<title>BookMyJuice</title>
```

### 4. Test

```bash
cd lush
flutter clean
flutter pub get
flutter run
```

---

## 📝 Current Status

| Component | Current Name | Target Name | Status |
|-----------|--------------|-------------|--------|
| **Display Name (Android)** | lush | BookMyJuice | ⏳ TODO |
| **Display Name (iOS)** | lush | BookMyJuice | ⏳ TODO |
| **Display Name (Web)** | lush | BookMyJuice | ⏳ TODO |
| **Package Name (Android)** | com.bookmyjuice.app | com.bookmyjuice.app | ✅ Already correct |
| **Bundle ID (iOS)** | com.bookmyjuice.app | com.bookmyjuice.app | ✅ Already correct |
| **Internal Code Name** | lush | lush | ✅ Keep as is |

---

## 🎯 Recommendation

**DO THIS NOW:**
1. ✅ Change display name only (strings.xml, Info.plist, index.html)
2. ✅ Keep package name as `com.bookmyjuice.app`
3. ✅ Keep internal code name as `lush`

**DON'T DO:**
- ❌ Don't change package name (breaks existing installs)
- ❌ Don't change all imports (time-consuming, error-prone)
- ❌ Don't change internal code name (unnecessary)

---

**Last Updated:** April 1, 2026  
**Status:** ⏳ PENDING DISPLAY NAME CHANGE  
**Time Required:** 15 minutes (display name only)
