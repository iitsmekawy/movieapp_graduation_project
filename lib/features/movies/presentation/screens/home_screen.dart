import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/api_service.dart';
import 'package:movieapp_graduation_project_amr/features/search/presentation/screens/search_screen.dart';
import 'package:movieapp_graduation_project_amr/features/browse/presentation/screens/browse_screen.dart';
import 'package:movieapp_graduation_project_amr/features/profile/presentation/screens/profile_screen.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/widgets/main_movie_card.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/widgets/movie_thumbnail_card.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/widgets/section_header.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  final ApiService _apiService = ApiService();
  int _currentIndex = 0;
  int _bottomNavIndex = 0;

  List<Movie> _movies = [];
  List<Movie> _actionMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final movies = await _apiService.fetchMovies();
      final actionMovies = await _apiService.fetchMoviesByCategory('Action');
      setState(() {
        _movies = movies;
        _actionMovies = actionMovies;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryYellow),
        ),
      );
    }

    final List<Widget> screens = [
      _buildHomeContent(),
      const MovieSearchScreen(),
      const MovieBrowseScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavBar(),
      body: screens[_bottomNavIndex],
    );
  }

  Widget _buildHomeContent() {
    return Stack(
      children: [
        if (_movies.isNotEmpty)
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: CachedNetworkImage(
                imageUrl: _movies[_currentIndex].largeCoverImage,
                key: ValueKey(_movies[_currentIndex].id),
                width: double.infinity,
                height: MediaQuery.of(context).size.height + 60,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorWidget: (context, url, error) =>
                    Container(color: Colors.black),
              ),
            ),
          ),

        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.4)),
        ),

        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color.fromARGB(150, 0, 0, 0),
                  AppColors.background,
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),

        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/images/Available Now.png',
                height: 100,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 10),

              if (_movies.isNotEmpty)
                SizedBox(
                  height: 420,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.75),
                    itemCount: _movies.length > 10 ? 10 : _movies.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      double scale = index == _currentIndex ? 1.0 : 0.85;
                      return Transform.scale(
                        scale: scale,
                        child: MainMovieCard(movie: _movies[index]),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              Image.asset(
                'assets/images/Watch Now.png',
                height: 110,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              SectionHeader(
                title: AppLocalizations.of(context)!.action,
                onSeeMore: () => setState(() => _bottomNavIndex = 2),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: _actionMovies.length,
                  itemBuilder: (context, index) =>
                      MovieThumbnailCard(movie: _actionMovies[index]),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF282A28),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_rounded, 0),
          _navItem(Icons.search_rounded, 1),
          _navItem(Icons.explore_rounded, 2),
          _navItem(Icons.person_rounded, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white60,
          size: 28,
        ),
      ),
    );
  }
}
