import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TestPlayer extends StatefulWidget {
  final String url;
  final Stream<bool> playSignal;

  const TestPlayer({
    required this.url,
    required this.playSignal,
    Key? key,
  }) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<TestPlayer> with TickerProviderStateMixin {
  VideoPlayerController? videoPlayerController;
  StreamSubscription? playSubscription;

  _initialize() async {
    videoPlayerController = VideoPlayerController.network(widget.url);
    await videoPlayerController!.initialize();
    videoPlayerController?.addListener(_videoStatusListener);
    playSubscription = widget.playSignal.listen((shouldPlay) {
      if (shouldPlay) {
        videoPlayerController?.play();
      } else {
        videoPlayerController?.pause();
      }
    });

    if (this.mounted) {
      videoPlayerController?.play();
    }
  }

  _videoStatusListener() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isPlaying) {
      print('playing');
    }
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    playSubscription?.cancel();
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
            if (snapshot.connectionState == ConnectionState.done &&
                videoPlayerController != null) {
              return Container(
                width: maxHeight,
                height: maxWidth,
                child: AspectRatio(
                  aspectRatio: videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController!),
                ),
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
