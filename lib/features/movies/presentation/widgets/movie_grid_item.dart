import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';
import 'package:movieapp_graduation_project_amr/core/widgets/rating_badge.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/screens/movie_details_screen.dart';

class MovieGridItem extends StatelessWidget {
  final Movie movie;

  const MovieGridItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movieId: movie.id),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: movie.largeCoverImage,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.grey[900]),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: RatingBadge(rating: movie.rating),
            ),
          ],
        ),
      ),
    );
  }
}
