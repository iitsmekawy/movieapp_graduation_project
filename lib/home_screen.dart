import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  int _currentIndex = 0;
  int _bottomNavIndex = 0;

  final List<String> mainMovies = [
    "assets/images/Card.png",
    "assets/images/Card-1.png",
    "assets/images/Card-2.png"
  ];

  final List<String> actionMovies = [
    "assets/images/Mini Card.png",
    "assets/images/Mini Card1.png",
    "assets/images/Mini Card2.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      bottomNavigationBar: _buildBottomNavBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Image.asset(
                mainMovies[_currentIndex],
                key: ValueKey(mainMovies[_currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
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
                    Color.fromARGB(120, 0, 0, 0),
                    Color.fromARGB(200, 0, 0, 0),
                    Color(0xFF121212),
                  ],
                  stops: [0.0, 0.25, 0.45, 0.7, 1.0],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  "Available Now",
                  style: GoogleFonts.caveat(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 380,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.7),
                    itemCount: mainMovies.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      double scale = index == _currentIndex ? 1.0 : 0.85;
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: scale,
                        child: _mainCard(mainMovies[index]),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Watch Now",
                  style: GoogleFonts.caveat(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _sectionHeader("Action"),

                const SizedBox(height: 15),

                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    itemCount: actionMovies.length,
                    itemBuilder: (context, index) =>
                        _actionCard(actionMovies[index]),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _mainCard(String image) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Align(alignment: Alignment.topLeft, child: RatingBadge()),
      ),
    );
  }

  Widget _actionCard(String image) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Align(alignment: Alignment.topLeft, child: RatingBadge()),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Text("See More →",
              style: TextStyle(color: Color(0xFFFFBB3B), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5))),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff1A1A1A),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFFFFBB3B),
        unselectedItemColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 28), label: ""),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded, size: 28), label: ""),

          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: _bottomNavIndex == 2
                      ? const Color(0xFFFFBB3B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                Icons.explore_rounded,
                color: _bottomNavIndex == 2
                    ? Colors.black
                    : const Color(0xff1A1A1A),
                size: 22,
              ),
            ),
            label: "",
          ),

          const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded, size: 28), label: ""),
        ],
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("7.7",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              SizedBox(width: 3),
              Icon(Icons.star_rounded,
                  color: Color(0xFFFFBB3B), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}