import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../bloc/CartBloc/cart_bloc.dart';
import '../../bloc/CartBloc/cart_event.dart';
import '../../bloc/CartBloc/cart_state.dart';
import 'package:lush/theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'razorpay';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    // Show success message
    Fluttertoast.showToast(
      msg: "Payment successful! Order placed.",
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: AppColors.success,
    );
    
    // Clear the cart
    context.read<CartBloc>().add(ClearCart());
    
    // Navigate to order confirmation
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    // Show error message
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message}",
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: AppColors.error,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    Fluttertoast.showToast(
      msg: "External wallet selected: ${response.walletName}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void _processPayment(double amount, String description) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });

    if (_selectedPaymentMethod == 'razorpay') {
      var options = {
        'key': 'rzp_test_5O37uNi7fzqqXI',
        'amount': (amount * 100).toInt(), // Convert to paise
        'name': 'BookMyJuice',
        'description': description,
        'prefill': {
          'contact': _phoneController.text,
          'email': _emailController.text,
          'name': _nameController.text,
        },
        'external': {
          'wallets': ['paytm', 'gpay', 'phonepe']
        }
      };
      
      try {
        _razorpay.open(options);
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        
        Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppColors.error,
        );
      }
    } else if (_selectedPaymentMethod == 'cod') {
      // Handle Cash on Delivery
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isProcessing = false;
        });
        
        // Show success message
        Fluttertoast.showToast(
          msg: "Order placed successfully! Pay on delivery.",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: AppColors.success,
        );
        
        // Clear the cart
        context.read<CartBloc>().add(ClearCart());
        
        // Navigate to order confirmation
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80.r,
                      color: AppColors.lightTextDisabled,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/menu');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Browse Juices'),
                    ),
                  ],
                ),
              );
            }
            
            final totalAmount = items.fold<double>(
              0,
              (sum, item) => sum + item.totalPrice,
            );
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ...items.map((item) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity}x ${item.item.name ?? ''} (${item.selectedPrice?.name ?? 'Regular'})',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${item.totalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            Divider(height: 24.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  '₹${totalAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryOrangeDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Delivery Information
                    Text(
                      'Delivery Information',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your delivery address';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Payment Method
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Row(
                              children: [
                                Icon(Icons.payment, color: AppColors.info),
                                SizedBox(width: 8.w),
                                const Text('Pay with Razorpay'),
                              ],
                            ),
                            subtitle: const Text('Credit/Debit Card, UPI, Wallet'),
                            value: 'razorpay',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Row(
                              children: [
                                Icon(Icons.money, color: AppColors.success),
                                SizedBox(width: 8.w),
                                const Text('Cash on Delivery'),
                              ],
                            ),
                            subtitle: const Text('Pay when your order arrives'),
                            value: 'cod',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _processPayment(
                                totalAmount,
                                'Order from BookMyJuice - ${items.length} items',
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          disabledBackgroundColor: AppColors.grey,
                        ),
                        child: _isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  const Text('Processing...'),
                                ],
                              )
                            : Text(
                                'Place Order - ₹${totalAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is CartError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading cart',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<CartBloc>().add(LoadCart());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Back to Cart'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
