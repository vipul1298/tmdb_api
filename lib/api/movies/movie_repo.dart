import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:tmdb/api/movies/movie_contract.dart';
import 'package:tmdb/model/movie_detail.dart';
import 'package:tmdb/model/movies.dart';

import '../../hive/movie_db.dart';
import '../../main.dart';

class MovieRepo implements MovieContract {
  final logger = Logger();
  @override
  Future<MovieDetail> getMovieDetail(int id) async {
    MovieDetail movieDetail = MovieDetail();
    final url = Uri.parse('${dotenv.env['BASE_URL']}/movie/$id?language=en-US');
    final headers = {
      'Authorization': 'Bearer ${dotenv.env['BEARER_TOKEN']}',
      'accept': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = jsonDecode(response.body);
      movieDetail = MovieDetail.fromJson(data);
    } else {
      logger.e('Failed to load data. Status code: ${response.statusCode}');
      logger.e('Response body: ${response.body}');
    }
    return movieDetail;
  }

  @override
  Future<List<Movie>> getMovies({int page = 1}) async {
    List<Movie> movies = [];
    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/movie/popular?language=en-US&page=$page');
    final headers = {
      'Authorization': 'Bearer ${dotenv.env['BEARER_TOKEN']}',
      'accept': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = jsonDecode(response.body);
      movies = Movies.fromJson(data).results ?? [];
    } else {
      logger.e('Failed to load data. Status code: ${response.statusCode}');
      logger.e('Response body: ${response.body}');
    }
    return movies;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    List<Movie> movies = [];
    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/search/movie?query=$query&language=en-US&page=1');
    final headers = {
      'Authorization': 'Bearer ${dotenv.env['BEARER_TOKEN']}',
      'accept': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      movies = Movies.fromJson(data).results ?? [];
    } else {
      logger.e(
          'Failed to load search results. Status code: ${response.statusCode}');
      logger.e('Response body: ${response.body}');
    }
    return movies;
  }

  @override
  Future<void> addToFavorites(Movie movie) async {
    await MovieDB.instance.addToFavorites(movie);
  }

  @override
  Future<void> removeFromFavorites(Movie movie) async {
    await MovieDB.instance.removeFromFavorites(movie.id ?? 0);
  }
}
