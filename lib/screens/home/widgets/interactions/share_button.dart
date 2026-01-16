import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:makemyday/screens/home/widgets/interactions/interaction_button.dart';

class ShareButton extends StatefulWidget {
  final String id;
  final String title;
  final String previewImageUrl; // custom image passed as prop

  const ShareButton(this.id, this.title, this.previewImageUrl, {super.key});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  final GlobalKey _shareButtonKey = GlobalKey();

  Future<void> _sharePostWithImage() async {
    try {
      // Download the image
      final response = await http.get(Uri.parse(widget.previewImageUrl));
      final bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/preview.jpg',
      ).writeAsBytes(bytes);

      final url = 'https://makemydaynow.netlify.app/post/${widget.id}';
      final shareText = '${widget.title}\n\n$url';

      // Get the render box to pass the correct position to the iOS share sheet
      final RenderBox? renderBox = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final Offset? position = renderBox?.localToGlobal(Offset.zero);
      final Size? size = renderBox?.size;

      Rect? sharePositionOrigin;
      if (position != null && size != null) {
        sharePositionOrigin = Rect.fromLTWH(
          position.dx,
          position.dy,
          size.width,
          size.height,
        );
      }

      // Share both image and text with clickable link
      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        subject: widget.title,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      print('Error sharing post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractionButton(
      child: Container(
        // padding: EdgeInsets.all(8),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Center(
            child: IconButton(
              key: _shareButtonKey,
              icon: Icon(
                Icons.share,
                color: Colors.black54,
                size: 24.0,

                semanticLabel: 'Share this post',
              ),
              onPressed: _sharePostWithImage,
            ),
          ),
        ),
      ),
    );
  }
}
