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
  bool loading = true;
  VideoPlayerController? videoPlayerController;
  AnimationController? animationController;
  StreamSubscription? playSubscription;
  StreamSubscription? volumeSubscription;

  double expectedHeight = 0.0;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  _initialize() {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }

    _setController().then((value) {
      videoPlayerController = value;

      videoPlayerController?.initialize().then((value) {
        animationController = AnimationController(
            vsync: this, duration: videoPlayerController?.value.duration);
        videoPlayerController?.addListener(_videoStatusListener);
        playSubscription = widget.controller.playSignal.listen((play) {
          if (play) {
            videoPlayerController?.play();
            animationController?.forward();
          } else {
            videoPlayerController?.pause();
            animationController?.stop();
          }
        });
        volumeSubscription = widget.controller.volume.listen((volume) {
          videoPlayerController?.setVolume(volume);
        });
        if (this.mounted) {
          animationController?.forward();
          videoPlayerController?.play();
          setState(() {
            loading = false;
          });
        }
      });
    });
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
      return VideoPlayerController.file(File(source.url));
    } else {
      final info = await DefaultCacheManager().getFileFromCache(source.url);
      if (info == null) {
        return VideoPlayerController.network(source.url);
      } else {
        return VideoPlayerController.file(info.file);
      }
    }
  }

  @override
  void didUpdateWidget(covariant Player oldWidget) {
    playSubscription?.cancel();
    volumeSubscription?.cancel();
    playSubscription = null;
    volumeSubscription = null;

    final oldVideo = videoPlayerController;
    final oldAnimation = animationController;

    videoPlayerController = null;
    animationController = null;

    oldVideo?.dispose();
    oldAnimation?.dispose();
    _initialize();
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
        if(videoPlayerController!=null) {
          expectedHeight = maxWidth / videoPlayerController!.value.aspectRatio;
        }
        return Container(
          width: maxHeight,
          height: maxWidth,
          child: Stack(
            children: [
              if (loading && widget.videos[widget.index].thumbUrl != null)
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
              Center(
                child: CircularProgressIndicator(),
              ),
              if (!loading)
                ClipRect(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: SizedBox(
                        width: (maxHeight > expectedHeight)
                            ? maxHeight * videoPlayerController!.value.aspectRatio
                            : maxWidth,
                        height: max(maxHeight , expectedHeight),
                        child: VideoPlayer(videoPlayerController!)),
                  ),
                ),
              if (!loading)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: List.generate(
                      widget.videos.length,
                      (index) {
                        final width = constraints.maxWidth / widget.videos.length;
                        final showBorder = index != widget.videos.length -1;
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
                            backgroundColor: widget.progressBarInactiveColor,
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
  }
}
