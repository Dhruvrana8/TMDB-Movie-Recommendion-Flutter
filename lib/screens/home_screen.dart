import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../screens/movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _error = '';
  int _currentPage = 1;
  bool _hasMorePages = true;
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentSearch = value;
        _currentPage = 1;
        _hasMorePages = true;
        _movies.clear();
      });
      _fetchMovies();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMorePages) {
        _fetchMoreMovies();
      }
    }
  }

  Future<void> _fetchMoreMovies() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final url =
          _currentSearch.isEmpty
              ? 'http://0.0.0.0:8000/api/v1/movies/?page=$_currentPage'
              : 'http://0.0.0.0:8000/api/v1/movies/?page=$_currentPage&search=$_currentSearch';

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Connection timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        final nextPage = data['next'];

        setState(() {
          _movies.addAll(results.map((json) => Movie.fromJson(json)).toList());
          _hasMorePages = nextPage != null;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load more movies';
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading more movies: $e';
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchMovies() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
        _currentPage = 1;
        _hasMorePages = true;
        _movies.clear();
      });

      final url =
          _currentSearch.isEmpty
              ? 'http://0.0.0.0:8000/api/v1/movies/'
              : 'http://0.0.0.0:8000/api/v1/movies/?search=$_currentSearch';

      print('Attempting to connect to: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'Connection timed out. Please check if the API server is running.',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        final nextPage = data['next'];

        setState(() {
          _movies = results.map((json) => Movie.fromJson(json)).toList();
          _hasMorePages = nextPage != null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load movies. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _error =
            'Connection refused. Please check if the API server is running.\nError: $e';
        _isLoading = false;
      });
    } on TimeoutException catch (e) {
      setState(() {
        _error =
            'Connection timed out. Please check if the API server is running.\nError: $e';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Movie Recommendation System",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMovies,
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                        : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchMovies,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                    : _movies.isEmpty
                    ? Center(
                      child: Text(
                        _currentSearch.isEmpty
                            ? 'No movies found'
                            : 'No movies found for "$_currentSearch"',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                    : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _movies.length + (_hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _movies.length) {
                          return Container(
                            height: 100,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          );
                        }

                        final movie = _movies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        MovieDetailsScreen(movie: movie),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    child: Hero(
                                      tag: 'movie_poster_${movie.id}',
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Center(
                                            child: Icon(Icons.error),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            movie.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rating: ${movie.voteAverage}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Year: ${movie.year}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Release: ${movie.releaseDate ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Adult: ${movie.adult ? "Yes" : "No"}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Popularity: ${movie.popularity}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
