import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/screens/login_screen.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final Dio _dio = Dio();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final response = await _dio.get(
        'https://movies-api.accel.li/api/v2/list_movies.json',
      );
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching movies: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryYellow),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              _buildPage(
                index: 0,
                title: 'Find Your Next\nFavorite Movie Here',
                description:
                    'Get access to a huge library of movies to suit all tastes. You will surely like it.',
                imageAsset: 'assets/images/Movies Posters Group.png',
                hasCard: false,
              ),
              _buildPage(
                index: 1,
                title: 'Discover Movies',
                description:
                    'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
                imageAsset: 'assets/images/2.png',
              ),
              _buildPage(
                index: 2,
                title: 'Explore All Genres',
                description:
                    'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
                imageAsset: 'assets/images/3.png',
              ),
              _buildPage(
                index: 3,
                title: 'Create Watchlists',
                description:
                    'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.',
                imageAsset: 'assets/images/4.png',
              ),
              _buildPage(
                index: 4,
                title: 'Rate, Review, and Learn',
                description:
                    'Share your thoughts on the movies you\'ve watched. Dive deep into film details and help others discover great movies with your reviews.',
                imageAsset: 'assets/images/5.png',
              ),
              _buildPage(
                index: 5,
                title: 'Start Watching Now',
                description: '',
                imageAsset: 'assets/images/6.png',
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required int index,
    required String title,
    required String description,
    required String imageAsset,
    bool isLast = false,
    bool hasCard = true,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: index == 0 ? Alignment.center : const Alignment(0, -1.0),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              color: hasCard
                  ? const Color(0xFF083236).withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.2),
              colorBlendMode: hasCard ? BlendMode.multiply : BlendMode.darken,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),
        _buildTextContent(
          title: title,
          description: description,
          buttonText: index == 0 ? 'Explore Now' : (isLast ? 'Finish' : 'Next'),
          hasCard: hasCard,
          showBack: index > 0,
          onPressed: () {
            if (isLast) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          onBack: () => _pageController.previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    bool showBack = false,
    VoidCallback? onBack,
    bool hasCard = true,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasCard ? const Color(0xFF121312) : Colors.transparent,
          borderRadius: hasCard
              ? const BorderRadius.only(
                  topLeft: Radius.circular(42),
                  topRight: Radius.circular(42),
                )
              : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: hasCard ? 34.0 : 60.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (description.isNotEmpty)
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 32),
            _buildButton(
              text: buttonText,
              onPressed: onPressed,
              isPrimary: true,
            ),
            if (showBack) ...[
              const SizedBox(height: 14),
              _buildButton(
                text: 'Back',
                onPressed: onBack ?? () {},
                isPrimary: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: AppColors.primaryYellow, width: 1.5),
                foregroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
