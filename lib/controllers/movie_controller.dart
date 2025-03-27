import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tmdb/api/movies/movie_repo.dart';
import 'package:tmdb/hive/movie_db.dart';
import 'package:tmdb/model/movie_detail.dart';
import 'package:tmdb/model/movies.dart';
import 'package:tmdb/utils/snackbar.dart';

import '../utils/internet_connectivity.dart';

class MovieController extends ChangeNotifier {
  MovieController({required this.movieRepo});

  MovieRepo movieRepo;
  List<Movie> _movies = [];
  List<Movie> _favorites = [];
  MovieDetail? _movieDetail;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isFavorites = false;
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isConnected = true;

  List<Movie> get movies => _movies;
  List<Movie> get favorites => _favorites;
  MovieDetail? get movieDetail => _movieDetail;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;
  bool get isFavorites => _isFavorites;
  String get searchQuery => _searchQuery;
  bool get isConnected => _isConnected;

  void searchMovies(String query, BuildContext context) {
    _searchQuery = query;
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        await getMovies();
        return;
      }

      if (!await InternetConnectivity.checkInternetConnection()) {
        showSnackBar('No internet connection', context);
        _isLoading = false;
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      try {
        _movies = await movieRepo.searchMovies(query);
      } catch (e) {
        showSnackBar('Error searching movies: $e', context);
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> toggleMovieList() async {
    _isFavorites = !_isFavorites;
    notifyListeners();
    if (_isFavorites) {
      _movies = await MovieDB.instance.getFavorites();
    } else {
      await getMovies();
    }
    notifyListeners();
  }

  bool isFavorite(int id) {
    bool isFav = _favorites.any((element) => element.id == id);

    return isFav;
  }

  Future<bool> isInternetConnected() async {
    return await InternetConnectivity.checkInternetConnection();
  }

  Future<void> getMovies({bool loadMore = false, BuildContext? context}) async {
    _favorites = await MovieDB.instance.getFavorites();
    _isConnected = await isInternetConnected();
    if (!_isConnected) {
      _movies = _favorites;
      _isLoading = false;
      notifyListeners();
      showSnackBar('No internet connection', context!);
      return;
    }
    if (!loadMore) {
      _currentPage = 1;
      _movies = [];
      _hasMorePages = true;
    }

    if (!_hasMorePages || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newMovies = await movieRepo.getMovies(page: _currentPage);
      if (newMovies.isEmpty) {
        _hasMorePages = false;
      } else {
        _movies.addAll(newMovies);
        _currentPage++;
      }
    } catch (e) {
      showSnackBar('Error fetching movies: $e', context!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMovieDetail(int id, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      _movieDetail = await movieRepo.getMovieDetail(id);
    } catch (e) {
      showSnackBar('Error fetching movie detail: $e', context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToFavorites(Movie movie) async {
    await movieRepo.addToFavorites(movie);
    _favorites.add(movie);
    notifyListeners();
  }

  Future<void> removeFromFavorites(Movie movie) async {
    await movieRepo.removeFromFavorites(movie);
    _favorites.removeWhere((element) => element.id == movie.id);
    if (isFavorites) {
      _movies.removeWhere((element) => element.id == movie.id);
    }
    notifyListeners();
  }
}
