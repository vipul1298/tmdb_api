import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:tmdb/controllers/movie_controller.dart';
import 'package:tmdb/hive/movie_db.dart';
import 'package:tmdb/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Hive before running tests
    await Hive.initFlutter();
    await MovieDB.instance.init();
  });

  testWidgets('App should have correct title and switch functionality',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Wait for initial frame to be rendered and async operations to complete
    await tester.pumpAndSettle();

    // Verify the initial state - Movies title should be visible
    expect(find.text("Movies"), findsOneWidget);

    // Verify the switch is present
    expect(find.byKey(Key("switch")), findsOneWidget);

    // Get the context from the widget tree
    final context = tester.element(find.byType(MaterialApp));

    // Get the MovieController from the Provider
    final movieController =
        Provider.of<MovieController>(context, listen: false);

    // Initialize movies with context
    await movieController.getMovies(context: context, loadMore: true);

    // Wait for loading to complete
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify that movies are loaded (check for movie cards)
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Verify that we have movie cards in the grid
    expect(find.byType(Container).first, findsOneWidget);

    // Verify that we have at least one movie loaded
    expect(movieController.movies.length, greaterThan(0));

    // Tap the switch to toggle to favorites
    await tester.tap(find.byKey(Key("switch")));

    // Wait for animations and async operations to complete
    await tester.pumpAndSettle();

    // Verify the title changes to "Favorites"
    expect(find.text("Favorites"), findsOneWidget);

    // Tap the switch again to go back to movies
    await tester.tap(find.byKey(Key("switch")));

    // Wait for animations and async operations to complete
    await tester.pumpAndSettle();

    // Verify the title changes back to "Movies"
    expect(find.text("Movies"), findsOneWidget);

    // Verify movies are loaded again
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Container).first, findsOneWidget);
    expect(movieController.movies.length, greaterThan(0));
  });
}
