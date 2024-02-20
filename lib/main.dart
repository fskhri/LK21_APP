import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class _MyAppState extends State<MyHomePage> {
  late List<MovieDetails> movies;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse('https://lk21-api.cyclic.app/movies'));
    final List<dynamic> responseData = json.decode(response.body);
    setState(() {
      movies = responseData.map((data) => MovieDetails.fromJson(data)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return MovieListScreen(movies: movies);
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class MovieDetails {
  final String id;
  final String title;
  final String type;
  final String posterImg;
  final String rating;
  final String url;
  final String qualityResolution;
  final List<String> genres;

  MovieDetails({
    required this.id,
    required this.title,
    required this.type,
    required this.posterImg,
    required this.rating,
    required this.url,
    required this.qualityResolution,
    required this.genres,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['_id'],
      title: json['title'],
      type: json['type'],
      posterImg: json['posterImg'],
      rating: json['rating'],
      url: json['url'],
      qualityResolution: json['qualityResolution'],
      genres: List<String>.from(json['genres']),
    );
  }
}

class VideoStream {
  final String provider;
  final String url;
  final List<String> resolutions;

  VideoStream({
    required this.provider,
    required this.url,
    required this.resolutions,
  });

  factory VideoStream.fromJson(Map<String, dynamic> json) {
    return VideoStream(
      provider: json['provider'],
      url: json['url'],
      resolutions: List<String>.from(json['resolutions']),
    );
  }
}

class MovieListScreen extends StatelessWidget {
  final List<MovieDetails> movies;

  const MovieListScreen({Key? key, required this.movies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie List'),
      ),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(movieDetails: movies[index]),
                ),
              );
            },
            child: Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(movies[index].posterImg),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movies[index].title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text('Rating: ${movies[index].rating}'),
                        Text('Genres: ${movies[index].genres.join(', ')}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MovieDetailsScreen extends StatelessWidget {
  final MovieDetails movieDetails;

  const MovieDetailsScreen({Key? key, required this.movieDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieDetails.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                movieDetails.posterImg,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text(
                'Rating: ${movieDetails.rating}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Quality Resolution: ${movieDetails.qualityResolution}'),
              Text('Genres: ${movieDetails.genres.join(', ')}'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Implement launching the trailer URL or any other action
                },
                child: Text('Watch Trailer'),
              ),
              SizedBox(height: 20),
              Text(
                'Video Streams:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FutureBuilder(
                // Fetch video streams for the selected movie
                future: fetchVideoStreams(movieDetails.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error fetching video streams');
                  } else {
                    // Display video streams
                    List<VideoStream> videoStreams = snapshot.data as List<VideoStream>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: videoStreams
                          .map((stream) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text('Provider: ${stream.provider}'),
                                  Text('Resolutions: ${stream.resolutions.join(', ')}'),
                                  ElevatedButton(
                                    onPressed: () {
                                      launchVideoStream(stream.url);
                                    },
                                    child: Text('Watch on ${stream.provider}'),
                                  ),
                                ],
                              ))
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Use the url_launcher package to open the video stream URL
  void launchVideoStream(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching video stream: $e');
      // Handle the error as needed (show a snackbar, etc.)
    }
  }

  Future<List<VideoStream>> fetchVideoStreams(String movieId) async {
    final response = await http.get(Uri.parse('https://lk21-api.cyclic.app/movies/$movieId/streams'));
    final List<dynamic> responseData = json.decode(response.body);
    return responseData.map((data) => VideoStream.fromJson(data)).toList();
  }
}