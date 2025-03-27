import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmdb/model/movies.dart';
import 'package:tmdb/screens/widgets/movie_detail_shimmer.dart';

import '../controllers/movie_controller.dart';
import '../utils/color.dart';

class MovieDetail extends StatefulWidget {
  final Movie movie;
  const MovieDetail({super.key, required this.movie});

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  String baseUrl = 'https://image.tmdb.org/t/p/w500';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieController>(context, listen: false)
          .getMovieDetail(widget.movie.id ?? 0, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: AppColors.appBarColor,
        title:
            const Text("Movie Detail", style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<MovieController>(
        builder: (context, model, _) {
          return model.isLoading
              ? const MovieDetailShimmer()
              : SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildBackdropImage(model),
                          _buildMovieInfo(model),
                          _buildRatingAndDate(model),
                          _buildProductionInfo(model),
                        ],
                      ),
                      _buildFavoriteButton(model),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildBackdropImage(MovieController model) {
    return CachedNetworkImage(
      width: double.infinity,
      imageUrl: '$baseUrl${model.movieDetail?.backdropPath}',
      placeholder: (context, _) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(),
      ),
      errorWidget: (_, __, ___) => const SizedBox(),
      fit: BoxFit.cover,
      httpHeaders: const {'accept': 'image/*'},
    );
  }

  Widget _buildMovieInfo(MovieController model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPosterImage(model),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.movieDetail?.overview ?? "No overview available.",
                  style: const TextStyle(fontSize: 16),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _buildGenresList(model),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterImage(MovieController model) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        width: 120,
        height: 180,
        imageUrl: '$baseUrl${model.movieDetail?.posterPath}',
        placeholder: (context, _) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(),
        ),
        errorWidget: (_, __, ___) => const SizedBox(),
        fit: BoxFit.cover,
        httpHeaders: const {'accept': 'image/*'},
      ),
    );
  }

  Widget _buildGenresList(MovieController model) {
    return Wrap(
      spacing: 8,
      children: model.movieDetail?.genres?.map((genre) {
            return Chip(
              label: Text(genre.name ?? ""),
              backgroundColor: Colors.yellowAccent.shade400,
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildRatingAndDate(MovieController model) {
    final style = TextStyle(fontSize: 16);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                '${model.movieDetail?.voteAverage ?? 0.0} (${model.movieDetail?.voteCount ?? 0} votes)',
                style: style,
              ),
            ],
          ),
          Text(
            model.movieDetail?.releaseDate != null
                ? DateFormat('MMMM dd, yyyy').format(
                    DateTime.parse(model.movieDetail?.releaseDate ?? ""))
                : "Date:Unknown",
            style: style,
          ),
        ],
      ),
    );
  }

  Widget _buildProductionInfo(MovieController model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.movieDetail?.productionCompanies?.isNotEmpty ?? false) ...[
            const Text(
              "Production Companies:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: model.movieDetail?.productionCompanies?.map((company) {
                    return Chip(
                      label: Text(company.name ?? "Unknown"),
                      backgroundColor: Colors.greenAccent,
                    );
                  }).toList() ??
                  [],
            ),
          ],
          if (model.movieDetail?.productionCountries?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            const Text(
              "Production Countries:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: model.movieDetail?.productionCountries?.map((country) {
                    return Chip(
                      label: Text(country.name ?? "Unknown"),
                      backgroundColor:
                          Colors.orangeAccent.withValues(alpha: 0.5),
                    );
                  }).toList() ??
                  [],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(MovieController model) {
    return Positioned(
      child: GestureDetector(
        onTap: () {
          if (model.isFavorite(widget.movie.id ?? 0)) {
            model.removeFromFavorites(widget.movie);
          } else {
            model.addToFavorites(widget.movie);
          }
        },
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              model.isFavorite(widget.movie.id ?? 0)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: model.isFavorite(widget.movie.id ?? 0)
                  ? Colors.red
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
