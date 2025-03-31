class Movie {
  final int id;
  final String title;
  final double voteAverage;
  final int voteCount;
  final String status;
  final int revenue;
  final String backdropPath;
  final int budget;
  final String homepage;
  final String imdbId;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final String releaseDate;
  final String tagline;
  final String genres;
  final String productionCompanies;
  final String productionCountries;
  final String spokenLanguages;
  final String keywords;
  final int runtime;
  final bool adult;

  Movie({
    required this.id,
    required this.title,
    required this.voteAverage,
    required this.voteCount,
    required this.status,
    required this.revenue,
    required this.backdropPath,
    required this.budget,
    required this.homepage,
    required this.imdbId,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.tagline,
    required this.genres,
    required this.productionCompanies,
    required this.productionCountries,
    required this.spokenLanguages,
    required this.keywords,
    required this.runtime,
    required this.adult,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      voteAverage: double.tryParse(json['vote_average']?.toString() ?? '0.0') ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      status: json['status'] ?? '',
      revenue: int.tryParse(json['revenue']?.toString() ?? '0') ?? 0,
      backdropPath: json['backdrop_path'] ?? '',
      budget: int.tryParse(json['budget']?.toString() ?? '0') ?? 0,
      homepage: json['homepage'] ?? '',
      imdbId: json['imdb_id'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      popularity: double.tryParse(json['popularity']?.toString() ?? '0.0') ?? 0.0,
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      tagline: json['tagline'] ?? '',
      genres: json['genres'] ?? '',
      productionCompanies: json['production_companies'] ?? '',
      productionCountries: json['production_countries'] ?? '',
      spokenLanguages: json['spoken_languages'] ?? '',
      keywords: json['keywords'] ?? '',
      runtime: json['runtime'] ?? 0,
      adult: json['adult'] ?? false,
    );
  }

  // Helper method to get genres as a list
  List<String> get genresList {
    if (genres.isEmpty) return [];
    return genres.split(',').map((e) => e.trim()).toList();
  }

  // Helper method to get production companies as a list
  List<String> get productionCompaniesList {
    if (productionCompanies.isEmpty) return [];
    return productionCompanies.split(',').map((e) => e.trim()).toList();
  }

  // Helper method to get production countries as a list
  List<String> get productionCountriesList {
    if (productionCountries.isEmpty) return [];
    return productionCountries.split(',').map((e) => e.trim()).toList();
  }

  // Helper method to get spoken languages as a list
  List<String> get spokenLanguagesList {
    if (spokenLanguages.isEmpty) return [];
    return spokenLanguages.split(',').map((e) => e.trim()).toList();
  }

  // Helper method to get keywords as a list
  List<String> get keywordsList {
    if (keywords.isEmpty) return [];
    return keywords.split(',').map((e) => e.trim()).toList();
  }
} 