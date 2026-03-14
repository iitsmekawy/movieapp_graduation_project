class Movie {
  final int id;
  final String title;
  final String titleEnglish;
  final int year;
  final double rating;
  final List<String> genres;
  final String summary;
  final String backgroundImage;
  final String mediumCoverImage;
  final String largeCoverImage;

  final int runtime;
  final String descriptionFull;
  final int likeCount;
  final List<Cast>? cast;
  final List<String>? screenshots;

  Movie({
    required this.id,
    required this.title,
    required this.titleEnglish,
    required this.year,
    required this.rating,
    required this.genres,
    required this.summary,
    required this.backgroundImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    this.runtime = 0,
    this.descriptionFull = '',
    this.likeCount = 0,
    this.cast,
    this.screenshots,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> screenshots = [];
    if (json['medium_screenshot_image1'] != null)
      screenshots.add(json['medium_screenshot_image1']);
    if (json['medium_screenshot_image2'] != null)
      screenshots.add(json['medium_screenshot_image2']);
    if (json['medium_screenshot_image3'] != null)
      screenshots.add(json['medium_screenshot_image3']);

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      titleEnglish: json['title_english'] ?? '',
      year: json['year'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      genres: List<String>.from(json['genres'] ?? []),
      summary: json['summary'] ?? json['description_full'] ?? '',
      backgroundImage: json['background_image'] ?? '',
      mediumCoverImage: json['medium_cover_image'] ?? '',
      largeCoverImage: json['large_cover_image'] ?? '',
      runtime: json['runtime'] ?? 0,
      descriptionFull: json['description_full'] ?? '',
      likeCount: json['like_count'] ?? 0,
      cast: json['cast'] != null
          ? (json['cast'] as List).map((c) => Cast.fromJson(c)).toList()
          : null,
      screenshots: screenshots.isNotEmpty ? screenshots : null,
    );
  }
}

class Cast {
  final String name;
  final String characterName;
  final String urlSmallImage;

  Cast({
    required this.name,
    required this.characterName,
    required this.urlSmallImage,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      name: json['name'] ?? '',
      characterName: json['character_name'] ?? '',
      urlSmallImage: json['url_small_image'] ?? '',
    );
  }
}
