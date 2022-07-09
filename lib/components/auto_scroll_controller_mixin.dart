part of '../scroll_to_index.dart';


mixin AutoScrollControllerMixin on ScrollController
    implements AutoScrollController {
  @override
  final Map<int, AutoScrollTagState> tagMap = <int, AutoScrollTagState>{};
  double? get suggestedRowHeight;
  ViewportBoundaryGetter get viewportBoundaryGetter;
  AxisValueGetter get beginGetter;
  AxisValueGetter get endGetter;

  bool __isAutoScrolling = false;
  set _isAutoScrolling(bool isAutoScrolling) {
    __isAutoScrolling = isAutoScrolling;
    if (!isAutoScrolling &&
        hasClients) //after auto scrolling, we should sync final scroll position without flag on
      notifyListeners();
  }

  @override
  bool get isAutoScrolling => __isAutoScrolling;

  ScrollController? _parentController;
  @override
  set parentController(ScrollController parentController) {
    if (_parentController == parentController) return;

    final isNotEmpty = positions.isNotEmpty;
    if (isNotEmpty && _parentController != null) {
      for (final p in _parentController!.positions)
        if (positions.contains(p)) _parentController!.detach(p);
    }

    _parentController = parentController;

    if (isNotEmpty && _parentController != null)
      for (final p in positions) _parentController!.attach(p);
  }

  @override
  bool get hasParentController => _parentController != null;

  @override
  void attach(ScrollPosition position) {
    super.attach(position);

    _parentController?.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    _parentController?.detach(position);

    super.detach(position);
  }

  static const maxBound = 30; // 0.5 second if 60fps
  @override
  Future scrollToIndex(int index,
      {Duration? duration,
      Curve? curve,
      AutoScrollPosition? preferPosition}) async {
    duration ??= kAutoScrollControllerDefault.defaultDuration ?? scrollAnimationDuration;
    curve ??= kAutoScrollControllerDefault.defaultCurve ?? Curves.ease;
    preferPosition ??= kAutoScrollControllerDefault.defaultAutoScrollPosition;

    return co(
        this,
        () => _scrollToIndex(index,
            duration!, curve!, preferPosition: preferPosition));
  }

  Future _scrollToIndex(int index,
      Duration duration, Curve curve,
      {AutoScrollPosition? preferPosition}) async {
    assert(duration > Duration.zero);

    // In listView init or reload case, widget state of list item may not be ready for query.
    // this prevent from over scrolling becoming empty screen or unnecessary scroll bounce.
    Future<void> makeSureStateIsReady() async {
      for (var count = 0; count < maxBound; count++) {
        if (_isEmptyStates) {
          await _waitForWidgetStateBuild();
        } else
          return null;
      }

      return null;
    }

    await makeSureStateIsReady();

    if (!hasClients) return null;

    // two cases,
    // 1. already has state. it's in viewport layout
    // 2. doesn't have state yet. it's not in viewport so we need to start scrolling to make it into layout range.
    if (isIndexStateInLayoutRange(index)) {
      _isAutoScrolling = true;

      await _bringIntoViewportIfNeed(index, preferPosition,
          (double offset) async {
        await animateTo(offset, duration: duration, curve: Curves.ease);
        await _waitForWidgetStateBuild();
        return null;
      });

      _isAutoScrolling = false;
    } else {
      // the idea is scrolling based on either
      // 1. suggestedRowHeight or
      // 2. testDistanceOffset
      double prevOffset = offset - 1;
      double currentOffset = offset;
      bool contains = false;
      Duration spentDuration = const Duration();
      double lastScrollDirection = 0.5; // alignment, default center;
      final moveDuration = duration ~/ defaultDurationUnit;

      _isAutoScrolling = true;

      /// ideally, the suggest row height will move to the final corrent offset approximately in just one scroll(iteration).
      /// if the given suggest row height is the minimal/maximal height in variable row height enviroment,
      /// we can just use viewport calculation to reach the final offset in other iteration.
      bool usedSuggestedRowHeightIfAny = true;
      while (prevOffset != currentOffset &&
          !(contains = isIndexStateInLayoutRange(index))) {
        prevOffset = currentOffset;
        final nearest = _getNearestIndex(index);

        if (tagMap[nearest ?? 0] == null) 
          return null;

        final moveTarget =
            _forecastMoveUnit(index, nearest, usedSuggestedRowHeightIfAny)!;
        
        // assume suggestRowHeight will move to correct offset in just one time.
        // if the rule doesn't work (in variable row height case), we will use backup solution (non-suggested way)
        final suggestedDuration =
            usedSuggestedRowHeightIfAny && suggestedRowHeight != null
                ? duration
                : null;
        usedSuggestedRowHeightIfAny = false; // just use once
        lastScrollDirection = moveTarget - prevOffset > 0 ? 1 : 0;
        currentOffset = moveTarget;
        spentDuration += suggestedDuration ?? moveDuration;
        final oldOffset = offset;
        await animateTo(currentOffset,
            duration: suggestedDuration ?? moveDuration, curve: curve);
        await _waitForWidgetStateBuild();
        if (!hasClients || offset == oldOffset) {
          // already scroll to begin or end
          contains = isIndexStateInLayoutRange(index);
          break;
        }
      }
      _isAutoScrolling = false;

      if (contains && hasClients) {
        await _bringIntoViewportIfNeed(
            index, preferPosition ?? _alignmentToPosition(lastScrollDirection),
            (finalOffset) async {
          if (finalOffset != offset) {
            _isAutoScrolling = true;
            final remaining = duration - spentDuration;
            await animateTo(finalOffset,
                duration: remaining <= Duration.zero ? _millisecond : remaining,
                curve: curve);
            await _waitForWidgetStateBuild();

            // not sure why it doesn't scroll to the given offset, try more within 3 times
            if (hasClients && offset != finalOffset) {
              final count = 3;
              for (var i = 0;
                  i < count && hasClients && offset != finalOffset;
                  i++) {
                await animateTo(finalOffset,
                    duration: _millisecond, curve: curve);
                await _waitForWidgetStateBuild();
              }
            }
            _isAutoScrolling = false;
          }
        });
      }
    }

    return null;
  }

  @override
  Future highlight(int index,
      {bool cancelExistHighlights: true,
      Duration highlightDuration: _highlightDuration,
      bool animated: true}) async {
    final tag = tagMap[index];
    return tag == null
        ? null
        : await tag.highlight(
            cancelExisting: cancelExistHighlights,
            highlightDuration: highlightDuration,
            animated: animated);
  }

  @override
  void cancelAllHighlights() {
    _cancelAllHighlights();
  }

  @override
  bool isIndexStateInLayoutRange(int index) => tagMap[index] != null;

  /// this means there is no widget state existing, usually happened before build.
  /// we should wait for next frame.
  bool get _isEmptyStates => tagMap.isEmpty;

  /// wait until the [SchedulerPhase] in [SchedulerPhase.persistentCallbacks].
  /// it means if we do animation scrolling to a position, the Future call back will in [SchedulerPhase.midFrameMicrotasks].
  /// if we want to search viewport element depending on Widget State, we must delay it to [SchedulerPhase.persistentCallbacks].
  /// which is the phase widget build/layout/draw
  Future _waitForWidgetStateBuild() => SchedulerBinding.instance.endOfFrame;

  /// NOTE: this is used to forcase the nearestIndex. if the the index equals targetIndex,
  /// we will use the function, calling _directionalOffsetToRevealInViewport to get move unit.
  double? _forecastMoveUnit(
      int targetIndex, int? currentNearestIndex, bool useSuggested) {
    assert(targetIndex != currentNearestIndex);
    currentNearestIndex = currentNearestIndex ?? 0; //null as none of state

    final alignment = targetIndex > currentNearestIndex ? 1.0 : 0.0;
    double? absoluteOffsetToViewport;

    if (useSuggested && suggestedRowHeight != null) {
      final indexDiff = (targetIndex - currentNearestIndex);
      final offsetToLastState = _offsetToRevealInViewport(
          currentNearestIndex, indexDiff <= 0 ? 0 : 1)!;
      absoluteOffsetToViewport = math.max(
          offsetToLastState.offset + indexDiff * suggestedRowHeight!, 0);
    } else {
      final offsetToLastState =
          _offsetToRevealInViewport(currentNearestIndex, alignment);
      
      absoluteOffsetToViewport = offsetToLastState?.offset;
      if (absoluteOffsetToViewport == null)
        absoluteOffsetToViewport = defaultScrollDistanceOffset;
    }

    return absoluteOffsetToViewport;
  }

  int? _getNearestIndex(int index) {
    final list = tagMap.keys;
    if (list.isEmpty) return null;

    final sorted = list.toList()
      ..sort((int first, int second) => first.compareTo(second));
    final min = sorted.first;
    final max = sorted.last;
    return (index - min).abs() < (index - max).abs() ? min : max;
  }

  /// bring the state node (already created but all of it may not be fully in the viewport) into viewport
  Future _bringIntoViewportIfNeed(int index, AutoScrollPosition? preferPosition,
      Future move(double offset)) async {

    if (preferPosition != null) {
      double targetOffset = _directionalOffsetToRevealInViewport(
          index, _positionToAlignment(preferPosition));

      // The content preferred position might be impossible to reach
      // for items close to the edges of the scroll content, e.g.
      // we cannot put the first item at the end of the viewport or
      // the last item at the beginning. Trying to do so might lead
      // to a bounce at either the top or bottom, unless the scroll
      // physics are set to clamp. To prevent this, we limit the
      // offset to not overshoot the extent in either direction.
      targetOffset = targetOffset.clamp(
          position.minScrollExtent, position.maxScrollExtent);

      await move(targetOffset);
    } else {
      final begin = _directionalOffsetToRevealInViewport(index, 0);
      final end = _directionalOffsetToRevealInViewport(index, 1);

      final alreadyInViewport = offset < begin && offset > end;
      if (!alreadyInViewport) {
        double value;
        if ((end - offset).abs() < (begin - offset).abs())
          value = end;
        else
          value = begin;

        await move(value > 0 ? value : 0);
      }
    }
  }

  double _positionToAlignment(AutoScrollPosition position) {
    return position == AutoScrollPosition.begin
        ? 0
        : position == AutoScrollPosition.end
            ? 1
            : 0.5;
  }

  AutoScrollPosition _alignmentToPosition(double alignment) => alignment == 0
      ? AutoScrollPosition.begin
      : alignment == 1
          ? AutoScrollPosition.end
          : AutoScrollPosition.middle;

  /// return offset, which is a absolute offset to bring the target index object into the location(depends on [direction]) of viewport
  /// see also: _offsetYToRevealInViewport()
  double _directionalOffsetToRevealInViewport(int index, double alignment) {
    assert(alignment == 0 || alignment == 0.5 || alignment == 1);
    // 1.0 bottom, 0.5 center, 0.0 begin if list is vertically from begin to end
    final tagOffsetInViewport = _offsetToRevealInViewport(index, alignment);

    if (tagOffsetInViewport == null) {
      return -1;
    } else {
      double absoluteOffsetToViewport = tagOffsetInViewport.offset;
      if (alignment == 0.5) {
        return absoluteOffsetToViewport;
      } else if (alignment == 0) {
        return absoluteOffsetToViewport - beginGetter(viewportBoundaryGetter());
      } else {
        return absoluteOffsetToViewport + endGetter(viewportBoundaryGetter());
      }
    }
  }

  /// return offset, which is a absolute offset to bring the target index object into the center of the viewport
  /// see also: _directionalOffsetToRevealInViewport()
  RevealedOffset? _offsetToRevealInViewport(int index, double alignment) {
    final ctx = tagMap[index]?.context;
    if (ctx == null) return null;

    final renderBox = ctx.findRenderObject()!;
    assert(Scrollable.of(ctx) != null);
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderBox)!;
    final revealedOffset = viewport.getOffsetToReveal(renderBox, alignment);

    return revealedOffset;
  }
}

