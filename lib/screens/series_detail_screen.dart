import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tv_series.dart';
import '../utils/favorites_manager.dart';
import 'player_screen.dart';

class SeriesDetailScreen extends StatefulWidget {
  final TvSeries series;

  const SeriesDetailScreen({Key? key, required this.series}) : super(key: key);

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  bool _isFavorite = false;
  Map<String, List<Episode>> _seasons = {};
  String _expandedSeason = '';

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _groupEpisodesBySeason();
  }

  Future<void> _checkFavorite() async {
    final isFav = await FavoritesManager.isSeriesFavorite(widget.series.id.toString());
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _groupEpisodesBySeason() {
    final Map<String, List<Episode>> grouped = {};
    
    for (var ep in widget.series.episodes) {
      String seasonName = 'الموسم 1';
      final match = RegExp(r'[Ss](\d+)').firstMatch(ep.title);
      if (match != null) {
        int seasonNum = int.parse(match.group(1)!);
        seasonName = 'الموسم $seasonNum';
      }
      grouped.putIfAbsent(seasonName, () => []).add(ep);
    }
    
    setState(() {
      _seasons = grouped;
      if (_seasons.isNotEmpty) {
        _expandedSeason = _seasons.keys.first;
      }
    });
  }

  Future<void> _toggleFavorite() async {
    final added = await FavoritesManager.toggleSeriesFavorite(widget.series.id.toString());
    setState(() {
      _isFavorite = added;
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة',
          style: const TextStyle(),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1329),
      body: CustomScrollView(
        slivers: [
          // Banner Sliver AppBar
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            leading: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.series.imageAsset,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.black38),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF0F172A),
                      child: const Icon(Icons.movie, size: 80, color: Colors.white24),
                    ),
                  ),
                  // Dark fading overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0B1329),
                            const Color(0xFF0B1329).withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Series details listing
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.series.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Metadata Row
                  Row(
                    children: [
                      // Rating Badge
                      if (widget.series.rating > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                widget.series.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Year
                      if (widget.series.year.isNotEmpty) ...[
                        Text(
                          widget.series.year,
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        const Text('•', style: TextStyle(color: Colors.white30)),
                        const SizedBox(width: 12),
                      ],

                      // Category
                      Expanded(
                        child: Text(
                          widget.series.category,
                          style: TextStyle(color: Colors.blueAccent.shade400, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (widget.series.description.isNotEmpty) ...[
                    const Text(
                      'القصة:',
                      style: TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.series.description,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Seasons header
                  const Text(
                    'الحلقات:',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Season Accordions
                  if (_seasons.isEmpty)
                    const Text(
                      'لا توجد حلقات متاحة حالياً.',
                      style: TextStyle(color: Colors.white30, fontSize: 13),
                    )
                  else
                    ..._seasons.keys.map((seasonKey) {
                      final isExpanded = _expandedSeason == seasonKey;
                      final episodes = _seasons[seasonKey] ?? [];
                      
                      return Card(
                        color: const Color(0xFF1E293B).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isExpanded ? Colors.blueAccent.withOpacity(0.3) : const Color(0xFF334155).withOpacity(0.5),
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                seasonKey,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white54,
                              ),
                              onTap: () {
                                setState(() {
                                  _expandedSeason = isExpanded ? '' : seasonKey;
                                });
                              },
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 2.5,
                                  ),
                                  itemCount: episodes.length,
                                  itemBuilder: (context, epIndex) {
                                    final ep = episodes[epIndex];
                                    
                                    // Parse clean episode title (e.g. S01E05 -> الحلقة 5)
                                    String cleanTitle = ep.title;
                                    final match = RegExp(r'[Ee](\d+)').firstMatch(ep.title);
                                    if (match != null) {
                                      cleanTitle = 'الحلقة ${int.parse(match.group(1)!)}';
                                    }

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlayerScreen(
                                              videoUrl: ep.videoUrl,
                                              title: '${widget.series.title} - $seasonKey - $cleanTitle',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A).withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF334155),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.blueAccent,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                cleanTitle,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
