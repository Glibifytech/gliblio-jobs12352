import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['isRead'] ?? false;
    final String type = notification['type'] ?? 'general';
    final String timestamp = notification['timestamp'] ?? '';
    final String message = notification['message'] ?? '';
    final String userName = notification['userName'] ?? '';
    final String userAvatar = notification['userAvatar'] ?? '';
    final String? contentPreview = notification['contentPreview'];

    return Dismissible(
      key: Key(notification['id'].toString()),
      background: _buildSwipeBackground(context, isRead: isRead),
      secondaryBackground: _buildDeleteBackground(context),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onMarkRead?.call();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isRead
                ? AppTheme.lightTheme.colorScheme.surface
                : AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(userAvatar),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNotificationHeader(context, type, userName, isRead),
                      SizedBox(height: 1.h),
                      _buildNotificationMessage(context, message, isRead),
                      if (contentPreview != null) ...[
                        SizedBox(height: 1.h),
                        _buildContentPreview(context, contentPreview),
                      ],
                      SizedBox(height: 1.h),
                      _buildTimestamp(context, timestamp),
                    ],
                  ),
                ),
                _buildNotificationIcon(context, type),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String avatarUrl) {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? CustomImageWidget(
                imageUrl: avatarUrl,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                child: CustomIconWidget(
                  iconName: 'person',
                  size: 6.w,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
      ),
    );
  }

  Widget _buildNotificationHeader(
      BuildContext context, String type, String userName, bool isRead) {
    return Row(
      children: [
        Expanded(
          child: Text(
            userName,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isRead)
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationMessage(
      BuildContext context, String message, bool isRead) {
    return Text(
      message,
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildContentPreview(BuildContext context, String contentPreview) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        contentPreview,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, String timestamp) {
    return Text(
      timestamp,
      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context, String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        iconData = Icons.chat_bubble;
        iconColor = AppTheme.lightTheme.colorScheme.primary;
        break;
      case 'follow':
        iconData = Icons.person_add;
        iconColor = AppTheme.lightTheme.colorScheme.secondary;
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor =
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: _getIconName(iconData),
        size: 4.w,
        color: iconColor,
      ),
    );
  }

  String _getIconName(IconData iconData) {
    if (iconData == Icons.favorite) return 'favorite';
    if (iconData == Icons.chat_bubble) return 'chat_bubble';
    if (iconData == Icons.person_add) return 'person_add';
    if (iconData == Icons.alternate_email) return 'alternate_email';
    return 'notifications';
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isRead}) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      color: isRead
          ? Colors.orange.withValues(alpha: 0.2)
          : AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
      child: CustomIconWidget(
        iconName: isRead ? 'mark_email_unread' : 'mark_email_read',
        color:
            isRead ? Colors.orange : AppTheme.lightTheme.colorScheme.secondary,
        size: 6.w,
      ),
    );
  }

  Widget _buildDeleteBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      color: Colors.red.withValues(alpha: 0.2),
      child: CustomIconWidget(
        iconName: 'delete',
        color: Colors.red,
        size: 6.w,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Notification',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            content: Text(
              'Are you sure you want to delete this notification?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: notification['isRead']
                    ? 'mark_email_unread'
                    : 'mark_email_read',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                notification['isRead'] ? 'Mark as Unread' : 'Mark as Read',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                onMarkRead?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Colors.red,
                size: 6.w,
              ),
              title: Text(
                'Delete',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
