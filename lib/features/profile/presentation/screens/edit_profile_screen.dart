import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/features/profile/data/user_service.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/screens/login_screen.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieapp_graduation_project_amr/features/auth/data/auth_service.dart';
import 'package:movieapp_graduation_project_amr/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:movieapp_graduation_project_amr/features/profile/presentation/widgets/avatar_selection_sheet.dart';
import 'package:movieapp_graduation_project_amr/features/profile/presentation/widgets/reset_password_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late int _selectedAvatarIndex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _userService.name);
    _phoneController = TextEditingController(text: _userService.phone);
    _selectedAvatarIndex = _userService.selectedAvatarIndex;

    _userService.loadFromFirestore().then((_) {
      if (mounted) {
        setState(() {
          _nameController.text = _userService.name;
          _phoneController.text = _userService.phone;
          _selectedAvatarIndex = _userService.selectedAvatarIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ResetPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          style: const TextStyle(
              color: AppColors.primaryYellow, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSelectedAvatar(),
                  const SizedBox(height: 40),
                  ProfileTextField(
                    controller: _nameController,
                    hint: AppLocalizations.of(context)!.name,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),
                  ProfileTextField(
                    controller: _phoneController,
                    hint: AppLocalizations.of(context)!.phoneNumber,
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _showResetPasswordDialog,
                      child: Text(
                        AppLocalizations.of(context)!.resetPassword,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSelectedAvatar() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AvatarSelectionSheet(
                selectedAvatarIndex: _selectedAvatarIndex,
                onAvatarSelected: (index) {
                  setState(() => _selectedAvatarIndex = index);
                },
              ),
            );
          },
          child: CircleAvatar(
            radius: 70,
            backgroundImage:
                AssetImage(AppAssets.avatars[_selectedAvatarIndex]),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
                color: AppColors.primaryYellow, shape: BoxShape.circle),
            child: const Icon(Icons.edit, size: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleUpdateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : Text(AppLocalizations.of(context)!.updateData,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _handleDeleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(AppLocalizations.of(context)!.deleteAccount,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdateProfile() async {
    setState(() => _isSaving = true);
    try {
      await _userService.updateInFirestore(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarIndex: _selectedAvatarIndex,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      String message = 'Failed to update profile. Try again.';
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        message =
            'For security, please logout and login again to change your email.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('Delete Account',
            style: TextStyle(color: AppColors.error)),
        content: const Text(
            'Are you sure you want to delete your account? This action is permanent.',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white70))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .delete();
        }
        await AuthService().deleteAccount();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          String message = 'Failed to delete account.';
          if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
            message = 'Please login again before deleting your account.';
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message), backgroundColor: AppColors.error));
        }
      }
    }
  }
}
