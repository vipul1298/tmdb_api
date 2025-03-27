import 'package:tmdb/model/movie_detail.dart';
import 'package:tmdb/model/movies.dart';

abstract class MovieContract {
  Future<List<Movie>> getMovies();
  Future<MovieDetail> getMovieDetail(int id);
  Future<List<Movie>> searchMovies(String query);
  Future<void> addToFavorites(Movie movie);
  Future<void> removeFromFavorites(Movie movie);
}
