import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme.dart';

class FilterOptions extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategoryChanged;

  final String selectedSize;
  final List<String> sizes;
  final Function(String) onSizeChanged;

  const FilterOptions({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.selectedSize,
    required this.sizes,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header with improved UI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: LushTheme.nearlyBlue,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontFamily: LushTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: LushTheme.darkerText,
                    ),
                  ),
                ],
              ),
              // All filters button
              ElevatedButton.icon(
                onPressed: () {
                  // Show filter dialog with all options
                  _showFilterDialog(context);
                },
                icon: Icon(
                  Icons.filter_list,
                  size: 16.sp,
                  color: Colors.white,
                ),
                label: Text(
                  'All Filters',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LushTheme.nearlyBlue,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  minimumSize: Size(0, 32.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Filter chips in a horizontal scrollable row with visual indicators
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category filter
                _buildFilterChip(
                  label: selectedCategory,
                  icon: Icons.category,
                  onTap: () => _showCategorySelectionDialog(context),
                  color: LushTheme.orangeAccent,
                ),
                SizedBox(width: 8.w),

                // Size filter
                _buildFilterChip(
                  label: selectedSize,
                  icon: Icons.straighten,
                  onTap: () => _showSizeSelectionDialog(context),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 14.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              color: color,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Track local filter selections
    String localCategory = selectedCategory;
    String localSize = selectedSize;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.filter_list, color: LushTheme.nearlyBlue, size: 24.sp),
              SizedBox(width: 8.w),
              const Text('Filter Options'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category selection
                  Row(
                    children: [
                      Icon(Icons.category,
                          color: LushTheme.orangeAccent, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Juice Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: categories.map((category) {
                      final isSelected = category == localCategory;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              localCategory = category;
                            });
                          }
                        },
                        selectedColor: LushTheme.orangeAccent.withValues(alpha: 0.2),
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? LushTheme.orangeAccent
                              : LushTheme.darkerText,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        avatar: isSelected
                            ? Icon(Icons.check_circle,
                                color: LushTheme.orangeAccent, size: 16.sp)
                            : null,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),

                  // Size selection
                  Row(
                    children: [
                      Icon(Icons.straighten, color: Colors.green, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Bottle Size',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: sizes.map((size) {
                      final isSelected = size == localSize;
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              localSize = size;
                            });
                          }
                        },
                        selectedColor: Colors.green.withValues(alpha: 0.2),
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.green : LushTheme.darkerText,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        avatar: isSelected
                            ? Icon(Icons.check_circle,
                                color: Colors.green, size: 16.sp)
                            : null,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply all filters at once
                onCategoryChanged(localCategory);
                onSizeChanged(localSize);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LushTheme.nearlyBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ],
        );
      }),
    );
  }

  void _showCategorySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.category, color: LushTheme.orangeAccent, size: 20.sp),
            SizedBox(width: 8.w),
            const Text('Select Juice Category'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              final isSelected = category == selectedCategory;
              return ListTile(
                onTap: () {
                  onCategoryChanged(category);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? LushTheme.orangeAccent.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? LushTheme.orangeAccent : Colors.grey,
                    size: 24.sp,
                  ),
                ),
                title: Text(
                  category,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? LushTheme.orangeAccent
                        : LushTheme.darkerText,
                  ),
                ),
                subtitle: Text(
                  _getCategoryDescription(category),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: LushTheme.lightText,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: LushTheme.orangeAccent)
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                tileColor: isSelected
                    ? LushTheme.orangeAccent.withValues(alpha: 0.05)
                    : null,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Premium':
        return 'Our finest selection of juices';
      case 'Signature':
        return 'BookMyJuice signature blends';
      case 'Delight':
        return 'Light and refreshing options';
      default:
        return '';
    }
  }

  void _showSizeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.straighten, color: Colors.green, size: 20.sp),
            SizedBox(width: 8.w),
            const Text('Select Bottle Size'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sizes.map((size) {
              final isSelected = size == selectedSize;
              return ListTile(
                onTap: () {
                  onSizeChanged(size);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.green : Colors.grey,
                    size: 24.sp,
                  ),
                ),
                title: Text(
                  size,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.green : LushTheme.darkerText,
                  ),
                ),
                subtitle: Text(
                  _getSizeDescription(size),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: LushTheme.lightText,
                  ),
                ),
                trailing:
                    isSelected ? Icon(Icons.check, color: Colors.green) : null,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                tileColor: isSelected ? Colors.green.withValues(alpha: 0.05) : null,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getSizeDescription(String size) {
    switch (size) {
      case 'Small (100ml)':
        return 'Perfect for a quick refreshment';
      case 'Medium (250ml)':
        return 'Our most popular size';
      case 'Large (500ml)':
        return 'Great value for sharing';
      default:
        return '';
    }
  }
}
