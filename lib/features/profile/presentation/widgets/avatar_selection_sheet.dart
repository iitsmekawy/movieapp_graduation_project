import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_assets.dart';

class AvatarSelectionSheet extends StatelessWidget {
  final int selectedAvatarIndex;
  final Function(int) onAvatarSelected;

  const AvatarSelectionSheet({
    super.key,
    required this.selectedAvatarIndex,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0), // Adjusted padding
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Choose Avatar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: AppAssets.avatars.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  onAvatarSelected(index);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedAvatarIndex == index
                          ? AppColors.primaryYellow
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(AppAssets.avatars[index]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // Bottom padding
          ],
        ),
      ),
    );
  }
}
