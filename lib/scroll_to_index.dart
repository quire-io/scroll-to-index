//Copyright (C) 2019 Potix Corporation. All Rights Reserved.
//History: Tue Apr 24 09:17 CST 2019
// Author: Jerry Chen

// Fork Author: Aldahir Higa (FernandoDev007)
// Forked from quire-io/scroll-to-index

library scroll_to_index;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'util.dart';

part 'components/auto_scroll_controller_default.dart';
part 'components/auto_scroll_controller_mixin.dart';
part 'components/auto_scroll_controller.dart';
part 'components/auto_scroll_tag.dart';
part 'components/page_auto_scroll_controller.dart';
part 'components/simple_auto_scroll_controller.dart';


const double defaultScrollDistanceOffset = 100.0;
const int defaultDurationUnit = 40;

const Duration _millisecond = const Duration(milliseconds: 1);
const Duration _highlightDuration = const Duration(seconds: 3);
const Duration scrollAnimationDuration = const Duration(milliseconds: 250);
Map<AutoScrollTagState, AnimationController?> _highlights =
    <AutoScrollTagState, AnimationController?>{};

typedef Rect ViewportBoundaryGetter();
typedef double AxisValueGetter(Rect rect);
typedef Widget TagHighlightBuilder(BuildContext context, Widget? child, Animation<double> highlight);


Rect defaultViewportBoundaryGetter() => const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);


enum AutoScrollPosition {
  begin,
  middle,
  end
}


void _cancelAllHighlights([AutoScrollTagState? state]) {
  for (final tag in _highlights.keys)
    tag._cancelController(reset: tag != state);

  _highlights.clear();
}


Widget buildHighlightTransition({required BuildContext context, required Animation<double> highlight, 
  required Widget child, Color? background, Color? highlightColor}) {
  return DecoratedBoxTransition(
    decoration: DecorationTween(
      begin: background != null ?
      BoxDecoration(color: background) :
      BoxDecoration(),
      end: background != null ?
      BoxDecoration(color: background) :
      BoxDecoration(color: highlightColor)
    ).animate(highlight),
    child: child
  );
}

