import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef FirebaseDocument = QueryDocumentSnapshot<Map<String, dynamic>>;

class LoadingController {
  LoadingController(this.collection, {this.descending = false, this.limit = 8}) {
    query = FirebaseFirestore.instance
      .collection(collection)
      .orderBy('time', descending: descending)
      .limit(limit);
  }

  final String collection;
  final bool descending;
  final int limit;
  late final Query<Map<String, dynamic>> query;

  PagingController<int, FirebaseDocument>? pagingController;
  ScrollController? scrollController;
  GlobalKey<RefreshIndicatorState>? refreshKey;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? last;

  Future<void>? reload() => refreshKey?.currentState?.show();

  Future<void> load(int key, [bool refresh = false]) async {
    assert(pagingController != null, 'A paging controller should be assigned before using a loading controller');
    try {
      if (pagingController!.nextPageKey != 0 || last == null) {
        final q = (refresh || key == 0) ? query : query.startAfterDocument(pagingController!.itemList!.last);
        final snapshot = await q.get();
        last = snapshot.docs;
      }
      if (refresh) {
        scrollController?.jumpTo(0.0);
        pagingController!.refresh();
      }
      else if (last!.length < limit) pagingController!.appendLastPage(last!);
      else pagingController!.appendPage(last!, pagingController!.nextPageKey! + 1);
    } catch (e) {
      pagingController!.error = e;
    }
  }

  Future<void>? scrollUp() {
    return scrollController?.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic
    );
  }
}
