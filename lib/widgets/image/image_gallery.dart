import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../miraculous_theme.dart';
import 'attachment.dart';
import 'base_gallery.dart';
import 'float_index.dart';
import 'image_page.dart';
import 'page_indicator.dart';

class ImageGallery extends StatefulWidget {
  const ImageGallery(this.images, this.attachments, {super.key, this.parentController});

  final List<String> images;
  final List<Attachment> attachments;
  final ScrollController? parentController;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final pageController = PageController();
  
  late final providers = widget.images.map((image) => CachedNetworkImageProvider(image)).toList();
  late final attachments = widget.attachments.map((attachment) {
    if (attachment.isImage) return CachedNetworkImageProvider(attachment.url);
    return VideoPlayerController.network(attachment.url);
  }).toList();
  late final attachmentProviders = attachments.isNotEmpty ? attachments : providers;

  late final _defaultWidth = MediaQuery.of(context).size.width - 64;
  late final _defaultHeight = MediaQuery.of(context).size.height * 0.25;
  late final heights = List<double>.filled(attachmentProviders.length, _defaultHeight);

  double get currentHeight => heights.atFloatIndex(pageController.hasClients ? pageController.page! : 0);

  void setHeights() {
    attachmentProviders.asMap().forEach((index, provider) async {
      if (provider is CachedNetworkImageProvider) {
        provider.resolve(ImageConfiguration()).addListener(ImageStreamListener((imageInfo, isSynchronous) {
          heights[index] = imageInfo.image.height * (_defaultWidth / imageInfo.image.width);
          setState(() {});
        }));
      } else if (provider is VideoPlayerController) {
        await provider.initialize();
        heights[index] = _defaultWidth / provider.value.aspectRatio;
        attachmentProviders[index] = ChewieController(
          videoPlayerController: provider,
          aspectRatio: provider.value.aspectRatio,
          customControls: MaterialDesktopControls(),
          materialProgressColors: ChewieProgressColors(
            bufferedColor: const Color.fromRGBO(100, 100, 100, 0.5),
          ),
        );
        setState(() {});
      }
    });
  }

  Future<void> openImagePage(index) async {
    int page = await Navigator.push(context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ImagePage(providers, attachments, initialPage: pageController.page!.round()),
        opaque: false,
        transitionDuration: Duration(milliseconds: 500),
        reverseTransitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final fadeTween = CurveTween(curve: Curves.easeOut);
          final colorTween = ColorTween(begin: context.theme.navigationColor, end: context.theme.surfaceColor)
              .chain(CurveTween(curve: Curves.easeOut));
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: animation.drive(colorTween).value,
            ),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        }
      ),
    );
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    pageController.addListener(() => setState(() {}));
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setHeights();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    attachments.forEach((attachmentProvider) {
      if (attachmentProvider is ChewieController) {
        attachmentProvider.videoPlayerController.dispose();
        attachmentProvider.dispose();
      } else if (attachmentProvider is VideoPlayerController) {
        attachmentProvider.dispose();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        final newPixels = notification.metrics.pixels;
        final oldPixels = newPixels - notification.scrollDelta!;
        final itemPixels = notification.metrics.maxScrollExtent / (attachmentProviders.length - 1);
        final delta = heights.atFloatIndex(newPixels / itemPixels) - heights.atFloatIndex(oldPixels / itemPixels);
        widget.parentController?.jumpTo(widget.parentController!.offset + delta / 2);
        return true;
      },
      child: Container(
        width: _defaultWidth,
        height: currentHeight,
        child: BaseGallery(
          providers,
          attachments,
          pageController: pageController,
          onTap: openImagePage,
          disableGestures: true,
        ),
      ),
    );
    if (attachmentProviders.length <= 1) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(height: 8.0),
        PageIndicator(pageController: pageController, count: attachmentProviders.length),
      ],
    );
  }
}
