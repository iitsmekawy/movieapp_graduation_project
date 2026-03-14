import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/api_service.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/movie_interaction_service.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';
import 'package:movieapp_graduation_project_amr/features/profile/data/user_service.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/widgets/movie_stat_item.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/widgets/movie_thumbnail_card.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/widgets/cast_card.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ApiService _apiService = ApiService();
  final MovieInteractionService _interactionService = MovieInteractionService();

  Movie? _movie;
  List<Movie> _similarMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final movie = await _apiService.fetchMovieDetails(widget.movieId);
      final similar = await _apiService.fetchSimilarMovies(widget.movieId);
      if (mounted) {
        setState(() {
          _movie = movie;
          _similarMovies = similar;
          _isLoading = false;
        });

        UserService().addToHistory(
          movieId: widget.movieId,
          movieName: movie.title,
          movieType: movie.genres.isNotEmpty ? movie.genres.first : 'Generic',
        );
      }
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
            child: CircularProgressIndicator(color: AppColors.primaryYellow)),
      );
    }

    if (_movie == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child:
                Text("Movie not found", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWatchButton(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 30),
                  _buildSectionTitle(AppLocalizations.of(context)!.screenShots),
                  _buildScreenshots(),
                  const SizedBox(height: 30),
                  _buildSectionTitle(AppLocalizations.of(context)!.similar),
                  _buildSimilarMovies(),
                  const SizedBox(height: 30),
                  _buildSectionTitle(AppLocalizations.of(context)!.summary),
                  _buildSummary(),
                  const SizedBox(height: 30),
                  _buildSectionTitle(AppLocalizations.of(context)!.cast),
                  _buildCastList(),
                  const SizedBox(height: 30),
                  _buildSectionTitle(AppLocalizations.of(context)!.genres),
                  _buildGenres(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: _movie!.largeCoverImage,
          width: double.infinity,
          height: 500,
          fit: BoxFit.cover,
        ),
        Container(
          height: 500,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.5),
                AppColors.background,
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                StreamBuilder<bool>(
                  stream: _interactionService.saveStream(widget.movieId),
                  builder: (context, snapshot) {
                    final isSaved = snapshot.data ?? false;
                    return IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          key: ValueKey(isSaved),
                          color:
                              isSaved ? AppColors.primaryYellow : Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        if (_movie == null) return;
                        await _interactionService.toggleSave(
                          movieId: widget.movieId,
                          movieName: _movie!.title,
                          movieType: _movie!.genres.isNotEmpty
                              ? _movie!.genres.first
                              : 'Generic',
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: AppColors.primaryYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  size: 50, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Text(
                _movie!.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _movie!.year.toString(),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWatchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          AppLocalizations.of(context)!.watch,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<({int count, bool isLiked})>(
          stream: _interactionService.likesStream(widget.movieId),
          builder: (context, snapshot) {
            final count = snapshot.data?.count ?? _movie!.likeCount;
            final isLiked = snapshot.data?.isLiked ?? false;

            return GestureDetector(
              onTap: () async {
                if (_movie == null) return;
                await _interactionService.toggleLike(
                  movieId: widget.movieId,
                  movieName: _movie!.title,
                  movieType: _movie!.genres.isNotEmpty
                      ? _movie!.genres.first
                      : 'Generic',
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: isLiked
                      ? AppColors.primaryYellow.withValues(alpha: 0.15)
                      : const Color(0xFF282A28),
                  borderRadius: BorderRadius.circular(10),
                  border: isLiked
                      ? Border.all(color: AppColors.primaryYellow, width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isLiked),
                        color: AppColors.primaryYellow,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      count.toString(),
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        MovieStatItem(
            icon: Icons.access_time_filled, value: "${_movie!.runtime}m"),
        MovieStatItem(icon: Icons.star, value: _movie!.rating.toString()),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildScreenshots() {
    if (_movie!.screenshots == null) return const SizedBox();
    return Column(
      children: _movie!.screenshots!.map((url) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimilarMovies() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarMovies.length,
        itemBuilder: (context, index) {
          return MovieThumbnailCard(
            movie: _similarMovies[index],
            useReplacement: true,
          );
        },
      ),
    );
  }

  Widget _buildSummary() {
    return Text(
      _movie!.descriptionFull,
      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
    );
  }

  Widget _buildCastList() {
    if (_movie!.cast == null) return const SizedBox();
    return Column(
      children: _movie!.cast!.map((cast) => CastCard(cast: cast)).toList(),
    );
  }

  Widget _buildGenres() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _movie!.genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF282A28),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(genre, style: const TextStyle(color: Colors.white70)),
        );
      }).toList(),
    );
  }
}
