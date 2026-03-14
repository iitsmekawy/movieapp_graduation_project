import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';
import 'package:movieapp_graduation_project_amr/core/widgets/rating_badge.dart';
import 'package:movieapp_graduation_project_amr/features/movies/presentation/screens/movie_details_screen.dart';

class MovieThumbnailCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final bool useReplacement;

  const MovieThumbnailCard({
    super.key,
    required this.movie,
    this.width = 150,
    this.useReplacement = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (useReplacement) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movieId: movie.id),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movieId: movie.id),
            ),
          );
        }
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: movie.mediumCoverImage,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[900]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.black),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: RatingBadge(rating: movie.rating),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
