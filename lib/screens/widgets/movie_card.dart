import 'package:flutter/material.dart';

import '../../controllers/movie_controller.dart';

class MovieCard extends StatelessWidget {
  final MovieController model;
  final int index;
  final Function onTap;
  const MovieCard({
    super.key,
    required this.index,
    required this.model,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                'https://image.tmdb.org/t/p/w500${model.movies[index].posterPath}',
              ),
              fit: BoxFit.cover),
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (model.isFavorite(model.movies[index].id ?? 0)) {
                    model.removeFromFavorites(model.movies[index]);
                  } else {
                    model.addToFavorites(model.movies[index]);
                  }
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 05, horizontal: 08),
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      model.isFavorite(model.movies[index].id ?? 0)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: model.isFavorite(model.movies[index].id ?? 0)
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Center(
                  child: Text(
                    model.movies[index].title ?? "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
