import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/image/attachment.dart';
import '../widgets/image/image_gallery.dart';
import '../widgets/loading_controller.dart';
import '../widgets/miraculous_page.dart';
import '../widgets/miraculous_theme.dart';

void launch(String url) async => await canLaunchUrl(Uri.parse(url)) ? launchUrl(Uri.parse(url)) : null;

class ArtPage extends StatelessWidget {
  const ArtPage(this.controller, {super.key});

  final LoadingController controller;

  @override
  Widget build(BuildContext context) {
    return MiraculousPage<Art>(
      controller: controller,
      noItemsText: 'Nothing Here Yet',
      deserialize: Art.deserialize,
      itembuilder: (art, scrollControler) {
        return ItemBox(
          child: ArtWidget(
            key: ValueKey(art.id),
            art: art,
            parentController: scrollControler,
          ),
        );
      },
    );
  }
}

class Art {
  final String id;
  final List<String> images;
  final String title;
  final String credit;
  final String source;

  const Art({
    required this.id,
    required this.images,
    required this.title,
    required this.credit,
    required this.source,
  });

  static Art deserialize(FirebaseDocument document) {
    final data = document.data();
    return Art(
      id: document.id,
      images: (data['images'] ?? []).map<String>((img) => img as String).toList(),
      title: data['title'],
      credit: data['credit'],
      source: data['source'],
    );
  }
}

class ArtWidget extends StatelessWidget {
  const ArtWidget({super.key, required this.art, this.parentController});

  final Art art;
  final ScrollController? parentController;

  @override
  Widget build(BuildContext context) {
    var theme = context.theme;
    return Column(
      children: [
        Text(art.title, style: TextStyle(fontSize: 24, color: theme.onSurfaceColor)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ImageGallery([],
            art.images.map((image) => Attachment(image, AttachmentType.image)).toList(),
            parentController: parentController,
          ),
        ),
        Row(
          children: [
            Text(art.credit, style: TextStyle(fontSize: 16.0, color: theme.onSurfaceColor)),
            Spacer(),
            GestureDetector(
              onTap: () => launch(art.source),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Source', style: TextStyle(fontSize: 16.0, color: theme.onSurfaceColor)),
                  Icon(
                    Icons.open_in_new,
                    size: 16.0,
                    color: theme.onSurfaceColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
