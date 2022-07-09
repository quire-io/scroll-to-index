part of '../scroll_to_index.dart';


class SimpleAutoScrollController extends ScrollController
    with AutoScrollControllerMixin {

  @override
  final double? suggestedRowHeight;
  @override
  final ViewportBoundaryGetter viewportBoundaryGetter;
  @override
  final AxisValueGetter beginGetter;
  @override
  final AxisValueGetter endGetter;

  SimpleAutoScrollController(
      {double initialScrollOffset: 0.0,
      bool keepScrollOffset: true,
      this.suggestedRowHeight,
      this.viewportBoundaryGetter: defaultViewportBoundaryGetter,
      required this.beginGetter,
      required this.endGetter,
      AutoScrollController? copyTagsFrom,
      String? debugLabel})
      : super(
            initialScrollOffset: initialScrollOffset,
            keepScrollOffset: keepScrollOffset,
            debugLabel: debugLabel) {
    if (copyTagsFrom != null) tagMap.addAll(copyTagsFrom.tagMap);
  }
}

