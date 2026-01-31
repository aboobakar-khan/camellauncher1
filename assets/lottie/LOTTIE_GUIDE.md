# 🎨 Lottie Background Guide

## Where to Get Lottie Animations

### 🔗 LottieFiles.com (Best Source)

1. **Visit:** [lottiefiles.com](https://lottiefiles.com)

2. **Search for calm animations:**
   - "calm nature"
   - "slow clouds"
   - "water loop"
   - "minimal gradient"
   - "abstract calm"
   - "night sky"
   - "aurora"
   - "waves ocean"

3. **Filter by:**
   - ✅ Free
   - ✅ Loopable
   - ✅ Dark backgrounds work best

### 📥 How to Download

1. Click on animation you like
2. Click **"Download Lottie JSON"** button
3. Save as `bg.json`
4. Place in: `assets/lottie/bg.json`

### 🌟 Recommended Animations

**For Minimalist Launcher:**

| Style | Search Term | Vibe |
|-------|------------|------|
| Nature | "calm forest loop" | 🌲 Peaceful trees |
| Water | "ocean waves slow" | 🌊 Gentle waves |
| Sky | "clouds subtle" | ☁️ Slow clouds |
| Abstract | "gradient flow" | 🎨 Color shift |
| Night | "stars night" | ⭐ Starry sky |
| Minimal | "particle slow" | ✨ Floating dots |

### ⚡ Performance Tips

**Good Lottie Files:**
- ✅ Under 500KB
- ✅ Simple shapes
- ✅ Loopable
- ✅ 30fps or less
- ✅ Short duration (3-10 seconds)

**Avoid:**
- ❌ Heavy files (> 1MB)
- ❌ Complex gradients
- ❌ Too many layers
- ❌ High FPS (60fps)

### 🎬 Examples from LottieFiles

**ID Numbers** (if available):
- Search by ID: `lottiefiles.com/[ID]`

**Great for Oasis style:**
1. Search: **"minimal gradient"**
   - Look for: Slow color transitions
   
2. Search: **"calm nature loop"**
   - Look for: Subtle tree/leaf movement

3. Search: **"dark abstract"**
   - Look for: Flowing shapes on dark background

### 🔧 How It Works in the App

The `AnimatedBackground` widget:
- ✅ Tries to load `assets/lottie/bg.json`
- ✅ Falls back to gradient if file missing
- ✅ Handles errors gracefully
- ✅ Covers full screen
- ✅ Loops automatically

### 📝 Using Different Files

To use a different Lottie file:

1. **Option 1:** Replace the file
   - Name it `bg.json`
   - Place in `assets/lottie/`

2. **Option 2:** Use custom name (requires code change)
   ```dart
   AnimatedBackground(
     lottieAsset: 'assets/lottie/custom_name.json',
     child: ...
   )
   ```

### 🚫 Disable Lottie (Use Gradient Only)

If Lottie causes issues:

```dart
AnimatedBackground(
  useLottie: false,  // Forces gradient
  child: ...
)
```

### 🎯 Current Setup

- **Default:** Looks for `bg.json`
- **Fallback:** Animated dark gradient
- **No errors:** Silently falls back if file missing

---

**Ready to add your background:**
1. Download animation from LottieFiles
2. Save as `bg.json`
3. Drop into `assets/lottie/` folder
4. Run app - it loads automatically! 🚀
