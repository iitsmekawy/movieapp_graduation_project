import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isObscured;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isObscured = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      obscureText: isObscured,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.darkGray,
        prefixIcon: Icon(prefixIcon, color: AppColors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.white),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
