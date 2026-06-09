import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const PlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    // Enable wakelock to prevent screen sleeping
    WakelockPlus.enable();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Dispose previous controllers safely
    await _disposeControllers();

    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowedScreenSleep: false,
        showControls: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 50),
                  const SizedBox(height: 12),
                  const Text(
                    'حدث خطأ أثناء تحميل البث',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _initializePlayer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Listen to fullscreen changes
      _chewieController!.addListener(_onChewieStateChanged);

      setState(() {});
    } catch (e) {
      print('Video player initialization error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _onChewieStateChanged() {
    final isFull = _chewieController?.isFullScreen ?? false;
    if (_isFullscreen != isFull) {
      setState(() {
        _isFullscreen = isFull;
      });
    }
  }

  Future<void> _disposeControllers() async {
    _chewieController?.removeListener(_onChewieStateChanged);
    _chewieController?.dispose();
    _chewieController = null;
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      await _videoPlayerController!.dispose();
    }
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _disposeControllers();
    // Reset orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvoked: (didPop) {
        if (!didPop && _isFullscreen) {
          _chewieController?.toggleFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullscreen
            ? null
            : AppBar(
                title: Text(
                  widget.title,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
        body: Center(
          child: _hasError
              ? _buildErrorWidget()
              : _chewieController != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : _buildLoadingWidget(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.blueAccent),
        const SizedBox(height: 16),
        Text(
          'جاري الاتصال بمصدر البث...',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          const Text(
            'لا يمكن تشغيل هذا البث حالياً',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage.contains('SocketException')
                ? 'يرجى التحقق من اتصال الإنترنت الخاص بك.'
                : 'رابط البث غير صالح أو متوقف من المصدر.',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializePlayer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
