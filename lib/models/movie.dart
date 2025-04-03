class Movie {
  final int id;
  final String title;
  final String genre;
  final String? releaseDate;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String? backdropPath;
  final String? posterPath;
  final bool adult;
  final String overview;
  final int year;
  final String type;
  final String cast;
  final String character;
  final String director;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    this.releaseDate,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    this.backdropPath,
    this.posterPath,
    required this.adult,
    required this.overview,
    required this.year,
    required this.type,
    required this.cast,
    required this.character,
    required this.director,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      releaseDate: json['release_date'],
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      backdropPath: json['backdrop_path'],
      posterPath: json['poster_path'],
      adult: json['adult'] ?? false,
      overview: json['overview'] ?? '',
      year: json['year'] ?? 0,
      type: json['type'] ?? '',
      cast: json['cast'] ?? '',
      character: json['character'] ?? '',
      director: json['director'] ?? '',
    );
  }

  // Helper method to get genres as a list
  List<String> get genresList {
    if (genre.isEmpty) return [];
    return genre.split(',').map((e) => e.trim()).toList();
  }

  // Helper method to get cast as a list
  List<String> get castList {
    if (cast.isEmpty) return [];
    return cast.split(',').map((e) => e.trim()).toList();
  }

  // Helper method to get characters as a list
  List<String> get characterList {
    if (character.isEmpty) return [];
    return character.split(',').map((e) => e.trim()).toList();
  }
} 