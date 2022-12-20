import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';

import '../miraculous_theme.dart';
import 'base_gallery.dart';
import 'page_indicator.dart';

class ImagePage extends StatefulWidget {
  const ImagePage(this.providers, this.attachments, {Key? key, this.initialPage = 0}) : super(key: key);

  final List<CachedNetworkImageProvider> providers;
  final List<Object> attachments;
  final int initialPage;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with TickerProviderStateMixin {
  static const _platform = MethodChannel('com.cj.miraculousnews');
  static const _successMessage = 'Image downloaded successfully';
  static const _failureMessage = 'Image download failed';

  late final attachments = widget.attachments.isNotEmpty ? widget.attachments : widget.providers;

  late final pageController = PageController(initialPage: widget.initialPage);
  int get page => pageController.hasClients ? pageController.page!.round() : 0;

  void pop() => Navigator.of(context).pop(page);

  Future downloadFile(Uint8List byteData, String ext) =>
      _platform.invokeMethod<bool>('downloadFile', {
        'data': byteData,
        'extension': ext,
      });

  String? getExtension(Uint8List byteData) {
    var decoders = <Decoder>[JpegDecoder(), PngDecoder(), GifDecoder(), WebPDecoder(), BmpDecoder(), TiffDecoder()];
    var extensions = <String>['jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff'];
    for (int i = 0; i < decoders.length; i++)
      if (decoders[i].isValidFile(byteData)) return extensions[i];
    return null;
  }

  void showToast(String message) => Fluttertoast.showToast(msg: message);

  @override
  Widget build(BuildContext context) {
    var theme = context.theme;
    Widget child = Dismissible(
      key: ValueKey('Dismissible'),
      direction: DismissDirection.vertical,
      dismissThresholds: {
        DismissDirection.up: 0.20,
        DismissDirection.down: 0.20,
        DismissDirection.vertical: 0.20,
      },
      confirmDismiss: (direction) async {
        pop();
        return true;
      },
      child: BaseGallery(
        widget.providers,
        widget.attachments,
        pageController: pageController,
      ),
    );
    if (attachments.length > 1) {
      child = Stack(
        alignment: Alignment.bottomCenter,
        children: [
          child,
          Positioned(
            bottom: 16.0,
            child: PageIndicator(
              count: attachments.length,
              pageController: pageController,
            ),
          ),
        ],
      );
    }
    return WillPopScope(
      onWillPop: () async {
        pop();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: theme.surfaceColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            color: theme.onSurfaceColor,
            icon: Icon(Icons.arrow_back),
            onPressed: () => pop(),
          ),
          actions: [
            if (attachments[page] is CachedNetworkImageProvider) IconButton(
              color: theme.onSurfaceColor,
              icon: Icon(Icons.south),
              onPressed: () async {
                try {
                  var response = await http.get(Uri.parse(widget.providers[page].url));
                  if (response.statusCode ~/ 100 != 2) return showToast('$_failureMessage: Unable to fetch image');
                  var byteData = response.bodyBytes;
                  var ext = getExtension(byteData);
                  if (ext == null) return showToast('$_failureMessage: Unknown extension');
                  var result = await downloadFile(byteData, ext);
                  if (result == true) showToast(_successMessage);
                  else showToast(_failureMessage);
                } catch (error) {
                  showToast(error is PlatformException ? error.message ?? _failureMessage : _failureMessage);
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: child,
        ),
      ),
    );
  }
}
