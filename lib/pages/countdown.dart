import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/loading_controller.dart';
import '../widgets/image/attachment.dart';
import '../widgets/image/image_gallery.dart';
import '../widgets/miraculous_page.dart';
import '../widgets/miraculous_theme.dart';
import '../widgets/no_over_scroll.dart';

class CountDownPage extends StatefulWidget {
  CountDownPage(this.controller, {super.key});

  final LoadingController controller;

  @override
  _CountDownPageState createState() => _CountDownPageState();
}

class _CountDownPageState extends State<CountDownPage> {
  late Timer _timer;

  @override
  void initState() {
    var millis = DateTime.now().millisecondsSinceEpoch;
    Timer(Duration(milliseconds: 1000 - millis % 1000), () {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) => setState(() {}));
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MiraculousPage<CountDown>(
      controller: widget.controller,
      noItemsText: 'No Upcoming Episodes',
      deserialize: CountDown.deserialize,
      itembuilder: (countDown, scrollController) {
        return ItemBox(
          padding: EdgeInsets.zero,
          child: CountDownWidget(
            key: ValueKey(countDown.id),
            countDown: countDown,
          ),
        );
      }
    );
  }
}

class CountDown {
  final String id;
  final String title;
  final DateTime time;
  final String? details;
  final String? channel;
  final String? language;
  final String? synopsis;
  final String? image;

  const CountDown({
    required this.id,
    required this.title,
    required this.time,
    this.details,
    this.channel,
    this.language,
    this.synopsis,
    this.image,
  });

  static CountDown deserialize(FirebaseDocument document) {
    final data = document.data();
    return CountDown(
      id: document.id,
      title: data['title'],
      details: data['details'],
      time: data['time'].toDate().toLocal(),
      channel: data['channel'],
      language: data['language'],
      synopsis: data['synopsis'],
      image: data['image'],
    );
  }
}

class CountDownWidget extends StatefulWidget {
  const CountDownWidget({Key? key, required this.countDown}) : super(key: key);

  final CountDown countDown;

  @override
  _CountDownWidgetState createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> with AutomaticKeepAliveClientMixin {
  late MiraculousTheme theme = context.theme;
  late final countDown = widget.countDown;

  @override
  bool get wantKeepAlive => true;

  Future<void> _showBottomCountDown() {
    return showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      backgroundColor: theme.surfaceColor,
      builder: (_) => SafeArea(
        child: BottomCountDown(
          title: countDown.title,
          content: countDown.synopsis,
          image: countDown.image,
        ),
      ),
    );
  }

  String get channelLanguageText {
    if (countDown.channel == null) return countDown.language!;
    if (countDown.language == null) return countDown.channel!;
    return countDown.channel! + ' / ' + countDown.language!;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    theme = context.theme;
    final duration = countDown.time.difference(DateTime.now());
    return GestureDetector(
      onTap: _showBottomCountDown,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          if (duration.inSeconds <= 0) OutLabel(width: 128, height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                Text(countDown.title, style: TextStyle(fontSize: 24, color: theme.onSurfaceColor)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (countDown.details != null) Text(
                        countDown.details!,
                        style: TextStyle(fontSize: 16, color: theme.onSurfaceColor),
                      ),
                      Text(
                        DateFormat.yMMMMd().add_jm().format(countDown.time),
                        style: TextStyle(fontSize: 16, color: theme.onSurfaceColor)
                      ),
                      if (countDown.channel != null || countDown.language != null) Text(
                        channelLanguageText,
                        style: TextStyle(fontSize: 16, color: theme.onSurfaceColor),
                      ),
                    ],
                  ),
                ),
                countDown.image != null ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ImageGallery([countDown.image!],[Attachment(countDown.image!, AttachmentType.image)]),
                ) : SizedBox(height: 4),
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: CountDownBox(
                        duration: !duration.isNegative ? duration : Duration.zero,
                        type: CountDownBoxType.values[index],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}

class CountDownBox extends StatelessWidget {
  const CountDownBox({Key? key, required this.duration, required this.type}) : super(key: key);

  final Duration duration;
  final CountDownBoxType type;

  int get unit {
    switch (type) {
      case CountDownBoxType.days: return duration.inDays;
      case CountDownBoxType.hours: return duration.inHours.remainder(24);
      case CountDownBoxType.minutes: return duration.inMinutes.remainder(60);
      case CountDownBoxType.seconds: return duration.inSeconds.remainder(60);
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(unit.toString(), style: TextStyle(fontSize: 32, color: context.theme.onSurfaceColor)),
        Text(type.name, style: TextStyle(fontSize: 16, color: context.theme.onSurfaceColor)),
      ],
    );
  }
}

enum CountDownBoxType {days, hours, minutes, seconds}

class OutLabel extends StatelessWidget {
  const OutLabel({ Key? key, required this.width, required this.height }) : super(key: key);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radians = 45 * pi / 180;
    final sin45 = sin(radians);
    final top = height * sin45;
    final right = top + width * (1 - sin45);
    return Positioned(
      top: -top,
      right: -right,
      child: Transform.rotate(
        angle: radians,
        alignment: Alignment.topLeft,
        child: Container(
          width: width,
          height: height,
          color: context.theme.secondaryColor,
          alignment: Alignment.center,
          child: Text(
            'OUT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
              color: context.theme.onSecondaryColor,
            ),
          )
        ),
      ),
    );
  }
}

class BottomCountDown extends StatelessWidget {
  BottomCountDown({Key? key, required this.title, this.content, this.image}) : super(key: key);

  final String title;
  final String? content;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ScrollConfiguration(
      behavior: NoOverscroll(),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 24, color: theme.onSurfaceColor)),
              Container(height: 2, color: theme.onSurfaceColor, margin: EdgeInsets.symmetric(vertical: 4)),
              Text(
                content ?? 'No synopsis yet',
                style: TextStyle(fontSize: 20, color: theme.onSurfaceColor),
                textAlign: TextAlign.justify,
              ),
              if (image != null) Container(
                margin: EdgeInsets.only(top: 8),
                child: ImageGallery([image!], [Attachment(image!, AttachmentType.image)]),
              )
            ],
          ),
        ),
      )
    );
  }
}
