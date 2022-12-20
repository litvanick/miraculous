import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/loading_controller.dart';
import '../widgets/image/attachment.dart';
import '../widgets/image/image_gallery.dart';
import '../widgets/miraculous_page.dart';
import '../widgets/miraculous_theme.dart';

void launch(String url) async => await canLaunchUrl(Uri.parse(url)) ? launchUrl(Uri.parse(url)) : null;

class SpoilerPage extends StatelessWidget {
  const SpoilerPage(this.controller, {super.key});

  final LoadingController controller;

  @override
  Widget build(BuildContext context) {
    return MiraculousPage<Spoiler>(
      controller: controller,
      noItemsText: 'No News Yet',
      deserialize: Spoiler.deserialize,
      itembuilder: (spoiler, scrollController) {
        return ItemBox(
         child: Article(
           key: ValueKey(spoiler.id),
           spoiler: spoiler,
           parentController: scrollController,
         ),
       );
      }
    );
  }
}

class Spoiler {
  final String id;
  final String title;
  final String content;
  final String? source;
  final List<String> images;
  final List<Attachment> attachments;
  final DateTime time;

  const Spoiler({
    required this.id,
    required this.title,
    required this.content,
    this.source = '',
    this.images = const [],
    this.attachments = const [],
    required this.time,
  });

  static Spoiler deserialize(FirebaseDocument document) {
    final data = document.data();
    return Spoiler(
      id: document.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      source: data['source'],
      images: (data['images'] ?? []).map<String>((img) => img as String).toList(),
      attachments: (data['attachments'] ?? []).map<Attachment>((at) => Attachment.fromJSON(at)).toList(),
      time: data['time'].toDate().toLocal(),
    );
  }
}

class Article extends StatefulWidget {
  const Article({Key? key, required this.spoiler, this.parentController}) : super(key: key);

  final Spoiler spoiler;
  final ScrollController? parentController;

  @override
  _ArticleState createState() => _ArticleState();
}

class _ArticleState extends State<Article> with AutomaticKeepAliveClientMixin {
  var isExpanded = false;

  late final spoiler = widget.spoiler;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = context.theme;
    return Column(
      children: [
        Text(widget.spoiler.title, style: TextStyle(fontSize: 20, color: theme.onSurfaceColor)),
        Container(height: 2, color: context.theme.onSurfaceColor, margin: EdgeInsets.symmetric(vertical: 4)),
        MarkdownBody(
          data: spoiler.content,
          selectable: true,
          softLineBreak: true,
          onTapText: () => setState(() => isExpanded = !isExpanded),
          onTapLink: (text, url, title) => launch(url!),
          styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: 20.0, color: theme.onSurfaceColor),
              bodyMedium: TextStyle(fontSize: 16.0, color: theme.onSurfaceColor),
            ),
          )).copyWith(a: TextStyle(fontSize: 16.0, color: theme.linkColor)),
        ),
        if (spoiler.images.isEmpty && spoiler.attachments.isEmpty) SizedBox(height: 4.0)
        else Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ImageGallery(
            spoiler.images,
            spoiler.attachments,
            parentController: widget.parentController,
          ),
        ),
        Row(
          children: [
            Text(DateFormat.yMMMMd().add_jm().format(spoiler.time), style: TextStyle(color: theme.onSurfaceColor)),
            Spacer(),
            if (spoiler.source != null) GestureDetector(
              onTap: () => launch(spoiler.source!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Source', style: TextStyle(color: theme.onSurfaceColor)),
                  Icon(
                    Icons.open_in_new,
                    size: 14.0,
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
