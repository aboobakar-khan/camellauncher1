import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

/// Reusable glass-morphism widget card
/// Used for dashboard widgets like To-Do, Notes, Calendar
class WidgetCard extends ConsumerWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final double? height;
  final EdgeInsets? padding;

  const WidgetCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w400,
                    color: themeColor.color.withValues(alpha: 0.5),
                  ),
                ),
                Row(
                  children: [
                    if (onDelete != null)
                      GestureDetector(
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    if (onEdit != null)
                      GestureDetector(
                        onTap: onEdit,
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget for cards with no content
class EmptyCardState extends ConsumerWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAdd;

  const EmptyCardState({
    super.key,
    required this.message,
    required this.icon,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: themeColor.color.withValues(alpha: 0.3),
              fontSize: 14,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: themeColor.color.withValues(alpha: 0.5),
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
