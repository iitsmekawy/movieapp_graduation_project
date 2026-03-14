import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/screens/home_screen.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/screens/register_screen.dart';
import 'package:movieapp_graduation_project_amr/main.dart';
import 'package:movieapp_graduation_project_amr/features/auth/data/auth_service.dart';
import 'package:movieapp_graduation_project_amr/features/profile/data/user_service.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_assets.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(email, password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MovieHomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
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

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        if (mounted) setState(() => _isLoading = false);
        return; // User cancelled — do nothing
      }
      UserService().loadFromFirestore().catchError((_) {});

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MovieHomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Google sign-in failed: $e');
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    AppAssets.logo,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),

                AuthTextField(
                  controller: _emailController,
                  hintText: l10n.email,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                AuthTextField(
                  controller: _passwordController,
                  hintText: l10n.password,
                  prefixIcon: Icons.lock,
                  isObscured: _isObscured,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.forgetPassword,
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          l10n.login,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${l10n.dontHaveAccount} ",
                      style: const TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        l10n.createOne,
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppColors.primaryYellow,
                        thickness: 1,
                        indent: 40,
                        endIndent: 10,
                      ),
                    ),
                    Text(
                      l10n.or,
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: AppColors.primaryYellow,
                        thickness: 1,
                        indent: 10,
                        endIndent: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SocialAuthButton(
                  label: l10n.loginWithGoogle,
                  onPressed: _loginWithGoogle,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 32),

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
                            border: Border.all(
                              color: AppColors.primaryYellow,
                              width: 2,
                            ),
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
        ),
      ),
    );
  }
}
