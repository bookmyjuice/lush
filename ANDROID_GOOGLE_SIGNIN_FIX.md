# Android Google Sign-In Troubleshooting

**Status:** ⏳ Configuration Required
**Date:** April 1, 2026

---

## 🛑 Why It's Failing

Google Sign-In on Android **will fail** if the SHA-1 fingerprint of your app's signing key is not registered in Google Cloud Console.

Even in **Debug Mode** (on an emulator), the app is signed with a debug key. You must register that debug key's SHA-1 with Google.

---

## ✅ Step 1: Get Your Debug SHA-1

Run this command in your Windows Command Prompt (cmd):

```cmd
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Output:**
Look for the line starting with `SHA1:`. It looks like this:
`SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12`

**Copy that string.**

---

## 🌐 Step 2: Register SHA-1 in Google Cloud Console

1.  Go to **[Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials)**.
2.  Find your **OAuth 2.0 Client ID** that is type **Android**.
3.  If you don't have one:
    *   Click **Create Credentials** → **OAuth client ID**.
    *   Application type: **Android**.
    *   Name: `BookMyJuice (Debug)`.
4.  **Paste the SHA-1** you copied into the **"SHA-1 certificate fingerprint"** field.
5.  **Package Name:** Ensure this is `com.bookmyjuice.app` (matches your `android/app/build.gradle.kts`).
6.  Click **Save**.

---

## 🧪 Step 3: Clean and Rebuild

The changes need to be applied.

```bash
cd x:\BMJ\lush

# Clean old build artifacts
flutter clean

# Get dependencies
flutter pub get

# Run on emulator
flutter run
```

---

## 📱 Step 4: Emulator Check

1.  **Google Play Store:** Ensure your emulator has the **Google Play Store** icon (standard Android emulators don't work well with Google Sign-In).
2.  **Google Account:** Ensure you have a Google account added in the emulator's **Settings > Passwords & Accounts**.
3.  **Internet:** Ensure the emulator has internet access.

---

**Last Updated:** April 1, 2026
