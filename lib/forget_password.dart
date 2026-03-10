import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final Color backgroundColor = const Color(0xFF121212);
  final Color fieldColor = const Color(0xFF252525);
  final Color primaryYellow = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Forget Password',
          style: TextStyle(
            color: primaryYellow,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),      body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          Container(
            height: 430,
            width: 430,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Forgot password-bro 1.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          // ----------------------------------------


          _buildInputField(
            label: 'Email Address',
            icon: Icons.email_outlined,
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Verify Email',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

        ],
      ),
    ),
    );
  }

  Widget _buildInputField({required String label, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        ),
      ),
    );
  }
}