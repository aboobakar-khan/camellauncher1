import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_content_manager.dart';
import '../providers/theme_provider.dart';

/// Subtle offline content download indicator
/// 
/// Shows a minimalist progress bar when downloading content
/// Appears at the top of the home screen, disappears when complete
class OfflineDownloadIndicator extends ConsumerWidget {
  const OfflineDownloadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(offlineContentProvider);
    final themeColor = ref.watch(themeColorProvider);
    
    // Don't show if complete
    if (status.isComplete) return const SizedBox.shrink();
    
    // Don't show if not downloading and no error
    if (!status.isDownloading && status.error == null) {
      return const SizedBox.shrink();
    }
    
    return AnimatedOpacity(
      opacity: status.isDownloading || status.error != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            if (status.isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: status.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeColor.color.withValues(alpha: 0.6),
                  ),
                  minHeight: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status.currentItem ?? 'Preparing offline content...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
            
            // Error state with retry
            if (status.error != null && !status.isDownloading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Offline content pending',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ref.read(offlineContentProvider.notifier).retryDownload();
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: themeColor.color.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact status icon for settings or status bar
class OfflineStatusIcon extends ConsumerWidget {
  const OfflineStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(offlineContentProvider);
    final themeColor = ref.watch(themeColorProvider);
    
    if (status.isComplete) {
      return Icon(
        Icons.cloud_done,
        color: themeColor.color.withValues(alpha: 0.5),
        size: 18,
      );
    }
    
    if (status.isDownloading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          value: status.progress,
          strokeWidth: 2,
          color: themeColor.color.withValues(alpha: 0.6),
        ),
      );
    }
    
    return Icon(
      Icons.cloud_off,
      color: Colors.white.withValues(alpha: 0.3),
      size: 18,
    );
  }
}
