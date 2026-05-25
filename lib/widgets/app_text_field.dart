import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_theme.dart';

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
  final void Function(String)? onChanged;
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
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
            fillColor: AppColors.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.lightDivider,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.lightDivider,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.primaryOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.lightDivider,
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
