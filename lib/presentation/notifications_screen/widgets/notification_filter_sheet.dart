import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationFilterSheet extends StatefulWidget {
  final List<String> selectedFilters;
  final ValueChanged<List<String>> onFiltersChanged;

  const NotificationFilterSheet({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  State<NotificationFilterSheet> createState() =>
      _NotificationFilterSheetState();
}

class _NotificationFilterSheetState extends State<NotificationFilterSheet> {
  late List<String> _selectedFilters;

  final List<Map<String, dynamic>> _filterOptions = [
    {
      'id': 'all',
      'title': 'All Notifications',
      'subtitle': 'Show all notification types',
      'icon': 'notifications',
      'color': Colors.blue,
    },
    {
      'id': 'like',
      'title': 'Likes',
      'subtitle': 'When someone likes your posts',
      'icon': 'favorite',
      'color': Colors.red,
    },
    {
      'id': 'comment',
      'title': 'Comments',
      'subtitle': 'When someone comments on your posts',
      'icon': 'chat_bubble',
      'color': Colors.blue,
    },
    {
      'id': 'follow',
      'title': 'Follows',
      'subtitle': 'When someone follows you',
      'icon': 'person_add',
      'color': Colors.green,
    },
    {
      'id': 'mention',
      'title': 'Mentions',
      'subtitle': 'When someone mentions you',
      'icon': 'alternate_email',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilters = List.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          _buildFilterOptions(),
          _buildActionButtons(context),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      width: 12.w,
      height: 0.5.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'filter_list',
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Notifications',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Choose which notifications to show',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      constraints: BoxConstraints(maxHeight: 50.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilters.contains(option['id']);
          final isAllSelected = _selectedFilters.contains('all');

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: (option['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: option['icon'],
                  size: 5.w,
                  color: option['color'],
                ),
              ),
              title: Text(
                option['title'],
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                option['subtitle'],
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              trailing: _buildCheckbox(
                  isSelected, option['id'] == 'all' && isAllSelected),
              onTap: () => _toggleFilter(option['id']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckbox(bool isSelected, bool isAllAndSelected) {
    return Container(
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.primary
            : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isSelected
          ? CustomIconWidget(
              iconName: 'check',
              size: 4.w,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllFilters,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Clear All',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _applyFilters(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFilter(String filterId) {
    setState(() {
      if (filterId == 'all') {
        if (_selectedFilters.contains('all')) {
          _selectedFilters.clear();
        } else {
          _selectedFilters.clear();
          _selectedFilters.add('all');
        }
      } else {
        _selectedFilters.remove('all');
        if (_selectedFilters.contains(filterId)) {
          _selectedFilters.remove(filterId);
        } else {
          _selectedFilters.add(filterId);
        }

        if (_selectedFilters.isEmpty) {
          _selectedFilters.add('all');
        }
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
      _selectedFilters.add('all');
    });
  }

  void _applyFilters(BuildContext context) {
    widget.onFiltersChanged(_selectedFilters);
    Navigator.pop(context);
  }
}
