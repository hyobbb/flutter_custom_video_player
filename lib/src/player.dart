import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'data.dart';
import 'player_controller.dart';
import 'indicator.dart';

class Player extends StatefulWidget {
  final List<VideoSource> videos;
  final int index;
  final PlayerController controller;
  final VoidCallback? onDone;
  final bool showProgressBar;
  final Color progressBarActiveColor;
  final Color progressBarInactiveColor;

  const Player({
    required this.videos,
    required this.index,
    required this.controller,
    required this.showProgressBar,
    required this.progressBarActiveColor,
    required this.progressBarInactiveColor,
    this.onDone,
    Key? key,
  }) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  VideoPlayerController? videoPlayerController;
  AnimationController? animationController;
  StreamSubscription? playSubscription;
  StreamSubscription? volumeSubscription;

  double _expectedHeight = 0.0;
  double _volume = 1.0;

  _initialize() async {
    videoPlayerController = await _setController();
    animationController = AnimationController(
        vsync: this, duration: videoPlayerController?.value.duration);
    videoPlayerController?.addListener(_videoStatusListener);
    playSubscription = widget.controller.playSignal.listen((shouldPlay) {
      if (shouldPlay) {
        print('#############play####################');
        print(videoPlayerController.hashCode);
        print('#################################');
        videoPlayerController?.play();
        animationController?.forward();
      } else {
        print('#############stop####################');
        print(videoPlayerController.hashCode);
        print('#################################');
        videoPlayerController?.pause();
        animationController?.stop();
      }
    });
    volumeSubscription = widget.controller.volume.listen((volume) {
      videoPlayerController?.setVolume(volume);
      _volume = volume;
    });

    if (this.mounted) {
      animationController?.forward();
      videoPlayerController?.play();
    }
  }

  _videoStatusListener() {
    if (!videoPlayerController!.value.isPlaying &&
        animationController!.isAnimating) {
      animationController?.stop();
    }

    if (videoPlayerController!.value.isPlaying &&
        !animationController!.isAnimating) {
      animationController?.forward();
    }

    if (videoPlayerController!.value.isBuffering) {
      animationController?.stop();
    }

    if (videoPlayerController!.value.position ==
        videoPlayerController!.value.duration) {
      if (widget.onDone != null) {
        widget.onDone!();
      }
    }
  }

  Future<VideoPlayerController> _setController() async {
    final source = widget.videos[widget.index];
    if (source.type == SourceType.file) {
      final controller = VideoPlayerController.file(File(source.url))
        ..setVolume(_volume);
      await controller.initialize();
      return controller;
    } else {
      final info = await DefaultCacheManager().getFileFromCache(source.url);
      if (info == null) {
        final controller = VideoPlayerController.network(source.url)
          ..setVolume(_volume);
        await controller.initialize();
        return controller;
      } else {
        final controller = VideoPlayerController.file(info.file)
          ..setVolume(_volume);
        await controller.initialize();
        return controller;
      }
    }
  }

  @override
  void didUpdateWidget(covariant Player oldWidget) {
    animationController?.dispose();
    videoPlayerController?.dispose();
    playSubscription?.cancel();
    volumeSubscription?.cancel();

    playSubscription = null;
    volumeSubscription = null;
    videoPlayerController = null;
    animationController = null;

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController?.dispose();
    videoPlayerController?.dispose();
    playSubscription?.cancel();
    volumeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final maxWidth = constraints.maxWidth;
        return FutureBuilder(
          future: _initialize(),
          builder: (context, snapshot) {
            if (videoPlayerController != null) {
              _expectedHeight =
                  maxWidth / videoPlayerController!.value.aspectRatio;
            }
            return Container(
              width: maxHeight,
              height: maxWidth,
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  if (widget.videos[widget.index].thumbUrl != null)
                    CachedNetworkImage(
                      imageUrl: widget.videos[widget.index].thumbUrl!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  if (snapshot.connectionState == ConnectionState.done &&
                      videoPlayerController != null)
                    ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: SizedBox(
                            width: (maxHeight > _expectedHeight)
                                ? maxHeight *
                                    videoPlayerController!.value.aspectRatio
                                : maxWidth,
                            height: max(maxHeight, _expectedHeight),
                            child: VideoPlayer(videoPlayerController!)),
                      ),
                    ),
                  if (snapshot.connectionState == ConnectionState.done &&
                      animationController != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        children: List.generate(
                          widget.videos.length,
                          (index) {
                            final width =
                                constraints.maxWidth / widget.videos.length;
                            final showBorder =
                                index != widget.videos.length - 1;
                            if (index < widget.index) {
                              return StaticIndicator(
                                width: width,
                                color: widget.progressBarActiveColor,
                                border: showBorder,
                              );
                            } else if (index == widget.index) {
                              return DynamicIndicator(
                                width: width,
                                controller: animationController!,
                                border: showBorder,
                                backgroundColor:
                                    widget.progressBarInactiveColor,
                                activeColor: widget.progressBarActiveColor,
                              );
                            } else {
                              return StaticIndicator(
                                width: width,
                                color: widget.progressBarInactiveColor,
                                border: showBorder,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
