import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../theme.dart';
import 'dynamic_juice.dart';

class DetailedJuiceCard extends StatelessWidget {
  final DynamicJuice juice;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const DetailedJuiceCard({
    super.key,
    required this.juice,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                HexColor(juice.startColor),
                HexColor(juice.endColor),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with image and title
                Row(
                  children: [
                    // Juice image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          juice.imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.local_drink,
                              size: 30,
                              color: Colors.white.withValues(alpha: 0.8 * 255),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            juice.displayName,
                            style: const TextStyle(
                              fontFamily: LushTheme.fontName,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (juice.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              juice.description,
                              style: TextStyle(
                                fontFamily: LushTheme.fontName,
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ingredients
                if (juice.meals.isNotEmpty) ...[
                  Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontFamily: LushTheme.fontName,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    juice.displayIngredients,
                    style: TextStyle(
                      fontFamily: LushTheme.fontName,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Benefits
                if (juice.benefits.isNotEmpty) ...[
                  Text(
                    'Benefits:',
                    style: TextStyle(
                      fontFamily: LushTheme.fontName,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    juice.displayBenefits,
                    style: TextStyle(
                      fontFamily: LushTheme.fontName,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Info row
                Row(
                  children: [
                    // Calories
                    if (juice.kacl > 0) ...[
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        juice.displayCalories,
                        style: TextStyle(
                          fontFamily: LushTheme.fontName,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    // Serving size
                    if (juice.servingSize.isNotEmpty) ...[
                      Icon(
                        Icons.local_drink,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        juice.servingSize,
                        style: TextStyle(
                          fontFamily: LushTheme.fontName,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    // Preparation time
                    if (juice.preparationTime.isNotEmpty) ...[
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        juice.preparationTime,
                        style: TextStyle(
                          fontFamily: LushTheme.fontName,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Tags
                if (juice.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: juice.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontFamily: LushTheme.fontName,
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Customization indicator
                    if (juice.hasCustomization)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Customizable',
                              style: TextStyle(
                                fontFamily: LushTheme.fontName,
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Add to cart button
                    if (onAddToCart != null)
                      ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          foregroundColor: HexColor(juice.endColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
