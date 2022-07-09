part of '../scroll_to_index.dart';


class PageAutoScrollController extends PageController
    with AutoScrollControllerMixin {
  @override
  final double? suggestedRowHeight;
  @override
  final ViewportBoundaryGetter viewportBoundaryGetter;
  @override
  final AxisValueGetter beginGetter = (r) => r.left;
  @override
  final AxisValueGetter endGetter = (r) => r.right;

  PageAutoScrollController(
      {int initialPage: 0,
      bool keepPage: true,
      double viewportFraction: 1.0,
      this.suggestedRowHeight,
      this.viewportBoundaryGetter: defaultViewportBoundaryGetter,
      AutoScrollController? copyTagsFrom,
      String? debugLabel})
      : super(
            initialPage: initialPage,
            keepPage: keepPage,
            viewportFraction: viewportFraction) {
    if (copyTagsFrom != null) tagMap.addAll(copyTagsFrom.tagMap);
  }
}

