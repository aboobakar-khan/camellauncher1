# Privacy Policy & Qur'an Attribution - Implementation Guide

## ✅ What's Been Added

### 1. Privacy Policy Screen (In-App)
- **Location**: `lib/screens/privacy_policy_screen.dart`
- **Features**: 
  - Full privacy policy compliant with Google Play Store requirements
  - Covers all necessary permissions and data handling
  - Accessible from Settings → About → Privacy Policy

### 2. Credits & Licenses Screen (In-App)
- **Location**: `lib/screens/credits_screen.dart`
- **Features**:
  - Qur'an text and translation attribution
  - License information for all resources
  - Important disclaimer about translation accuracy
  - Accessible from Settings → About → Credits & Licenses

### 3. Updated Settings Screen
- **Location**: `lib/screens/settings_screen.dart`
- **Changes**: Added navigation to both Privacy Policy and Credits screens in the ABOUT section

### 4. Web-Hostable Privacy Policy
- **Location**: `privacy_policy.html` (in project root)
- **Purpose**: Can be hosted on GitHub Pages, your website, or Google Sites for Play Store submission

---

## 📍 Where to Host Your Privacy Policy

You **must** provide a publicly accessible URL for your privacy policy when submitting to Google Play Store.

### Option 1: GitHub Pages (Recommended - Free & Easy)
1. Go to your GitHub repository: https://github.com/aheteshamq25/minimalist_app
2. Click **Settings** → **Pages**
3. Under "Source", select **main branch**
4. Click **Save**
5. Your privacy policy will be available at:
   ```
   https://aheteshamq25.github.io/minimalist_app/privacy_policy.html
   ```

### Option 2: Google Sites (Free)
1. Go to https://sites.google.com
2. Create a new site
3. Copy the content from `privacy_policy.html`
4. Publish and get the URL

### Option 3: Your Own Website
- Upload `privacy_policy.html` to your web server
- Use the direct URL in Play Store submission

---

## 📝 Before Publishing - Checklist

### Update These Values:

1. **In `privacy_policy.html`** (line 203):
   - Replace `your-email@example.com` with your actual support email

2. **In Play Store Console**:
   - Add the privacy policy URL (from hosting option above)
   - Add your support email
   - Add your developer name/studio name

3. **Optional - Update Date**:
   - The privacy policy already shows January 25, 2026 as the last updated date
   - You can keep this or update it to your actual publish date

---

## 🎯 Play Store Submission

### When filling out the Play Store listing:

1. **Privacy Policy URL**: 
   - Enter your hosted privacy policy URL (e.g., GitHub Pages link)

2. **Data Safety Section**:
   - ✅ Select "No data collected" for most categories
   - ✅ For "Location" → Select "No"
   - ✅ For "Personal info" → Select "No"
   - ✅ For "Photos and videos" → Select "No"
   - ✅ For "Audio files" → Select "Microphone used only for voice search, no data stored"
   - ✅ For "App activity" → Select "Device app list accessed for launcher functionality, stored locally only"

3. **Permissions Justification**:
   - **MICROPHONE**: Used only for optional voice app search feature. Audio is not recorded or stored.
   - **QUERY_ALL_PACKAGES**: Required for launcher functionality to display installed apps.
   - **PACKAGE_USAGE_STATS**: Optional feature for hiding unused apps. All processing is local.

---

## 🔍 How Users Will See This

### In the App:
1. Open app → Tap Settings icon
2. Scroll to **ABOUT** section
3. Tap **"Credits & Licenses"** to see Qur'an attribution
4. Tap **"Privacy Policy"** to read the full policy

### On Play Store:
- Your privacy policy URL will be clickable in the app listing
- Users can review it before installing

---

## 📖 Qur'an Source Notes

The current implementation shows:
- Arabic text: Public domain
- English translation: Public domain/open license
- Attribution shown prominently in Credits screen

**If you're using a specific translation** (e.g., Sahih International, Yusuf Ali, etc.):
1. Open `lib/screens/credits_screen.dart`
2. Update line 71-76 with the specific translation name and license
3. Example:
   ```dart
   description:
       'English translation: Sahih International\n\n'
       'Licensed under: Creative Commons CC BY-SA 4.0\n\n'
       'Source: quran.com',
   ```

---

## ✨ You're Ready!

With these implementations:
- ✅ Privacy policy is in the app (required)
- ✅ Privacy policy can be hosted publicly (required)
- ✅ Qur'an attribution is clearly shown (legal requirement)
- ✅ All necessary permissions are explained
- ✅ Play Store compliance is met

Just update the email address and host the HTML file, then you can submit to Play Store with confidence!

---

## Need Help?

If you have questions about:
- Specific translation licenses → Check the source of your Qur'an data file
- Play Store rejection → Share the rejection reason and we can adjust
- Hosting issues → GitHub Pages is the easiest option
