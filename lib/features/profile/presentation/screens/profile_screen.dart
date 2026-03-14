import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/features/auth/data/auth_service.dart';
import 'package:movieapp_graduation_project_amr/features/profile/data/user_service.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/api_service.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';
import 'package:movieapp_graduation_project_amr/core/widgets/rating_badge.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/screens/movie_details_screen.dart';
import 'package:movieapp_graduation_project_amr/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:movieapp_graduation_project_amr/features/auth/presentation/screens/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';
import 'package:movieapp_graduation_project_amr/main.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Movie> _historyMovies = [];
  List<Movie> _watchlistMovies = [];
  bool _isLoadingHistory = true;
  bool _isLoadingWatchlist = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
    _loadWatchlist();
    _userService.addListener(_onUserUpdate);
    // Load name, phone, avatar from Firestore
    _userService.loadFromFirestore();
  }

  void _onUserUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userService.removeListener(_onUserUpdate);
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final historyIds = await _userService.getHistory();
      if (historyIds.isEmpty) {
        if (mounted) setState(() { _historyMovies = []; _isLoadingHistory = false; });
        return;
      }
      
      final movies = await Future.wait(
        historyIds.map((id) => _apiService.fetchMovieDetails(id))
      );
      
      if (mounted) {
        setState(() {
          _historyMovies = movies.toList();
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _loadWatchlist() async {
    try {
      final watchlistIds = await _userService.getWatchlist();
      if (watchlistIds.isEmpty) {
        if (mounted) setState(() { _watchlistMovies = []; _isLoadingWatchlist = false; });
        return;
      }
      
      final movies = await Future.wait(
        watchlistIds.map((id) => _apiService.fetchMovieDetails(id))
      );
      
      if (mounted) {
        setState(() {
          _watchlistMovies = movies.toList();
          _isLoadingWatchlist = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingWatchlist = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildLanguageToggle(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: _buildTabBar(),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildWatchListGrid(),
              _buildHistoryGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(_userService.selectedAvatar),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userService.name.isNotEmpty
                      ? _userService.name
                      : (FirebaseAuth.instance.currentUser?.email ?? ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (_userService.phone.isNotEmpty)
                  Text(
                    _userService.phone,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(count: _watchlistMovies.length.toString(), label: AppLocalizations.of(context)!.wishList),
                    _StatItem(count: _historyMovies.length.toString(), label: AppLocalizations.of(context)!.history),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                l10n.editProfile,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                await _authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.exit, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  const Icon(Icons.logout, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          final newLocale = isArabic ? const Locale('en') : const Locale('ar');
          MyApp.of(context)?.setLocale(newLocale);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryYellow, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.language_rounded, color: AppColors.primaryYellow, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    isArabic ? 'اللغة / Language' : 'Language / اللغة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(isArabic),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isArabic ? 'English' : 'العربية',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primaryYellow,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      tabs: [
        Tab(
          icon: const Icon(Icons.list_rounded, size: 30),
          text: l10n.wishList,
        ),
        Tab(
          icon: const Icon(Icons.folder_open_rounded, size: 30),
          text: l10n.history,
        ),
      ],
    );
  }

  Widget _buildWatchListEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Empty 1.png',
            width: 180,
            height: 180,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchListGrid() {
    if (_isLoadingWatchlist) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
    }
    if (_watchlistMovies.isEmpty) {
      return _buildWatchListEmpty();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _watchlistMovies.length,
      itemBuilder: (context, index) {
        final movie = _watchlistMovies[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(movieId: movie.id),
              ),
            );
            // Refresh in case it was modified
            _loadWatchlist();
            _loadHistory();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: movie.mediumCoverImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: ScaleTransition(
                    scale: const AlwaysStoppedAnimation(0.8),
                    child: RatingBadge(rating: movie.rating),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryGrid() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
    }
    if (_historyMovies.isEmpty) {
      return const Center(
        child: Text(
          "No history available.",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _historyMovies.length,
      itemBuilder: (context, index) {
        final movie = _historyMovies[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(movieId: movie.id),
              ),
            );
            _loadHistory();
            _loadWatchlist();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: movie.mediumCoverImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: ScaleTransition(
                    scale: const AlwaysStoppedAnimation(0.8),
                    child: RatingBadge(rating: movie.rating),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 16),
        ),
      ],
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      height: 72,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}
