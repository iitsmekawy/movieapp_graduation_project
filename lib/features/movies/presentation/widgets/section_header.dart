import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeMore;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeMore,
            child: const Text(
              "See More →",
              style: TextStyle(color: AppColors.primaryYellow, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
