import 'package:hive/hive.dart';
import 'package:tmdb/model/movies.dart';

class MovieDB {
  MovieDB._();
  static final instance = MovieDB._();
  static const String _favoritesBoxName = 'favorites_db';
  static const String _favorites = 'favorites';
  late Box _favoritesBox;

  Future<void> init() async {
    _favoritesBox = await Hive.openBox(_favoritesBoxName);
  }

  Future<void> addToFavorites(Movie movie) async {
    List<dynamic> favorites =
        _favoritesBox.get(_favorites, defaultValue: []) as List<dynamic>;
    if (!favorites.any((m) => m['id'] == movie.id)) {
      favorites.add(movie.toJson());
      await _favoritesBox.put(_favorites, favorites);
    }
  }

  Future<void> removeFromFavorites(int movieId) async {
    List<dynamic> favorites =
        _favoritesBox.get(_favorites, defaultValue: []) as List<dynamic>;
    favorites.removeWhere((m) => m['id'] == movieId);
    await _favoritesBox.put(_favorites, favorites);
  }

  Future<List<Movie>> getFavorites() async {
    List<dynamic> favorites =
        _favoritesBox.get(_favorites, defaultValue: []) as List<dynamic>;
    return favorites.map((m) => Movie.fromJson(m)).toList();
  }
}
