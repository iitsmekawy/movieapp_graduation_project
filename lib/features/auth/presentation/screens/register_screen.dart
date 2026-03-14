import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';
import 'package:movieapp_graduation_project_amr/main.dart';
import 'package:movieapp_graduation_project_amr/features/auth/data/auth_service.dart';
import 'package:movieapp_graduation_project_amr/features/profile/data/user_service.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/screens/login_screen.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_assets.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  final PageController _avatarController = PageController(
    initialPage: 4,
    viewportFraction: 0.35,
  );

  int _currentPage = 4;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _avatarController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmail(email, password);
      await _authService.updateDisplayName(name);

      UserService().saveToFirestore(
        name: name,
        phone: _phoneController.text.trim(),
        email: email,
        avatarIndex: _currentPage,
      ).catchError((_) {});

      await _authService.signOut();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }
      if (!mounted) return;
      _showError(message);
    } catch (e) {
      if (!mounted) return;
      _showError('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
          l10n.register,
          style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 10),

            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _avatarController,
                itemCount: AppAssets.avatars.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  double scale = _currentPage == index ? 1.0 : 0.7;
                  double opacity = _currentPage == index ? 1.0 : 0.5;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(AppAssets.avatars[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (_currentPage == index) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.avatar,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            
            AuthTextField(
              controller: _nameController,
              hintText: l10n.name,
              prefixIcon: Icons.badge,
            ),
            const SizedBox(height: 15),

            AuthTextField(
              controller: _emailController,
              hintText: l10n.email,
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            AuthTextField(
              controller: _passwordController,
              hintText: l10n.password,
              prefixIcon: Icons.lock,
              isObscured: _isPasswordObscured,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),

            AuthTextField(
              controller: _confirmPasswordController,
              hintText: l10n.confirmPassword,
              prefixIcon: Icons.lock,
              isObscured: _isConfirmPasswordObscured,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),

            AuthTextField(
              controller: _phoneController,
              hintText: l10n.phoneNumber,
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        l10n.createAccount,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.alreadyHaveAccount,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Center(
              child: SizedBox(
                width: 100,
                height: 44,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: isArabic ? 56 : 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryYellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.primaryYellow, width: 2),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              MyApp.of(context)?.setLocale(const Locale('en'));
                            },
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Center(
                                child: Image.asset(
                                  AppAssets.lrFlag,
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              MyApp.of(context)?.setLocale(const Locale('ar'));
                            },
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Center(
                                child: Image.asset(
                                  AppAssets.egFlag,
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
