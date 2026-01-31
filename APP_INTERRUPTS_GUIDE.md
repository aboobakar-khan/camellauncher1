# App Interrupts - Digital Wellbeing Feature

## Overview
The App Interrupts feature helps you reduce mindless app usage by adding intentional friction before opening specific apps. When you try to open an app with an interrupt configured, you'll be prompted to pause and reconsider, helping you build healthier digital habits.

## Features

### Interrupt Methods

1. **30-Second Timer** ⏱️
   - Wait 30 seconds before the app opens
   - Gives you time to reconsider if you really need to use the app
   - Great for breaking automatic habits

2. **Password Input** 🔐
   - Enter a custom password to open the app
   - The password you set reminds you why you're limiting this app
   - Example: Set password to "onlyfor5mins" as a reminder

3. **Voice Confirmation** 🎤
   - Say the app name out loud to open it
   - Makes you consciously acknowledge what you're about to do
   - Requires microphone permission

4. **Timer + Reminder** ⏱️💡
   - Combines 30-second wait with a custom reminder message
   - Shows your personal reason for limiting the app
   - Example: "Remember: You wanted to spend less time scrolling"

5. **Password + Reminder** 🔐💡
   - Enter password while seeing your reminder message
   - Double reinforcement of your intentions

6. **Voice + Reminder** 🎤💡
   - Voice confirmation with reminder message
   - Combines physical action with mental reminder

## How to Use

### Setting Up Interrupts

1. Open **Settings** from the app list
2. Scroll to **Digital Wellbeing** section
3. Tap **App Interrupts**
4. Search for the app you want to limit
5. Tap the **+** icon next to the app
6. Choose your interrupt method
7. Configure:
   - For password methods: Set a meaningful password
   - For reminder methods: Write why you're limiting this app
8. Tap **Save**

### Managing Interrupts

- **Toggle On/Off**: Use the switch next to configured apps
- **Edit Settings**: Tap the edit icon to change method or reminder
- **Remove Interrupt**: Edit the app and delete, or toggle off

### Using Interrupts

When you try to open an app with an interrupt:

1. **Timer Method**: 
   - Wait for the countdown to complete
   - Tap "Continue" when ready
   - Or tap "Cancel" to avoid opening the app

2. **Password Method**:
   - Enter your custom password
   - Tap "Continue"
   - Wrong password? You'll get an error - try again or cancel

3. **Voice Method**:
   - Tap the microphone button
   - Say the app name clearly
   - If recognized correctly, app opens
   - Grant microphone permission when prompted

## Best Practices

### Choosing the Right Method

- **For quick check apps** (social media): Use Timer or Voice methods
- **For addictive apps** (games, videos): Use Password + Reminder
- **For work-time protection**: Use Timer + Reminder with message like "Save this for break time"
- **For evening wind-down**: Use reminders like "Better to read instead"

### Writing Effective Reminders

✅ **Good reminders:**
- "You wanted to read more instead"
- "Remember your goal to reduce screen time"
- "Is this urgent or can it wait?"
- "Last time you spent 2 hours here"

❌ **Less effective:**
- "Don't use this app"
- "Bad app"
- "Stop"

### Password Ideas

Make passwords that remind you of your goals:
- `justonequickcheck` (reminds you what you always say)
- `10minutesmax` (time limit reminder)
- `notrightnow` (postponement reminder)
- `aftermywork` (priority reminder)

## Technical Details

### Permissions Required

**Android:**
- `RECORD_AUDIO` - For voice interrupts
- `INTERNET` - For speech recognition processing
- `BLUETOOTH` - For external microphone support

**iOS:**
- `NSMicrophoneUsageDescription` - Microphone access for voice interrupts
- `NSSpeechRecognitionUsageDescription` - Speech-to-text processing

### Voice Recognition

- Uses Google's speech-to-text API (Android) or Apple's Speech framework (iOS)
- Works offline on most devices for common words
- Requires speaking clearly and saying the app name
- 5-second listening window with 3-second pause detection

### Data Storage

- All interrupt settings stored locally using Hive
- No data sent to external servers
- Settings persist across app restarts
- Can be cleared by clearing app data

## Troubleshooting

### Voice Recognition Not Working

1. **Grant microphone permission**: Check Settings > Apps > Minimalist App > Permissions
2. **Check microphone**: Test with another app to ensure it works
3. **Speak clearly**: Say the full app name clearly and loudly
4. **Language settings**: Ensure your device language matches your speech
5. **Background noise**: Try in a quieter environment

### Timer Not Starting

- Restart the app
- Check if interrupt is enabled (switch is on)
- Try removing and re-adding the interrupt

### Password Not Working

- Passwords are case-sensitive
- Check for extra spaces
- Try re-setting the password

## Privacy & Security

- **Local storage only**: All data stays on your device
- **No tracking**: We don't track which apps you use or how often
- **No cloud sync**: Interrupts are per-device
- **Voice data**: Speech is processed by OS, not stored by the app
- **Password security**: Passwords stored in local encrypted database

## Tips for Success

1. **Start small**: Begin with 1-2 apps you want to reduce
2. **Be honest**: Write reminders that truly resonate with you
3. **Adjust as needed**: Change methods if one isn't working
4. **Combine with other habits**: Use with app timers, focus modes
5. **Review weekly**: Check if your interrupts are helping or need adjustment

## Examples

### Social Media Break
- **Apps**: Instagram, Twitter, TikTok
- **Method**: Timer + Reminder
- **Reminder**: "You decided to check these only at lunch and after work"

### Gaming Limit
- **Apps**: Mobile games
- **Method**: Password + Reminder
- **Password**: `after8pmonly`
- **Reminder**: "Gaming time is after all work is done"

### Shopping Control
- **Apps**: Amazon, eBay, shopping apps
- **Method**: Voice + Reminder
- **Reminder**: "Do you really need this? Check your budget first"

## Future Enhancements

Planned features:
- Custom timer durations (15s, 1min, 5min)
- Schedule-based interrupts (only during work hours)
- Usage statistics and reports
- Multiple passwords for different times
- Breathing exercises during timer waits
- Math problem challenges

---

**Remember**: Interrupts work best when combined with genuine intention to change your habits. They're a tool to support your goals, not a magic solution. Be patient with yourself! 🌱
