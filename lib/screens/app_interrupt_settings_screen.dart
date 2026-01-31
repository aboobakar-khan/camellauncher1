import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/installed_app.dart';
import '../models/app_interrupt.dart';
import '../providers/app_interrupt_provider.dart';
import '../providers/installed_apps_provider.dart';
import '../providers/theme_provider.dart';

class AppInterruptSettingsScreen extends ConsumerStatefulWidget {
  const AppInterruptSettingsScreen({super.key});

  @override
  ConsumerState<AppInterruptSettingsScreen> createState() =>
      _AppInterruptSettingsScreenState();
}

class _AppInterruptSettingsScreenState
    extends ConsumerState<AppInterruptSettingsScreen> {
  String _searchQuery = '';

  void _showInterruptConfigDialog(InstalledApp app) {
    final currentInterrupt = ref.read(appInterruptProvider)[app.packageName];

    showDialog(
      context: context,
      builder: (context) => _InterruptConfigDialog(
        app: app,
        currentInterrupt: currentInterrupt,
        onSave: (interrupt) {
          ref.read(appInterruptProvider.notifier).addInterrupt(interrupt);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interrupts = ref.watch(appInterruptProvider);
    final installedAppsNotifier = ref.watch(installedAppsProvider.notifier);
    final allApps = ref.watch(installedAppsProvider);
    final themeColor = ref.watch(themeColorProvider);

    // Filter in memory - instant performance
    final filteredApps = installedAppsNotifier.filterApps(_searchQuery);
    final isRefreshing = installedAppsNotifier.isRefreshing;

    final appsWithInterrupts = filteredApps.where((app) {
      return interrupts.containsKey(app.packageName);
    }).toList();
    final appsWithoutInterrupts = filteredApps.where((app) {
      return !interrupts.containsKey(app.packageName);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('App Interrupts'),
            Text(
              'Reduce distractions from specific apps',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              style: TextStyle(color: themeColor.color.withValues(alpha: 0.9)),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: TextStyle(
                  color: themeColor.color.withValues(alpha: 0.3),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Apps list
          Expanded(
            child: allApps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white30),
                        const SizedBox(height: 16),
                        Text(
                          'Loading apps into memory...',
                          style: TextStyle(
                            color: themeColor.color.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (appsWithInterrupts.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Apps with Interrupts',
                          isRefreshing,
                        ),
                        ...appsWithInterrupts.map(
                          (app) =>
                              _buildAppItem(app, interrupts[app.packageName]),
                        ),
                      ],
                      if (appsWithoutInterrupts.isNotEmpty) ...[
                        _buildSectionHeader('All Apps', isRefreshing),
                        ...appsWithoutInterrupts.map(
                          (app) => _buildAppItem(app, null),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isRefreshing) {
    final themeColor = ref.watch(themeColorProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: themeColor.color.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRefreshing) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppItem(InstalledApp app, AppInterrupt? interrupt) {
    final themeColor = ref.watch(themeColorProvider);
    final hasInterrupt = interrupt != null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        app.appName,
        style: TextStyle(
          color: themeColor.color.withValues(alpha: 0.9),
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      subtitle: hasInterrupt
          ? Text(
              interrupt.method.displayName,
              style: TextStyle(color: Colors.orange.shade400, fontSize: 12),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasInterrupt)
            Switch(
              value: interrupt.isEnabled,
              onChanged: (_) {
                ref
                    .read(appInterruptProvider.notifier)
                    .toggleInterrupt(app.packageName);
              },
              activeThumbColor: Colors.orange.shade400,
            ),
          IconButton(
            icon: Icon(
              hasInterrupt ? Icons.edit : Icons.add_circle_outline,
              color: hasInterrupt ? Colors.white : Colors.grey,
            ),
            onPressed: () => _showInterruptConfigDialog(app),
          ),
        ],
      ),
    );
  }
}

class _InterruptConfigDialog extends StatefulWidget {
  final InstalledApp app;
  final AppInterrupt? currentInterrupt;
  final Function(AppInterrupt) onSave;

  const _InterruptConfigDialog({
    required this.app,
    this.currentInterrupt,
    required this.onSave,
  });

  @override
  State<_InterruptConfigDialog> createState() => _InterruptConfigDialogState();
}

class _InterruptConfigDialogState extends State<_InterruptConfigDialog> {
  late InterruptMethod _selectedMethod;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();
  bool _showReminder = true;

  @override
  void initState() {
    super.initState();
    _selectedMethod =
        widget.currentInterrupt?.method ?? InterruptMethod.timer30;
    _passwordController.text = widget.currentInterrupt?.customPassword ?? '';
    _reminderController.text = widget.currentInterrupt?.reminderMessage ?? '';
    _showReminder = widget.currentInterrupt?.showReminder ?? true;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  void _save() {
    // Validate
    if (_selectedMethod.requiresPassword && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password')));
      return;
    }

    if (_selectedMethod.requiresReminder &&
        _showReminder &&
        _reminderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder message')),
      );
      return;
    }

    final interrupt = AppInterrupt(
      packageName: widget.app.packageName,
      appName: widget.app.appName,
      method: _selectedMethod,
      customPassword: _selectedMethod.requiresPassword
          ? _passwordController.text
          : null,
      reminderMessage: (_selectedMethod.requiresReminder && _showReminder)
          ? _reminderController.text
          : null,
      showReminder: _showReminder,
    );

    widget.onSave(interrupt);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - minimal design
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.app.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Configure Interrupt',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Interrupt method selection
              const Text(
                'Interrupt Method',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...InterruptMethod.values.map(
                (method) => RadioListTile<InterruptMethod>(
                  value: method,
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    setState(() => _selectedMethod = value!);
                  },
                  title: Text(
                    method.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    method.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  activeColor: Colors.green[400],
                ),
              ),

              const SizedBox(height: 24),

              // Password field (if required)
              if (_selectedMethod.requiresPassword) ...[
                const Text(
                  'Custom Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter a password',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Reminder section
              Row(
                children: [
                  const Text(
                    'Show Reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _showReminder,
                    onChanged: (value) {
                      setState(() => _showReminder = value);
                    },
                    activeThumbColor: Colors.orange.shade400,
                  ),
                ],
              ),
              if (_showReminder) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _reminderController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        'Why did you set this interrupt?\ne.g., "Reduce mindless scrolling"',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: const Color.fromARGB(255, 27, 230, 98),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
