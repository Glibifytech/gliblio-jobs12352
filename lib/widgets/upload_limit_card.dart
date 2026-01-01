import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UploadLimitCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final Duration? duration;

  const UploadLimitCard({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Auto-dismiss after duration if provided
    if (duration != null) {
      Future.delayed(duration ?? const Duration(seconds: 5), () {
        if (onDismiss != null) onDismiss!();
      });
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.onErrorContainer,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
                  ),
                  onPressed: onDismiss,
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onErrorContainer,
              height: 1.5,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Limits reset automatically every 30 days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}