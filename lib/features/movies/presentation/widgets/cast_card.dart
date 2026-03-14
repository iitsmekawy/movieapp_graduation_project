import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';
import 'package:movieapp_graduation_project_amr/l10n/app_localizations.dart';

class CastCard extends StatelessWidget {
  final Cast cast;

  const CastCard({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF282A28),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: cast.urlSmallImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: cast.urlSmallImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[900]),
                    errorWidget: (context, url, error) => Container(color: Colors.grey, child: const Icon(Icons.person, color: Colors.white54)),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey,
                    child: const Icon(Icons.person, color: Colors.white54),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.name} : ${cast.name}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "Character : ${cast.characterName}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
