import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/tv_series.dart';
import '../../models/movie.dart';
import '../../services/api_service.dart';
import '../series_detail_screen.dart';
import '../player_screen.dart';

class SeriesTab extends StatefulWidget {
  final List<TvSeries> seriesList;
  final List<Movie> moviesList;

  const SeriesTab({
    Key? key,
    required this.seriesList,
    required this.moviesList,
  }) : super(key: key);

  @override
  State<SeriesTab> createState() => _SeriesTabState();
}

class _SeriesTabState extends State<SeriesTab> {
  int _activeSegment = 0; // 0 = Series, 1 = Movies
  String _searchQuery = '';
  List<TvSeries> _seriesList = [];
  List<Movie> _moviesList = [];
  bool _isRefreshing = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _seriesList = widget.seriesList;
    _moviesList = widget.moviesList;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    try {
      final results = await Future.wait([
        _apiService.fetchTvSeries(),
        _apiService.fetchMovies(),
      ]);
      if (mounted) {
        setState(() {
          _seriesList = results[0] as List<TvSeries>;
          _moviesList = results[1] as List<Movie>;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث البيانات: $e', textDirection: TextDirection.rtl),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  List<TvSeries> _getFilteredSeries() {
    return _seriesList.where((s) {
      return s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Movie> _getFilteredMovies() {
    return _moviesList.where((m) {
      return m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Segmented Control
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeSegment = 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeSegment == 0 
                            ? Colors.blueAccent.shade700 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'مسلسلات',
                        style: TextStyle(
                          color: _activeSegment == 0 ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeSegment = 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeSegment == 1 
                            ? Colors.blueAccent.shade700 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'أفلام',
                        style: TextStyle(
                          color: _activeSegment == 1 ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155), width: 1),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 400), () {
                  if (mounted) {
                    setState(() {
                      _searchQuery = val;
                    });
                  }
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: _activeSegment == 0 ? 'ابحث عن مسلسل...' : 'ابحث عن فيلم...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.6), size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // VOD Grid Listing
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.blueAccent,
            backgroundColor: const Color(0xFF1E293B),
            child: _activeSegment == 0 
                ? _buildSeriesGrid(_getFilteredSeries())
                : _buildMoviesGrid(_getFilteredMovies()),
          ),
        ),
      ],
    );
  }

  Widget _buildSeriesGrid(List<TvSeries> list) {
    if (list.isEmpty) return _buildEmptyState();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final series = list[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SeriesDetailScreen(series: series),
              ),
            );
          },
          child: _buildVODCard(
            title: series.title,
            imageUrl: series.imageAsset,
            subtitle: '${series.year} • ${series.category}',
            badge: '${series.episodes.length} حلقة',
          ),
        );
      },
    );
  }

  Widget _buildMoviesGrid(List<Movie> list) {
    if (list.isEmpty) return _buildEmptyState();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final movie = list[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  videoUrl: movie.videoUrl,
                  title: movie.title,
                ),
              ),
            );
          },
          child: _buildVODCard(
            title: movie.title,
            imageUrl: movie.imageAsset,
            subtitle: movie.category,
            badge: 'فيلم',
          ),
        );
      },
    );
  }

  Widget _buildVODCard({
    required String title,
    required String imageUrl,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Poster Image
          CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF0F172A),
              child: const Icon(Icons.movie, size: 50, color: Colors.white24),
            ),
            fit: BoxFit.cover,
          ),

          // Shadow overlay from bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Content info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Count/Type Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.shade700.withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_rounded, size: 60, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'لا توجد نتائج مطابقة للبحث',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
