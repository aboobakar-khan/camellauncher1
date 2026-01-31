# Focus Mode Feature Guide

## Overview
Focus Mode transforms your home screen into a minimal, distraction-free interface that only shows apps you've selected for focused work. This maintains the minimalist theme while helping you stay productive.

## Key Features

### 🎯 Dedicated Focus Screen
- **Replaces Home Screen**: When focus mode is active, the entire launcher shows only the Focus Mode Screen
- **Minimal Design**: Clean black background with large clock and minimal UI elements
- **No Distractions**: No access to widgets dashboard or full app list during focus

### 📱 App Limit (Maximum 5 Apps)
- **Strategic Limitation**: You can only add up to 5 apps to maintain focus
- **Visual Feedback**: Settings screen shows remaining slots (e.g., "3 slots left")
- **Prevents Clutter**: Keeps the focus screen clean and intentional

### ⏱️ Focus Duration Tracking
- **Time Tracking**: Shows how long you've been in focus mode
- **Motivation**: See your focus streak grow (e.g., "1h 23m focused")

## How to Use

### Setting Up Focus Mode

1. **Open Settings**
   - Navigate to Settings → Digital Wellbeing → Focus Mode

2. **Select Your Focus Apps** (Max 5)
   - Choose apps that help you stay productive
   - Examples: Calendar, Notes, Email, Music, Reading app
   - Add button turns gray when limit is reached

3. **Customize Block Message**
   - Set a custom message for blocked apps (optional)
   - Default: "Focus mode is active. This app is blocked."

4. **Enable Focus Mode**
   - Toggle the switch in the top right
   - Home screen immediately transforms to Focus Mode Screen

### Using Focus Mode

**When Enabled:**
- Large clock display with current time
- Your selected apps (max 5) shown in a clean list
- Focus duration timer shows your progress
- "FOCUS MODE" indicator at the top
- "Exit Focus Mode" button at the bottom

**To Exit:**
- Tap the "Exit Focus Mode" button
- Or toggle off in Settings
- Returns you to normal launcher immediately

## UI Design

### Focus Mode Screen
```
┌─────────────────────────────┐
│   🔒 FOCUS MODE             │
│                             │
│        14:23                │  ← Large clock
│     45m focused             │  ← Duration
│                             │
│   ALLOWED APPS              │
│                             │
│   📱 Calendar               │
│   📝 Notes                  │  ← Your 5 apps
│   📧 Email                  │
│   🎵 Music                  │
│   📚 Reading                │
│                             │
│   [Exit Focus Mode]         │
└─────────────────────────────┘
```

### Settings Screen
```
┌─────────────────────────────┐
│ ← Focus Mode         ON [✓] │
│                             │
│ Allowed in Focus Mode (3)   │
│              [2 slots left] │  ← Shows remaining
│   📱 Calendar        [−]    │
│   📝 Notes           [−]    │
│   📧 Email           [−]    │
│                             │
│ Blocked in Focus Mode (48)  │
│   🎮 Games           [+]    │  ← Gray when limit reached
│   📱 Social          [+]    │
│   ...                       │
└─────────────────────────────┘
```

## Benefits

### For Focus
- **Intentional Access**: Only see apps that support your goals
- **Reduced Temptation**: Blocked apps require exiting focus mode
- **Time Awareness**: Duration tracker keeps you aware of your focus session

### For Minimalism
- **Clean Interface**: Maximum 5 apps maintains minimalist aesthetic
- **Less Choice**: Reduces decision fatigue during work sessions
- **Purpose-Driven**: Each app in focus mode has a specific purpose

## Tips for Best Results

1. **Choose Wisely**: Select only apps essential for your work
   - Productivity tools (Calendar, Notes, Tasks)
   - Communication (Email, Work chat)
   - Tools (Calculator, Files)
   - Background apps (Music, Timer)

2. **Combine with App Interrupts**: 
   - Set interrupts on apps you've allowed in focus mode
   - Adds extra friction for mindful usage

3. **Time-Box Your Focus**:
   - Set a goal before enabling (e.g., "focus for 1 hour")
   - Watch the duration timer for motivation
   - Exit when goal is reached

4. **Regular Reviews**:
   - Periodically review your 5 allowed apps
   - Remove apps that don't support your goals
   - Add new ones as priorities change

## Technical Details

### Files Modified/Created
- `lib/screens/focus_mode_screen.dart` - New minimal focus screen
- `lib/models/focus_mode.dart` - Added 5-app limit logic
- `lib/providers/focus_mode_provider.dart` - Enforces app limit
- `lib/screens/focus_mode_settings_screen.dart` - Shows limit status
- `lib/screens/launcher_shell.dart` - Shows focus screen when enabled

### Integration
- Focus Mode integrates with existing App Interrupts feature
- Both systems work together for comprehensive digital wellbeing
- Focus Mode takes precedence: blocked apps can't be accessed even with interrupts

## Frequently Asked Questions

**Q: Why only 5 apps?**
A: The limit maintains the minimalist philosophy and prevents focus mode from becoming cluttered. Five apps is enough for essential tools while keeping you focused.

**Q: Can I temporarily access a blocked app?**
A: No, you must exit focus mode first. This intentional friction helps you stay committed to your focus session.

**Q: What happens if I restart the app during focus mode?**
A: Focus mode persists across app restarts. You'll return to the Focus Mode Screen.

**Q: Can I see my widgets during focus mode?**
A: No, focus mode replaces the entire home screen experience to minimize distractions.

**Q: Does focus mode affect app interrupts?**
A: Apps allowed in focus mode can still have interrupts. They work together for layered digital wellbeing.

## Future Enhancements (Potential)
- Scheduled focus sessions (auto-enable at certain times)
- Focus mode statistics and history
- Multiple focus mode profiles (Work, Study, Creative)
- Focus mode achievements and streaks
