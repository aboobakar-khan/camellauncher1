import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/todo_item.dart';
import 'models/note.dart';
import 'models/app_interrupt.dart';
import 'models/focus_mode.dart';
import 'models/favorite_app.dart';
import 'models/installed_app.dart';
import 'models/hidden_app.dart';
import 'models/event.dart';
import 'models/prayer_record.dart';
import 'screens/launcher_shell.dart';
import 'providers/font_provider.dart';
import 'providers/font_size_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  Hive.registerAdapter(TodoItemAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(AppInterruptAdapter());
  Hive.registerAdapter(InterruptMethodAdapter());
  Hive.registerAdapter(FocusModeSettingsAdapter());
  Hive.registerAdapter(FavoriteAppAdapter());
  Hive.registerAdapter(InstalledAppAdapter());
  Hive.registerAdapter(HiddenAppAdapter()); // User hidden/unhidden apps
  Hive.registerAdapter(EventAdapter()); // Event tracker
  Hive.registerAdapter(PrayerRecordAdapter()); // Prayer tracking

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await Hive.openBox('wallpaperBox');

  runApp(const ProviderScope(child: MinimalistLauncherApp()));
}

class MinimalistLauncherApp extends ConsumerWidget {
  const MinimalistLauncherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appFont = ref.watch(fontProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return MaterialApp(
      title: 'Camel Launcher',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(fontSize)),
          child: child!,
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black.withValues(alpha: 0.5),
        primarySwatch: Colors.grey,
        useMaterial3: true,
        fontFamily: appFont.fontFamily,
      ),
      home: const LauncherShell(),
    );
  }
}
