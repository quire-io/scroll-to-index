part of '../scroll_to_index.dart';


const AutoScrollControllerDefault kAutoScrollControllerDefault = const AutoScrollControllerDefault(
  defaultDuration: scrollAnimationDuration,
  defaultCurve: Curves.ease,
);


class AutoScrollControllerDefault {

  final Duration? defaultDuration;
  final AutoScrollPosition? defaultAutoScrollPosition;
  final Curve? defaultCurve;

  const AutoScrollControllerDefault({
    this.defaultDuration,
    this.defaultAutoScrollPosition,
    this.defaultCurve
  });

}

