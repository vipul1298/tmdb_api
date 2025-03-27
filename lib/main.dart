import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tmdb/api/movies/movie_repo.dart';
import 'package:tmdb/controllers/movie_controller.dart';
import 'package:tmdb/hive/movie_db.dart';
import 'package:tmdb/screens/home.dart';

DotEnv dotenv = DotEnv();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await MovieDB.instance.init();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => MovieController(movieRepo: MovieRepo())),
      ],
      child: MaterialApp(
        title: 'Stage-OTT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Home(),
      ),
    );
  }
}
