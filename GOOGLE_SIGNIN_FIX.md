# Fix Google Sign-In ApiException 10 (DEVELOPER_ERROR)

`ApiException: 10` means Google OAuth config doesn’t match your app. Fix it by **adding your app’s SHA-1** in Firebase and updating `google-services.json`.

---

## 1. Get your SHA-1

**Option A – Gradle (recommended)**

```bash
cd makemyday/android && ./gradlew signingReport
```

Find **SHA1** under the **debug** variant and copy it (with or without colons).

**Option B – keytool**

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA1** line.

**Option C – Helper script**

```bash
./scripts/get_sha1.sh
```

---

## 2. Add SHA-1 in Firebase

1. Open **[Firebase Console → Project settings](https://console.firebase.google.com/project/make-my-day-now/settings/general)**.
2. Under **Your apps**, select the **Android** app `com.makemyday.makemyday`.
3. Click **Add fingerprint**.
4. Paste your **SHA-1** and save.

---

## 3. Update google-services.json

1. On the same **Project settings** page, click **Download google-services.json**.
2. Replace `makemyday/android/app/google-services.json` with the new file.

---

## 4. Rebuild and reinstall

1. Uninstall the app from the emulator/device.
2. Run:

   ```bash
   cd makemyday && flutter clean && flutter run
   ```

---

## Other checks

- **Emulator:** Use an AVD with **Google Play** (Device Manager → “Google Play” = Yes). ApiException 8 often means no Play Services.
- **Google Sign-In method:** Firebase Console → **Authentication** → **Sign-in method** → **Google** must be **Enabled**.
