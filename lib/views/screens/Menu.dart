import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/views/widgets/cart_icon.dart';
import 'package:lush/views/models/item_list_view.dart';
import 'package:lush/services/item_service.dart';
import 'package:lush/views/widgets/filter_options.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_text_styles.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> topBarAnimation;
  double topBarOpacity = 0.2;
  bool isLoading = true;
  final UserRepository userRepository = getIt.get();
  final ItemService itemService = getIt.get<ItemService>();

  // Category selection
  String _selectedCategory = 'Premium'; // Default category
  final List<String> _categories = ['Premium', 'Signature', 'Delight'];

  // Size selection (will be populated dynamically)
  List<String> _sizes = [];
  String _selectedSize = '';

  // Type selection
  final String _selectedType = 'CHARGE'; // Default to one-time purchases
  final List<String> _types = [
    'CHARGE',
    'PLAN',
    'ADDON'
  ]; // One-time, Subscription, Add-on

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchSizes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading sizes'));
        }
        _sizes = snapshot.data ?? [];
        if (_selectedSize.isEmpty && _sizes.isNotEmpty) {
          _selectedSize = _sizes[0];
        }
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: Container(
            decoration: const BoxDecoration(color: AppColors.lightBackground),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 120.h), // Space for app bar
                      // Filter options widget
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: FilterOptions(
                          selectedCategory: _selectedCategory,
                          categories: _categories,
                          onCategoryChanged: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedSize: _selectedSize,
                          sizes: _sizes,
                          onSizeChanged: (size) {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                        ),
                      ),
                      // Item list
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: ItemListView(
                            mainScreenAnimation:
                                Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: animationController,
                                curve: const Interval(0.3, 0.7,
                                    curve: Curves.easeOutCubic),
                              ),
                            ),
                            mainScreenAnimationController: animationController,
                            category: _selectedCategory,
                            size: _selectedSize,
                            type: _selectedType,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getAppBarUI(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _fetchSizes() async {
    try {
      final items = await itemService.fetchItems();
      final sizes = items
          .map((item) => item.servingSize)
          .where((size) => size.toString().isNotEmpty)
          .map((size) => size.toString())
          .toSet()
          .toList();
      sizes.sort();
      return sizes;
    } catch (e) {
      return ['Small (100ml)', 'Medium (250ml)', 'Large (500ml)'];
    }
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withAlpha(242),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.r),
                      bottomRight: Radius.circular(32.r),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppColors.grey.withAlpha(76),
                          offset: const Offset(0, 2),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
                        child: Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(30.r),
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.info,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'menu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.sp,
                                      color: AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Fresh cold-pressed juices',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CartIcon(
                              size: 20.sp,
                              onTap: () {
                                Navigator.of(context).pushNamed('/cart');
                              },
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: AppColors.white),
                              onSelected: (value) {
                                switch (value) {
                                  case 'subscriptions':
                                    Navigator.pushNamed(
                                        context, '/manage-subscriptions');
                                    break;
                                  case 'orders':
                                    Navigator.pushNamed(
                                        context, '/order-history');
                                    break;
                                  case 'invoices':
                                    Navigator.pushNamed(context, '/invoices');
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'subscriptions',
                                  child: Text('Manage Subscriptions'),
                                ),
                                const PopupMenuItem(
                                  value: 'orders',
                                  child: Text('Order History'),
                                ),
                                const PopupMenuItem(
                                  value: 'invoices',
                                  child: Text('View Invoices'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
