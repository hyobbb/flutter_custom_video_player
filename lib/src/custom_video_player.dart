import 'package:custom_video_player/src/player.dart';
import 'package:custom_video_player/src/player_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'data.dart';

class CustomVideoPlayer extends StatefulWidget {
  final List<VideoSource> videos;
  final PlayerController controller;
  final int startIndex;
  final bool looping;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onDone;
  final VoidCallback? onPrev;
  final double? width;
  final double? height;
  final bool showProgressBar;
  final Color progressBarActiveColor;
  final Color progressBarInactiveColor;

  const CustomVideoPlayer(
    this.videos,
    this.controller, {
    this.startIndex = 0,
    this.looping = false,
    this.onIndexChanged,
    this.onDone,
    this.onPrev,
    this.width,
    this.height,
    this.showProgressBar = true,
    this.progressBarActiveColor = Colors.red,
    this.progressBarInactiveColor = Colors.white12,
  });

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = widget.startIndex;
    widget.videos.forEach((element) {
      if (element.type == SourceType.network) {
        DefaultCacheManager().downloadFile(element.url);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        widget.controller.pause();
      },
      onLongPressEnd: (details) {
        widget.controller.play();
      },
      onTapUp: (detail) {
        if (detail.globalPosition.dx > MediaQuery.of(context).size.width / 2) {
          _onNext();
        } else {
          _onPrev();
        }
        widget.controller.play();
      },
      onVerticalDragEnd: (endDetails) {
        var velocity = endDetails.primaryVelocity;
        if (velocity != null && velocity > 0) {
          widget.controller.pause();
          Navigator.pop(context);
        }
        widget.controller.play();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Player(
          videos: widget.videos,
          index: currentIndex,
          controller: widget.controller,
          showProgressBar: widget.showProgressBar,
          progressBarActiveColor: widget.progressBarActiveColor,
          progressBarInactiveColor: widget.progressBarInactiveColor,
          onDone: _onNext,
        ),
      ),
    );
  }

  _onNext() {
    if (currentIndex == widget.videos.length - 1) {
      if (widget.looping) {
        setState(() {
          currentIndex = 0;
          if (widget.onIndexChanged != null) {
            widget.onIndexChanged!(currentIndex);
          }
        });
      } else {
        if(widget.onDone!=null) {
          widget.onDone!();
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      setState(() {
        currentIndex += 1;
        if (widget.onIndexChanged != null) {
          widget.onIndexChanged!(currentIndex);
        }
      });
    }
  }

  _onPrev() {
    if (currentIndex == 0) {
      if (widget.looping) {
        setState(() {
          currentIndex = widget.videos.length - 1;
          if (widget.onIndexChanged != null) {
            widget.onIndexChanged!(currentIndex);
          }
        });
      } else {
        if(widget.onPrev!=null) {
          widget.onPrev!();
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      setState(() {
        currentIndex -= 1;
        if (widget.onIndexChanged != null) {
          widget.onIndexChanged!(currentIndex);
        }
      });
    }
  }
}
