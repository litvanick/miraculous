import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/widgets/miraculous_theme.dart';
import '../miraculous_page.dart';

class BaseGallery extends StatelessWidget {
  BaseGallery(this.providers, this.attachments, {
    Key? key,
    PageController? pageController,
    this.onPageChanged,
    this.onTap,
    this.disableGestures = false,
  }) : super(key: key) {
    this.pageController = pageController ?? PageController();
  }

  final List<CachedNetworkImageProvider> providers;
  final List<Object> attachments;
  late final PageController pageController;
  final void Function(int index)? onPageChanged;
  final Function(int index)? onTap;
  final bool disableGestures;

  double? getProgress(ImageChunkEvent? progress) {
    if (progress?.expectedTotalBytes == null) return null;
    return progress!.cumulativeBytesLoaded / progress.expectedTotalBytes!;
  }

  @override
  Widget build(BuildContext context) {
    var attachmentProviders = attachments.isNotEmpty ? attachments : providers;
    final builder = PhotoViewGallery.builder(
      itemCount: attachmentProviders.length,
      pageController: pageController,
      backgroundDecoration: BoxDecoration(color: context.theme.surfaceColor),
      builder: (context, index) {
        var attachment = attachmentProviders[index];
        if (attachment is CachedNetworkImageProvider) {
          return PhotoViewGalleryPageOptions(
            imageProvider: attachment,
            onTapDown: (context, details, value) => onTap?.call(index),
            disableGestures: disableGestures,
            errorBuilder: (_, url, error) {
              return MiraculousError(
                direction: Axis.horizontal,
                wrap: false,
              );
            },
          );
        }
        return PhotoViewGalleryPageOptions.customChild(
          child: attachment is ChewieController
              ? Chewie(controller: attachment)
              : Center(child: CircularProgressIndicator(color: context.theme.onSurfaceColor)),
        );
      },
      loadingBuilder: (context, progress) {
        return Center(
          child: CircularProgressIndicator(
            color: context.theme.onSurfaceColor,
            value: getProgress(progress),
          ),
        );
      },
    );
    if (!disableGestures) return builder;
    return GestureDetector(
      onTap: () => onTap?.call(pageController.page!.round()),
      child: builder,
    );
  }
}