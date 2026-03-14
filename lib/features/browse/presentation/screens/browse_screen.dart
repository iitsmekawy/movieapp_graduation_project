import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/api_service.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/widgets/movie_grid_item.dart';

class MovieBrowseScreen extends StatefulWidget {
  const MovieBrowseScreen({super.key});

  @override
  State<MovieBrowseScreen> createState() => _MovieBrowseScreenState();
}

class _MovieBrowseScreenState extends State<MovieBrowseScreen> {
  final ApiService _apiService = ApiService();
  final List<String> _categories = [
    "Action",
    "Adventure",
    "Animation",
    "Biography",
    "Comedy",
    "Crime",
    "Drama",
    "Family",
    "Fantasy",
  ];
  String _selectedCategory = "Action";
  List<Movie> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final movies = await _apiService.fetchMoviesByCategory(_selectedCategory);
      if (!mounted) return;
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCategoryTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildMovieGrid(),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case "Action":
        return l10n.action;
      case "Adventure":
        return l10n.adventure;
      case "Animation":
        return l10n.animation;
      case "Biography":
        return l10n.biography;
      case "Comedy":
        return l10n.comedy;
      case "Crime":
        return l10n.crime;
      case "Drama":
        return l10n.drama;
      case "Family":
        return l10n.family;
      case "Fantasy":
        return l10n.fantasy;
      default:
        return category;
    }
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              if (_selectedCategory != category) {
                setState(() => _selectedCategory = category);
                _loadMovies();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primaryYellow : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.primaryYellow,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _getLocalizedCategory(context, category),
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.primaryYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieGrid() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryYellow));
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Text(
          "No movies found in this category",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        return MovieGridItem(movie: _movies[index]);
      },
    );
  }
}
