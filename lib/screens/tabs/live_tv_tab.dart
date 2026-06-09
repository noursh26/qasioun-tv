import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/live_channel.dart';
import '../../services/api_service.dart';
import '../../utils/favorites_manager.dart';
import '../player_screen.dart';

class LiveTvTab extends StatefulWidget {
  final List<LiveChannel> channels;

  const LiveTvTab({Key? key, required this.channels}) : super(key: key);

  @override
  State<LiveTvTab> createState() => _LiveTvTabState();
}

class _LiveTvTabState extends State<LiveTvTab> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  List<String> _categories = ['الكل'];
  List<String> _favChannelIds = [];
  List<LiveChannel> _channels = [];
  bool _isRefreshing = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _channels = widget.channels;
    _extractCategories();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshChannels() async {
    setState(() => _isRefreshing = true);
    try {
      final freshChannels = await _apiService.fetchLiveChannels();
      if (mounted) {
        setState(() {
          _channels = freshChannels;
          _categories = ['الكل'];
        });
        _extractCategories();
        _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث القنوات: $e', textDirection: TextDirection.rtl),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _extractCategories() {
    final Set<String> cats = {};
    for (var ch in _channels) {
      if (ch.category.isNotEmpty) {
        cats.add(ch.category);
      }
    }
    // Sort categories or put Sports at first
    final sortedCats = cats.toList()..sort();
    
    // Put "رياضة (جميع الجودات)" or similar sports category first if it exists
    final sportsIndex = sortedCats.indexWhere((cat) => cat.contains('رياضة'));
    if (sportsIndex != -1) {
      final sportsCat = sortedCats.removeAt(sportsIndex);
      _categories.addAll([sportsCat, ...sortedCats]);
    } else {
      _categories.addAll(sortedCats);
    }
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesManager.getFavoriteChannelIds();
    if (mounted) {
      setState(() {
        _favChannelIds = favs;
      });
    }
  }

  Future<void> _toggleFavorite(LiveChannel channel) async {
    await FavoritesManager.toggleChannelFavorite(channel.id);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favChannelIds.contains(channel.id) 
              ? 'تمت الإزالة من المفضلة' 
              : 'تمت الإضافة إلى المفضلة',
          style: const TextStyle(),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }

  List<LiveChannel> _getFilteredChannels() {
    return _channels.where((ch) {
      final matchesCategory = _selectedCategory == 'الكل' || ch.category == _selectedCategory;
      final matchesSearch = ch.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ch.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredChannels = _getFilteredChannels();

    return Column(
      children: [
        // Search Bar Container
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                hintText: 'ابحث عن قناة...',
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

        // Categories List
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                  backgroundColor: const Color(0xFF1E293B).withOpacity(0.5),
                  selectedColor: Colors.blueAccent.shade700,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.blueAccent.shade400 : const Color(0xFF334155),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Channels Grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshChannels,
            color: Colors.blueAccent,
            backgroundColor: const Color(0xFF1E293B),
            child: filteredChannels.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: filteredChannels.length,
                    itemBuilder: (context, index) {
                      final channel = filteredChannels[index];
                      final isFav = _favChannelIds.contains(channel.id);
                      return _buildChannelCard(channel, isFav);
                    },
                  ),
          ),
        ),
      ],
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
              Icon(Icons.tv_off_rounded, size: 60, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'لا توجد قنوات مطابقة للبحث',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChannelCard(LiveChannel channel, bool isFav) {
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Logo + Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Image
                Expanded(
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    padding: const EdgeInsets.all(12),
                    child: CachedNetworkImage(
                      imageUrl: channel.imageUrl,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent.shade400),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/app.png',
                        fit: BoxFit.contain,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                // Name
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

            // Quality Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade700.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  channel.quality,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Heart / Favorite Icon
            Positioned(
              top: 4,
              left: 4,
              child: InkWell(
                onTap: () => _toggleFavorite(channel),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : Colors.white.withOpacity(0.6),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
