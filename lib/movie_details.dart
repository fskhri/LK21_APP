import 'package:flutter/material.dart';

class MovieDetails {
  final String id;
  final String title;
  final String type;
  final String posterImg;
  final String quality;
  final String rating;
  final String releaseDate;
  final String duration;
  final String synopsis;
  final String trailerUrl;
  final List<String> genres;
  final List<String> directors;
  final List<String> countries;
  final List<String> casts;

  MovieDetails({
    required this.id,
    required this.title,
    required this.type,
    required this.posterImg,
    required this.quality,
    required this.rating,
    required this.releaseDate,
    required this.duration,
    required this.synopsis,
    required this.trailerUrl,
    required this.genres,
    required this.directors,
    required this.countries,
    required this.casts,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['_id'],
      title: json['title'],
      type: json['type'],
      posterImg: json['posterImg'],
      quality: json['quality'],
      rating: json['rating'],
      releaseDate: json['releaseDate'],
      duration: json['duration'],
      synopsis: json['synopsis'],
      trailerUrl: json['trailerUrl'],
      genres: List<String>.from(json['genres']),
      directors: List<String>.from(json['directors']),
      countries: List<String>.from(json['countries']),
      casts: List<String>.from(json['casts']),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(movieDetails.posterImg),
            SizedBox(height: 16),
            Text('Quality: ${movieDetails.quality}'),
            Text('Rating: ${movieDetails.rating}'),
            Text('Release Date: ${movieDetails.releaseDate}'),
            Text('Duration: ${movieDetails.duration}'),
            Text('Synopsis: ${movieDetails.synopsis}'),
            Text('Trailer URL: ${movieDetails.trailerUrl}'),
            Text('Genres: ${movieDetails.genres.join(', ')}'),
            Text('Directors: ${movieDetails.directors.join(', ')}'),
            Text('Countries: ${movieDetails.countries.join(', ')}'),
            Text('Casts: ${movieDetails.casts.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
