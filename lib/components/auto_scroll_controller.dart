part of '../scroll_to_index.dart';


abstract class AutoScrollController implements ScrollController {

  factory AutoScrollController(
      {double initialScrollOffset = 0.0,
      bool keepScrollOffset = true,
      double? suggestedRowHeight,
      AutoScrollControllerDefault? autoScrollDefault,
      ViewportBoundaryGetter viewportBoundaryGetter:
          defaultViewportBoundaryGetter,
      Axis? axis,
      String? debugLabel,
      AutoScrollController? copyTagsFrom}) {
    if (autoScrollDefault != null) {
      kAutoScrollControllerDefault = autoScrollDefault;
    }

    return SimpleAutoScrollController(
        initialScrollOffset: initialScrollOffset,
        keepScrollOffset: keepScrollOffset,
        suggestedRowHeight: suggestedRowHeight,
        viewportBoundaryGetter: viewportBoundaryGetter,
        beginGetter: axis == Axis.horizontal ? (r) => r.left : (r) => r.top,
        endGetter: axis == Axis.horizontal ? (r) => r.right : (r) => r.bottom,
        copyTagsFrom: copyTagsFrom,
        debugLabel: debugLabel);
  }

  /// used to quick scroll to a index if the row height is the same
  double? get suggestedRowHeight;

  /// used to make the additional boundary for viewport
  /// e.g. a sticky header which covers the real viewport of a list view
  ViewportBoundaryGetter get viewportBoundaryGetter;

  /// used to choose which direction you are using.
  /// e.g. axis == Axis.horizontal ? (r) => r.left : (r) => r.top
  AxisValueGetter get beginGetter;
  AxisValueGetter get endGetter;

  /// detect if it's in scrolling (scrolling is a async process)
  bool get isAutoScrolling;

  /// all layout out states will be put into this map
  Map<int, AutoScrollTagState> get tagMap;

  /// used to chaining parent scroll controller
  set parentController(ScrollController parentController);

  /// check if there is a parent controller
  bool get hasParentController;

  /// scroll to the giving index
  Future<void> scrollToIndex(int index,
      {Duration? duration,
      Curve? curve,
      AutoScrollPosition? preferPosition});

  /// highlight the item
  Future<void> highlight(int index,
      {bool cancelExistHighlights = true,
      Duration highlightDuration = _highlightDuration,
      bool animated = true});

  /// cancel all highlight item immediately.
  void cancelAllHighlights();

  /// check if the state is created. that is, is the indexed widget is layout out.
  /// NOTE: state created doesn't mean it's in viewport. it could be a buffer range, depending on flutter's implementation.
  bool isIndexStateInLayoutRange(int index);
}

