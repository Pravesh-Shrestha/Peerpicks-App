import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';

/// Reusable video player with full controls, retry, and fullscreen support.
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double? height;
  final bool autoPlay;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.height,
    this.autoPlay = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _showControls = true;
  String? _errorDetail;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final resolvedUrl = ApiEndpoints.resolveServerUrl(widget.videoUrl);
    debugPrint('[VideoPlayer] Loading: $resolvedUrl');

    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(resolvedUrl),
      httpHeaders: const {'Accept': '*/*'},
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _initialized = true;
          _hasError = false;
          _errorDetail = null;
        });
        if (widget.autoPlay) {
          _controller!.play();
          _controller!.setLooping(true);
        }
        _controller!.addListener(_onControllerUpdate);
      }
    } catch (e) {
      debugPrint('[VideoPlayer] Error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorDetail = e.toString();
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _retry() async {
    setState(() {
      _initialized = false;
      _hasError = false;
      _errorDetail = null;
    });
    await _initVideo();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  void _openFullscreen() {
    if (_controller == null || !_initialized) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenVideoPlayer(
          controller: _controller!,
          videoUrl: widget.videoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: widget.height ?? 350,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 40),
              const SizedBox(height: 8),
              const Text(
                'Unable to load video',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              if (_errorDetail != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  child: Text(
                    _errorDetail!,
                    style: const TextStyle(color: Colors.white30, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _retry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFFC5FF41),
                  size: 18,
                ),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Color(0xFFC5FF41)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        height: widget.height ?? 350,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFC5FF41),
              ),
              SizedBox(height: 10),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Container(
        height: widget.height ?? 350,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),

            // Big play/pause button
            if (_showControls)
              GestureDetector(
                onTap: () {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                    _controller!.setLooping(true);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

            // Top controls — fullscreen
            if (_showControls)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _openFullscreen,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

            // Bottom controls — progress, time, volume
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Play/Pause small
                      GestureDetector(
                        onTap: () {
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            _controller!.play();
                            _controller!.setLooping(true);
                          }
                        },
                        child: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Current time
                      Text(
                        _formatDuration(_controller!.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress bar
                      Expanded(
                        child: VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          padding: EdgeInsets.zero,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFFC5FF41),
                            bufferedColor: Colors.white30,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Total time
                      Text(
                        _formatDuration(_controller!.value.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Volume
                      GestureDetector(
                        onTap: () {
                          _controller!.setVolume(
                            _controller!.value.volume > 0 ? 0 : 1,
                          );
                        },
                        child: Icon(
                          _controller!.value.volume > 0
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== FULLSCREEN VIDEO PLAYER ====================

class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoUrl;

  const _FullscreenVideoPlayer({
    required this.controller,
    required this.videoUrl,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  bool _showControls = true;
  late VideoPlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller;
    _ctrl.addListener(_update);
    // Landscape for fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_update);
    // Restore orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _ctrl.value.aspectRatio,
                child: VideoPlayer(_ctrl),
              ),
            ),

            // Controls overlay
            if (_showControls) ...[
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.fullscreen_exit_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Center play/pause
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_ctrl.value.isPlaying) {
                      _ctrl.pause();
                    } else {
                      _ctrl.play();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _ctrl.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        _ctrl,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFC5FF41),
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Play/Pause
                          GestureDetector(
                            onTap: () {
                              if (_ctrl.value.isPlaying) {
                                _ctrl.pause();
                              } else {
                                _ctrl.play();
                              }
                            },
                            child: Icon(
                              _ctrl.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Time
                          Text(
                            '${_formatDuration(_ctrl.value.position)} / ${_formatDuration(_ctrl.value.duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          // Volume
                          GestureDetector(
                            onTap: () {
                              _ctrl.setVolume(_ctrl.value.volume > 0 ? 0 : 1);
                            },
                            child: Icon(
                              _ctrl.value.volume > 0
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== FULLSCREEN IMAGE VIEWER ====================

/// Fullscreen image viewer with pinch-to-zoom
class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiEndpoints.resolveServerUrl(imageUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  resolvedUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: const Color(0xFFC5FF41),
                      ),
                    );
                  },
                  errorBuilder: (_, e, st) => const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
