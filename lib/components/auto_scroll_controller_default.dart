part of '../scroll_to_index.dart';


AutoScrollControllerDefault kAutoScrollControllerDefault = const AutoScrollControllerDefault(
  defaultDuration: scrollAnimationDuration,
  defaultCurve: Curves.ease,
  defaultAutoScrollPosition: AutoScrollPosition.begin,
);


class AutoScrollControllerDefault {

  final Duration? defaultDuration;
  final AutoScrollPosition? defaultAutoScrollPosition;
  final Curve? defaultCurve;

  const AutoScrollControllerDefault({
    this.defaultDuration = scrollAnimationDuration,
    this.defaultAutoScrollPosition,
    this.defaultCurve,
  }) : super();

}

