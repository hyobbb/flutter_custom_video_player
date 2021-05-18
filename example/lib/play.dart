import 'package:flutter/material.dart';
import 'package:custom_video_player/custom_video_player.dart';

class Play extends StatefulWidget {
  final List<VideoSource> videos;

  const Play(this.videos, {Key? key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  int index = 1;

  @override
  Widget build(BuildContext context) {
    final controller = PlayerController();
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            children: [
              CustomVideoPlayer(
                widget.videos.sublist(0, 3),
                controller,
                startIndex: index,
                looping: true,
                width: 300,
                height: 600,
                onIndexChanged: (idx) {
                  setState(() {
                    index = idx;
                  });
                },
              ),
              Text('$index'),
            ],
          ),
        ));
  }
}
