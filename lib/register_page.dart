import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color backgroundColor = const Color(0xFF121212);
  final Color fieldColor = const Color(0xFF252525);
  final Color primaryYellow = const Color(0xFFFFC107);

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  final PageController _avatarController = PageController(
      initialPage: 1,
      viewportFraction: 0.35
  );

  int _currentPage = 1;

  final List<String> avatars = [
    'assets/images/gamer (right)-1.png',
    'assets/images/gamer (main).png',
    'assets/images/gamer (left)-2.png',
  ];

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Register',
            style: TextStyle(color: primaryYellow, fontWeight: FontWeight.bold)),
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
                itemCount: avatars.length,
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
                              border: _currentPage == index
                                  ? Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 3)
                                  : null,
                              image: DecorationImage(
                                image: AssetImage(avatars[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (_currentPage == index) ...[
                            const SizedBox(height: 8),
                            const Text("Avatar",
                                style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            _buildInputField(label: 'Name', icon: Icons.badge_outlined),
            _buildInputField(label: 'Email', icon: Icons.email_outlined),

            _buildInputField(
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                isObscured: _isPasswordObscured,
                onToggle: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                }
            ),

            _buildInputField(
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
                isObscured: _isConfirmPasswordObscured,
                onToggle: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                }
            ),

            _buildInputField(label: 'Phone Number', icon: Icons.phone_outlined),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already Have Account?",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Login",
                      style: TextStyle(color: primaryYellow, fontWeight: FontWeight.w400)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: primaryYellow, width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 20),
                  Text('🇪🇬', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        obscureText: isPassword ? isObscured : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.white54
            ),
            onPressed: onToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}