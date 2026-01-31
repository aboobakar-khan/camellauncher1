# 📋 Widget Dashboard Guide

## ✨ Features Implemented

### 🎯 Three Core Widgets

1. **To-Do Widget**
   - Add tasks inline
   - Check/uncheck completion
   - Delete tasks
   - Shows top 3 active tasks
   - Tap to expand (future feature)

2. **Notes Widget**
   - Quick note input
   - Edit latest note
   - Auto-saves
   - Clean text display
   - Tap to expand (future feature)

3. **Calendar Widget**
   - Month view
   - Date selection
   - Today highlight
   - Minimal design
   - Tap to expand (future feature)

## 🎨 Design Philosophy

**Glass-morphism Cards:**
- Subtle transparency (3% white overlay)
- Thin borders (10% white)
- Rounded corners (16px)
- Consistent spacing

**Minimalist Typography:**
- Uppercase card titles
- Letter spacing for readability
- Muted colors (30-70% white opacity)
- No bold unless needed

## 📱 Navigation Flow

```
Home Screen
├─> Tap "Dashboard" → Widget Dashboard
├─> Tap "All Apps" → App List
└─> Back button → Minimize app (launcher behavior)

Widget Dashboard
└─> Back button → Home Screen
```

## 🗃️ Data Storage

**Hive Local Database:**
- `todos` box → TodoItem objects
- `notes` box → Note objects
- Persists across app restarts
- Fast read/write

**State Management:**
- Riverpod for reactive updates
- Providers in `lib/providers/`
- Auto-updates UI on data changes

## 🔮 How It Works

### Adding a To-Do

1. Type in input field
2. Press Enter or tap +
3. Saves to Hive
4. Riverpod updates UI instantly

### Writing a Note

1. Type in empty note widget
2. Tap "Save"
3. Stored in Hive
4. Latest note displays
5. Tap edit icon to modify

### Using Calendar

1. Tap any date
2. Highlights selection
3. Today always marked
4. Scroll between months

## 📂 Project Structure

```
lib/
├── models/
│   ├── todo_item.dart          # Todo data model
│   ├── todo_item.g.dart        # Generated adapter
│   ├── note.dart               # Note data model
│   └── note.g.dart             # Generated adapter
├── providers/
│   ├── todo_provider.dart      # Todo state management
│   └── note_provider.dart      # Note state management
├── widgets/
│   ├── widget_card.dart        # Reusable card component
│   ├── todo_widget.dart        # To-Do widget
│   ├── notes_widget.dart       # Notes widget
│   └── calendar_widget.dart    # Calendar widget
└── screens/
    ├── home_screen.dart        # Clock + shortcuts
    ├── app_list_screen.dart    # App drawer
    └── widget_dashboard_screen.dart  # Widget grid
```

## 🛠️ Customization

### Add More Widgets

1. Create widget file in `lib/widgets/`
2. Use `WidgetCard` wrapper
3. Add to dashboard grid in `widget_dashboard_screen.dart`

### Change Widget Order

Edit [widget_dashboard_screen.dart](../screens/widget_dashboard_screen.dart):

```dart
Column(
  children: [
    // Reorder these rows
    Row(children: [TodoWidget(), NotesWidget()]),
    CalendarWidget(),
    // Add new widgets here
  ],
)
```

### Modify Card Appearance

Edit [widget_card.dart](../widgets/widget_card.dart):
- Change `color` opacity
- Adjust `borderRadius`
- Modify padding

## 🚀 Future Enhancements

**Planned Features:**
- [ ] Full-screen widget views (tap to expand)
- [ ] App usage stats widget (requires Kotlin)
- [ ] Habit tracker widget
- [ ] Weather widget (API integration)
- [ ] Pomodoro timer widget
- [ ] Multiple notes support
- [ ] Todo categories/tags
- [ ] Reminders/notifications
- [ ] Swipe gestures between screens

## ⚠️ Known Limitations

1. **No Cloud Sync** - Data stored locally only
2. **No Reminders** - Todo/notes are passive
3. **App Usage** - Requires native Android code
4. **Calendar Events** - Display only, no Google Calendar sync

## 🔧 Troubleshooting

**Widgets not showing data?**
- Check Hive initialization in `main.dart`
- Verify adapters generated (`*.g.dart` files exist)
- Run `dart run build_runner build` if needed

**State not updating?**
- Ensure `ProviderScope` wraps app in `main.dart`
- Check provider imports in widget files

**Build errors?**
- Run `flutter clean`
- Run `flutter pub get`
- Regenerate adapters: `dart run build_runner build --delete-conflicting-outputs`

---

**Enjoy your minimalist productivity dashboard! 🌿**
