import 'package:dio/dio.dart';
import 'package:movieapp_graduation_project_amr/features/movies/data/models/movie_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://movies-api.accel.li/api/v2/list_movies.json';

  Future<List<Movie>> fetchMovies() async {
    try {
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        final List moviesJson = response.data['data']['movies'];
        return moviesJson.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<List<Movie>> fetchMoviesByCategory(String genre) async {
    try {
      final response =
          await _dio.get(_baseUrl, queryParameters: {'genre': genre});
      if (response.statusCode == 200) {
        final List moviesJson = response.data['data']['movies'];
        return moviesJson.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<Movie> fetchMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        'https://movies-api.accel.li/api/v2/movie_details.json',
        queryParameters: {
          'movie_id': movieId,
          'with_cast': true,
          'with_images': true,
        },
      );
      if (response.statusCode == 200) {
        final movieJson = response.data['data']['movie'];
        return Movie.fromJson(movieJson);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }

  Future<List<Movie>> fetchSimilarMovies(int movieId) async {
    try {
      final response = await _dio.get(
        'https://movies-api.accel.li/api/v2/movie_suggestions.json',
        queryParameters: {'movie_id': movieId},
      );
      if (response.statusCode == 200) {
        final List? moviesJson = response.data['data']['movies'];
        if (moviesJson == null) return [];
        return moviesJson.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load similar movies');
      }
    } catch (e) {
      throw Exception('Error fetching similar movies: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'query_term': query},
      );
      if (response.statusCode == 200) {
        final List? moviesJson = response.data['data']['movies'];
        if (moviesJson == null) return [];
        return moviesJson.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }
}
