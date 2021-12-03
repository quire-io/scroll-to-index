//Copyright (C) 2019 Potix Corporation. All Rights Reserved.
//History: Tue Apr 24 09:29 CST 2019
// Author: Jerry Chen

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll To Index Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Scroll To Index Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const maxCount = 100;
  static const double maxHeight = 1000;
  final random = math.Random();
  final scrollDirection = Axis.vertical;

  late AutoScrollController controller;
  late List<List<int>> randomList;

  Curve _curve = Curves.ease;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    randomList = List.generate(maxCount,
        (index) => <int>[index, (maxHeight * random.nextDouble()).toInt()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => counter = 0);
              _scrollToCounter();
            },
            icon: Text('First'),
          ),
          IconButton(
            onPressed: () {
              setState(() => counter = maxCount - 1);
              _scrollToCounter();
            },
            icon: Text('Last'),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: (AppBarTheme.of(context).backgroundColor ??
                    Theme.of(context).colorScheme.primary)
                .withOpacity(.33),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Curve:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.75 + 24,
                  child: DropdownButtonFormField(
                    value: _curve,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 24,
                    ),
                    iconSize: 24,
                    items: {
                      'linear': Curves.linear,
                      'decelerate': Curves.decelerate,
                      'fastLinearToSlowEaseIn': Curves.fastLinearToSlowEaseIn,
                      'ease': Curves.ease,
                      'easeIn': Curves.easeIn,
                      'easeInToLinear': Curves.easeInToLinear,
                      'easeInSine': Curves.easeInSine,
                      'easeInQuad': Curves.easeInQuad,
                      'easeInCubic': Curves.easeInCubic,
                      'easeInQuart': Curves.easeInQuart,
                      'easeInQuint': Curves.easeInQuint,
                      'easeInExpo': Curves.easeInExpo,
                      'easeInCirc': Curves.easeInCirc,
                      'easeInBack': Curves.easeInBack,
                      'easeOut': Curves.easeOut,
                      'linearToEaseOut': Curves.linearToEaseOut,
                      'easeOutSine': Curves.easeOutSine,
                      'easeOutQuad': Curves.easeOutQuad,
                      'easeOutCubic': Curves.easeOutCubic,
                      'easeOutQuart': Curves.easeOutQuart,
                      'easeOutQuint': Curves.easeOutQuint,
                      'easeOutExpo': Curves.easeOutExpo,
                      'easeOutCirc': Curves.easeOutCirc,
                      'easeOutBack': Curves.easeOutBack,
                      'easeInOut': Curves.easeInOut,
                      'easeInOutSine': Curves.easeInOutSine,
                      'easeInOutQuad': Curves.easeInOutQuad,
                      'easeInOutCubic': Curves.easeInOutCubic,
                      'easeInOutQuart': Curves.easeInOutQuart,
                      'easeInOutQuint': Curves.easeInOutQuint,
                      'easeInOutExpo': Curves.easeInOutExpo,
                      'easeInOutCirc': Curves.easeInOutCirc,
                      'easeInOutBack': Curves.easeInOutBack,
                      'fastOutSlowIn': Curves.fastOutSlowIn,
                      'slowMiddle': Curves.slowMiddle,
                      'bounceIn': Curves.bounceIn,
                      'bounceOut': Curves.bounceOut,
                      'bounceInOut': Curves.bounceInOut,
                      'elasticIn': Curves.elasticIn,
                      'elasticOut': Curves.elasticOut,
                      'elasticInOut': Curves.elasticInOut
                    }
                        .entries
                        .map((entry) => DropdownMenuItem(
                            value: entry.value,
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.75,
                                child: Text(entry.key))))
                        .toList(),
                    onChanged: (Curve? value) {
                      _curve = value ?? Curves.ease;
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: scrollDirection,
              controller: controller,
              children: randomList.map<Widget>((data) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: _getRow(data[0], math.max(data[1].toDouble(), 50.0)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextCounter,
        tooltip: 'Increment',
        child: Text(counter.toString()),
      ),
    );
  }

  int counter = -1;
  Future _nextCounter() {
    setState(() => counter = (counter + 1) % maxCount);
    return _scrollToCounter();
  }

  Future _scrollToCounter() async {
    await controller.scrollToIndex(
      counter,
      preferPosition: AutoScrollPosition.middle,
      curve: _curve,
    );
    controller.highlight(counter);
  }

  Widget _getRow(int index, double height) {
    return _wrapScrollTag(
        index: index,
        child: Container(
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          height: height,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue, width: 4),
              borderRadius: BorderRadius.circular(12)),
          child: Text('index: $index, height: $height'),
        ));
  }

  Widget _wrapScrollTag({required int index, required Widget child}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: controller,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );
}
