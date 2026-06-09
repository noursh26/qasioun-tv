import 'package:flutter/material.dart';
import '../models/live_channel.dart';
import '../models/tv_series.dart';
import '../models/contact_slide.dart';
import '../models/movie.dart';
import 'tabs/live_tv_tab.dart';
import 'tabs/series_tab.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/support_tab.dart';

class HomeScreen extends StatefulWidget {
  final List<LiveChannel> initialChannels;
  final List<TvSeries> initialSeries;
  final List<ContactSlide> initialSlides;
  final List<Movie> initialMovies;

  const HomeScreen({
    Key? key,
    required this.initialChannels,
    required this.initialSeries,
    required this.initialSlides,
    required this.initialMovies,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      LiveTvTab(channels: widget.initialChannels),
      SeriesTab(seriesList: widget.initialSeries, moviesList: widget.initialMovies),
      FavoritesTab(allChannels: widget.initialChannels, allSeries: widget.initialSeries),
      SupportTab(slides: widget.initialSlides),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1329),
      body: Stack(
        children: [
          // Background back image
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF0B1329),
              ),
            ),
          ),
          
          // Fading Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0B1329).withOpacity(0.95),
                    const Color(0xFF0F172A).withOpacity(0.85),
                    const Color(0xFF0B1329).withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/app.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'قاسيون TV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              body: IndexedStack(
                index: _currentIndex,
                children: _tabs,
              ),
              bottomNavigationBar: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    selectedItemColor: Colors.blueAccent.shade400,
                    unselectedItemColor: Colors.white.withOpacity(0.4),
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    selectedFontSize: 11,
                    unselectedFontSize: 11,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    items: [
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(_currentIndex == 0 ? Icons.tv : Icons.tv_outlined),
                        ),
                        label: 'البث المباشر',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(_currentIndex == 1 ? Icons.video_library : Icons.video_library_outlined),
                        ),
                        label: 'أفلام ومسلسلات',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(_currentIndex == 2 ? Icons.favorite : Icons.favorite_border),
                        ),
                        label: 'المفضلة',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(_currentIndex == 3 ? Icons.support_agent : Icons.support_agent_outlined),
                        ),
                        label: 'الدعم',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
