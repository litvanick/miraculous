import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'miraculous_theme.dart';
import '../widgets/loading_controller.dart';

typedef Deserialize<T> = T Function(FirebaseDocument);

class MiraculousPage<T> extends StatefulWidget {
  const MiraculousPage({
    Key? key,
    required this.controller,
    required this.itembuilder,
    required this.deserialize,
    this.onLoaded,
    this.noItemsText = 'Nothing New'
  }) : super(key: key);

  final LoadingController controller;
  final Widget Function(T item, ScrollController parentController) itembuilder;
  final Deserialize<T> deserialize;
  final void Function()? onLoaded;
  final String noItemsText;

  @override
  _MiraculousPageState<T> createState() => _MiraculousPageState<T>();
}

class _MiraculousPageState<T> extends State<MiraculousPage<T>> {
  late final controller = widget.controller;
  final scrollController = ScrollController();

  final _pagingController = PagingController<int, FirebaseDocument>(firstPageKey: 0);
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    controller.pagingController = _pagingController;
    controller.scrollController = scrollController;
    controller.refreshKey = _refreshKey;
    _pagingController.addPageRequestListener((key) => controller.load(key));
  }

  @override
  void dispose() {
    controller.pagingController = null;
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => controller.load(0, true),
      color: theme.onIndicatorColor,
      backgroundColor: theme.indicatorColor,
      child: PagedListView<int, FirebaseDocument>.separated(
        pagingController: _pagingController,
        scrollController: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        separatorBuilder: (context, index) => SizedBox(height: 16.0),
        builderDelegate: PagedChildBuilderDelegate<FirebaseDocument>(
          itemBuilder: (_, document, index) => widget.itembuilder(widget.deserialize(document), scrollController),
          noItemsFoundIndicatorBuilder: (context) => Center(child: NoItemsWidget(widget.noItemsText)),
          firstPageProgressIndicatorBuilder: (context) => Center(child: CircularProgressIndicator(color: theme.onImageColor)),
          newPageProgressIndicatorBuilder: (context) => Center(child: CircularProgressIndicator(color: theme.onImageColor)),
          firstPageErrorIndicatorBuilder: (context) {
            return MiraculousError(
              direction: Axis.vertical,
              onReload: _pagingController.retryLastFailedRequest,
            );
          },
          newPageErrorIndicatorBuilder: (context) {
            return MiraculousError(
              direction: Axis.horizontal,
              wrap: false,
              onReload: _pagingController.retryLastFailedRequest,
            );
          },
        ),
      ),
    );
  }
}

class ItemBox extends StatelessWidget {
  const ItemBox({Key? key, this.child, this.padding, this.borderRadius}) : super(key: key);

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.theme.surfaceColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class ItemText extends StatelessWidget {
  const ItemText(this.data, {
    Key? key,
    this.fontSize = 24.0,
    this.textAlign = TextAlign.center,
    this.color,
  }) : super(key: key);

  final String data;
  final double fontSize;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? context.theme.onSurfaceColor,
      ),
    );
  }
}

class NoItemsWidget extends StatelessWidget {
  const NoItemsWidget(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ItemBox(
      child: ItemText(text),
    );
  }
}

class MiraculousError extends StatelessWidget {
  const MiraculousError({Key? key, required this.direction, this.wrap = true, this.onReload}) : super(key: key);

  final Axis direction;
  final bool wrap;
  final void Function()? onReload;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ItemBox(
      borderRadius: BorderRadius.zero,
      child: Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 40.0,
            color: theme.onSurfaceColor,
          ),
          ItemText(
            'Error',
            fontSize: 32,
          ),
          if (onReload != null) ElevatedButton(
            child: Text('Reload'),
            onPressed: onReload,
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.secondaryColor,
              backgroundColor: theme.onSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
