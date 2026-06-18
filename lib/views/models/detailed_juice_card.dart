import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart' as hex;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'dynamic_juice.dart';

class DetailedJuiceCard extends StatelessWidget {
  final DynamicJuice juice;
  final VoidCallback? onTap;

  const DetailedJuiceCard({
    super.key,
    required this.juice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: [
              hex.HexColor(juice.startColor.isNotEmpty ? juice.startColor : '#FF9800'),
              hex.HexColor(juice.endColor.isNotEmpty ? juice.endColor : '#FF5722'),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: hex.HexColor(juice.endColor.isNotEmpty ? juice.endColor : '#FF5722').withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with emoji and name
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.local_drink,
                      size: 30,
                      color: Colors.white.withValues(alpha: 0.8 * 255),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          juice.name.isNotEmpty ? juice.name : 'Fresh Juice',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          juice.description.isNotEmpty ? juice.description : 'Delicious and nutritious',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Info cards row
              Row(
                children: [
                  _buildInfoCard(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${juice.kacl} kcal',
                  ),
                  SizedBox(width: 8.w),
                  _buildInfoCard(
                    icon: Icons.water_drop,
                    label: 'Serving',
                    value: juice.servingSize.isNotEmpty ? juice.servingSize : '200ml',
                  ),
                  SizedBox(width: 8.w),
                  _buildInfoCard(
                    icon: Icons.timer,
                    label: 'Shelf Life',
                    value: juice.shelfLife.isNotEmpty ? juice.shelfLife : '3 days',
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Tags
              if (juice.tags.isNotEmpty)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: juice.tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: 16.h),

              // Meals
              if (juice.meals.isNotEmpty) ...[
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: juice.meals.map((meal) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            meal,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: AppTextStyles.fontFamily,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontFamily: AppTextStyles.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}