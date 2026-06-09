import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/live_channel.dart';
import '../../models/tv_series.dart';
import '../../utils/favorites_manager.dart';
import '../series_detail_screen.dart';
import '../player_screen.dart';

class FavoritesTab extends StatefulWidget {
  final List<LiveChannel> allChannels;
  final List<TvSeries> allSeries;

  const FavoritesTab({
    Key? key,
    required this.allChannels,
    required this.allSeries,
  }) : super(key: key);

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  int _activeSegment = 0; // 0 = Channels, 1 = Series
  List<LiveChannel> _favChannels = [];
  List<TvSeries> _favSeries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Reload favorites whenever tab is visible or updated
  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final favChannelIds = await FavoritesManager.getFavoriteChannelIds();
    final favSeriesIds = await FavoritesManager.getFavoriteSeriesIds();

    final Set<String> channelIdSet = favChannelIds.toSet();
    final Set<String> seriesIdSet = favSeriesIds.toSet();

    if (mounted) {
      setState(() {
        _favChannels = widget.allChannels.where((c) => channelIdSet.contains(c.id)).toList();
        _favSeries = widget.allSeries.where((s) => seriesIdSet.contains(s.id.toString())).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeChannelFromFav(LiveChannel channel) async {
    await FavoritesManager.toggleChannelFavorite(channel.id);
    _loadFavorites();
  }

  Future<void> _removeSeriesFromFav(TvSeries series) async {
    await FavoritesManager.toggleSeriesFavorite(series.id.toString());
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Segment Selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                        'قنوات مفضلة',
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
                        'مسلسلات مفضلة',
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

        // Favorites listing
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFavorites,
            child: _activeSegment == 0
                ? _buildChannelsGrid()
                : _buildSeriesGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelsGrid() {
    if (_favChannels.isEmpty) return _buildEmptyState('لا توجد قنوات في المفضلة بعد');
    
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: _favChannels.length,
      itemBuilder: (context, index) {
        final channel = _favChannels[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  videoUrl: channel.streamUrl,
                  title: channel.name,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155).withOpacity(0.6), width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                        padding: const EdgeInsets.all(12),
                        child: CachedNetworkImage(
                          imageUrl: channel.imageUrl,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/app.png',
                            fit: BoxFit.contain,
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      color: const Color(0xFF0F172A).withOpacity(0.5),
                      child: Text(
                        channel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Remove button
                Positioned(
                  top: 4,
                  left: 4,
                  child: InkWell(
                    onTap: () => _removeChannelFromFav(channel),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeriesGrid() {
    if (_favSeries.isEmpty) return _buildEmptyState('لا توجد مسلسلات في المفضلة بعد');

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: _favSeries.length,
      itemBuilder: (context, index) {
        final series = _favSeries[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SeriesDetailScreen(series: series),
              ),
            );
            _loadFavorites(); // Reload when returning from detail page
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155).withOpacity(0.6), width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: series.imageAsset,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF0F172A),
                    child: const Icon(Icons.movie, size: 50, color: Colors.white24),
                  ),
                ),
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
                          series.title,
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
                          '${series.year} • ${series.category}',
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
                // Remove button
                Positioned(
                  top: 12,
                  left: 12,
                  child: InkWell(
                    onTap: () => _removeSeriesFromFav(series),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.22),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline_rounded, size: 60, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
