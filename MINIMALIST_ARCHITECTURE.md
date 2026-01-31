# Minimalist Architecture

## Philosophy

**Text only, stored in Hive, loaded into memory, no cache, instant filtering, lightweight UI**

## Architecture Overview

### 1. **Favorites** - `FavoriteApp` Model
- ✅ Stored permanently in Hive (`typeId: 8`)
- ✅ Contains: `packageName`, `appName`, `addedAt`
- ✅ Max 8 favorites
- ✅ No cache needed - always instant
- ✅ No API calls to get app names

**Provider:** `favoriteAppsProvider`
- Loads from `favorite_apps_v2` box
- Returns `List<FavoriteApp>`
- Instant display with stored app names

### 2. **Installed Apps** - `InstalledApp` Model
- ✅ Stored permanently in Hive (`typeId: 9`)
- ✅ Contains: `packageName`, `appName`, `lastUpdated`
- ✅ Loaded into memory once
- ✅ Instant filtering from memory
- ✅ Text-only, no icons

**Provider:** `installedAppsProvider`
- Loads from `installed_apps` box into memory
- Returns `List<InstalledApp>`
- `filterApps(query)` - filters in memory, instant
- `refreshApps()` - manual refresh when needed
- No automatic cache expiration

## Performance

### Before (Cached Architecture)
- First load: 1-2 seconds API call
- Cache valid: Instant (30 mins)
- Cache expired: 1-2 seconds reload
- Memory: Temporary cache variables

### After (Hive + Memory Architecture)
- First load: 1-2 seconds (stored in Hive)
- **All subsequent loads: Instant from memory**
- **Filtering: Instant in-memory search**
- **No cache logic, no expiration**
- Memory: Loaded once, stays in memory

## Data Flow

```
App Launch
    ↓
InstalledAppsProvider.init()
    ↓
Check Hive box 'installed_apps'
    ↓
If empty:
    Fetch from system API → Store in Hive → Load to memory
Else:
    Load from Hive to memory (instant)
    ↓
User types in search
    ↓
Filter in memory (instant)
    ↓
Display filtered results
```

## Files

### Models
- `lib/models/favorite_app.dart` - Favorite app data
- `lib/models/installed_app.dart` - Installed app data

### Providers
- `lib/providers/favorite_apps_provider.dart` - Favorites management
- `lib/providers/installed_apps_provider.dart` - Apps in memory

### Screens
- `lib/screens/app_list_screen.dart` - Text-only app list
- `lib/screens/home_clock_screen.dart` - Favorites display

## Benefits

✅ **True minimalism** - No complex caching logic  
✅ **Instant performance** - Everything in memory  
✅ **Persistent** - Stored in Hive across restarts  
✅ **Lightweight** - Text only, no icons  
✅ **Simple** - One source of truth (Hive → Memory)  
✅ **Efficient** - No repeated API calls  

## Manual Refresh

If user installs/uninstalls apps:
```dart
await ref.read(installedAppsProvider.notifier).refreshApps();
```

This can be added to settings or triggered automatically on app resume.
