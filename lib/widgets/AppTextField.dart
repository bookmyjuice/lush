import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design System Colors
class AppColors {
  static const Color primaryOrange = Color(0xFFFF8C42);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
}

/// Design System Spacing
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// Reusable TextField component following BookMyJuice Design System
/// 
/// Usage:
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   prefixIcon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) {
///     if (value == null || value.isEmpty) {
///       return 'Email is required';
///     }
///     if (!isValidEmail(value)) {
///       return 'Enter a valid email';
///     }
///     return null;
///   },
/// )
/// ```
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final Widget? suffixWidget;

  const AppTextField({
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.controller,
    this.readOnly = false,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.suffixWidget,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.nearlyBlack,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          readOnly: readOnly,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.nearlyBlack)
                : null,
            suffixIcon: suffixWidget ?? (suffixIcon != null
                ? Icon(suffixIcon, size: 20, color: AppColors.darkGrey)
                : null),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.grey,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.grey,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.grey,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}

/// Email validation helper
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Phone validation helper (10-digit Indian number)
bool isValidPhone(String phone) {
  return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
}

/// Password validation helper
bool isValidPassword(String password) {
  // Minimum 8 characters, at least 1 uppercase, 1 lowercase, 1 number, 1 special character
  return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
      .hasMatch(password);
}

/// ZIP code validation helper (6-digit Indian PIN)
bool isValidZipCode(String zip) {
  return RegExp(r'^\d{6}$').hasMatch(zip);
}

/// Country code validation helper (2-letter ISO code)
bool isValidCountryCode(String country) {
  return RegExp(r'^[A-Z]{2}$').hasMatch(country);
}
