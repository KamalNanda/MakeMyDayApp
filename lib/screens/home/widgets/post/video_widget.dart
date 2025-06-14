import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:makemyday/utils/constants.dart' as globals;

// ignore: must_be_immutable
class VideoWidget extends StatefulWidget {
  final String media_url;
  final Player player;

  const VideoWidget(this.media_url, this.player, {Key? key}) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoController(widget.player);
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: Container( 
        color: Colors.black,
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: 190 + globals.video_widget_height_constant,
            child: Padding(
              padding: const EdgeInsets.only(bottom:50.0),
              child: Video(controller: controller),
            ),
          ),
        ),
      ),
    );
  }
}