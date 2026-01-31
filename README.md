# Camel: Islamic Minimalist Launcher 🌿

A clean, distraction-free Android launcher built with Flutter.

## ✨ Features

- **📱 App List**: Clean, text-only app drawer with search
- **🕐 Home Screen**: Large clock, date, and quick access
- **🎨 Minimal Design**: No icons, maximum focus
- **🌑 Dark Theme**: Easy on the eyes
- **🔍 Fast Search**: Quickly find apps

## 🚀 Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Add Lottie background (optional):**
   - Visit [lottiefiles.com](https://lottiefiles.com)
   - Search: "calm nature" or "minimal gradient"
   - Download as JSON → rename to `bg.json`
   - Place in: `assets/lottie/bg.json`
   - See [assets/lottie/LOTTIE_GUIDE.md](assets/lottie/LOTTIE_GUIDE.md) for details

3. **Run on Android device:**
   ```bash
   flutter run
   ```

4. **Set as default launcher:**
   - Press Home button
   - Select this app
   - Choose "Always"

## 📦 Dependencies

- `device_apps` - List and launch installed apps
- `lottie` - Animated backgrounds
- `intl` - Date/time formatting

## 🎨 Lottie Backgrounds

The app supports Lottie animated backgrounds:
- **With Lottie:** Place `bg.json` in `assets/lottie/`
- **Without Lottie:** Uses smooth gradient fallback
- **No errors:** Automatically falls back if file missing

**Recommended animations:**
- Calm nature scenes
- Slow cloud movement
- Gentle water waves
- Abstract gradients

See [Lottie Guide](assets/lottie/LOTTIE_GUIDE.md) for download instructions.

## 🎯 Launcher Behavior

This app includes launcher intent filters in `AndroidManifest.xml`, allowing it to replace your default home screen.

## 🔮 Coming Soon

- [ ] Widget dashboard (To-Do, Notes, Calendar)
- [ ] App usage stats
- [ ] Customization options
- [ ] Multiple Lottie backgrounds
- [ ] Gesture controls

## ⚠️ Important

- **Android only** - iOS does not support launcher replacement
- Requires `QUERY_ALL_PACKAGES` permission

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
