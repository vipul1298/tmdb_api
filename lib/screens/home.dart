import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb/controllers/movie_controller.dart';
import 'package:tmdb/screens/movie_detail.dart';
import 'package:tmdb/screens/widgets/movie_card.dart';
import 'package:tmdb/utils/color.dart';

import '../utils/internet_connectivity.dart';
import '../utils/keys.dart';
import '../utils/snackbar.dart';
import 'widgets/movie_shimmer_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  static const double _scrollThreshold = 200.0;
  late MovieController movieController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      movieController = Provider.of<MovieController>(context, listen: false);
      movieController.getMovies();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _scrollThreshold) {
      if (!movieController.isLoading &&
          movieController.hasMorePages &&
          !movieController.isFavorites) {
        movieController.getMovies(loadMore: true, context: context);
      }
    }
  }

  void _handleSearch(String value) {
    movieController.searchMovies(value, context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieController>(
      builder: (context, model, child) {
        return Scaffold(
          key: Keys.instance.appPage,
          appBar: _buildAppBar(model),
          body: Column(
            children: [
              if (!model.isFavorites) _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await movieController.getMovies();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildMovieGrid(model),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(MovieController model) {
    return AppBar(
      title: const Text(
        "Movies",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        Switch(
          key: const Key("switch"),
          value: model.isFavorites,
          onChanged: (value) {
            model.toggleMovieList();
            if (model.isFavorites) {
              _searchController.clear();
            }
          },
        ),
      ],
      backgroundColor: AppColors.appBarColor,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.appBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<MovieController>(context, listen: false)
                        .searchMovies('', context);
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: _handleSearch,
      ),
    );
  }

  Widget _buildMovieGrid(MovieController model) {
    if (model.isLoading) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 8,
        itemBuilder: (ctx, index) => const MovieCardShimmer(),
      );
    }

    if (!model.isLoading && model.movies.isEmpty) {
      return const Center(
        child: Text("No movies found"),
      );
    }

    return GridView.builder(
      key: PageStorageKey('movie_grid'),
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: model.movies.length +
          (model.hasMorePages && !model.isFavorites && model.isConnected
              ? 1
              : 0),
      itemBuilder: (ctx, index) {
        if (index == model.movies.length &&
            !model.isFavorites &&
            model.isConnected) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return MovieCard(
          model: model,
          index: index,
          onTap: () => _handleMovieTap(model, index),
        );
      },
    );
  }

  Future<void> _handleMovieTap(MovieController model, int index) async {
    bool checkInternet = await InternetConnectivity.checkInternetConnection();
    if (!checkInternet) {
      showSnackBar('No internet connection', context);
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetail(movie: model.movies.elementAt(index)),
      ),
    );
  }
}
