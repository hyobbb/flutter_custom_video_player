import 'package:flutter/material.dart';
import 'package:custom_video_player/custom_video_player.dart';

class Play extends StatefulWidget {
  final videos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  PageController pageController = PageController();
  final controller = PlayerController();

  @override
  void initState() {
    pageController.addListener(() {
      if ((pageController.page! - pageController.page!.toInt()) == 0 &&
          (pageController.offset <= pageController.position.maxScrollExtent) &&
          (pageController.offset >= pageController.position.minScrollExtent)) {
        ///when page view scroll fixed
        controller.play();
      } else {
        ///on scrolling page view
        controller.pause();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: PageView(
          controller: pageController,
          children: [
            TestPlayer(
              url: widget.videos.first,
              playSignal: controller.playSignal,
            ),
            TestPlayer(
              url: widget.videos.first,
              playSignal: controller.playSignal,
            ),
          ],
        ),
      ),
    );
  }
}
