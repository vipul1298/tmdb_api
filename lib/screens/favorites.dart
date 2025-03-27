import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb/screens/movie_detail.dart';
import 'package:tmdb/utils/color.dart';

import '../controllers/movie_controller.dart';
import 'widgets/movie_card.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          "Favorites",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Consumer<MovieController>(
        builder: (ctx, model, index) {
          return model.favorites.isEmpty
              ? Center(
                  child: Text('No favorites found'),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: model.favorites.length,
                    itemBuilder: (ctx, index) {
                      return MovieCard(
                          model: model,
                          index: index,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MovieDetail(
                                      movie:
                                          model.favorites.elementAt(index)))));
                    },
                  ),
                );
        },
      ),
    );
  }
}
