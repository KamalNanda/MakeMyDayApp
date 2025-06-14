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

  ShareButton(this.id, this.title, this.previewImageUrl);

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  Future<void> _sharePostWithImage() async {
    try {
      final response = await http.get(Uri.parse(widget.previewImageUrl));
      final bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/preview.jpg',
      ).writeAsBytes(bytes);

      final url = 'https://makemydaynow.netlify.app/post/${widget.id}';

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.title}\n\nRead it here: $url',
        subject: widget.title,
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
              icon: Icon(
                Icons.share,
                color: Colors.white,
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
