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
  final nestedParentScrollViewKey = GlobalKey();

  late AutoScrollController controller;
  late List<List<int>> randomList;
  bool nested = false;

  @override
  void initState() {
    super.initState();
    controller = _getController(nested);
    randomList = List.generate(maxCount,
            (index) => <int>[index, (maxHeight * random.nextDouble()).toInt()]);
  }

  AutoScrollController _getController(bool withScrollerKey) {
    final scrollerKey = withScrollerKey ? nestedParentScrollViewKey : null;

    return AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: scrollDirection,
      scrollerWidgetKey: scrollerKey, // only need to assign in nested use case
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                nested = !nested;
                controller = _getController(nested);
              });
            },
            icon: Text(nested ? 'Single' : 'Nested'),
            iconSize: 50,
          ),
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
      body: nested ? _buildNestedListView() : _buildSingleListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextCounter,
        tooltip: 'Increment',
        child: Text(counter.toString()),
      ),
    );
  }

  Widget _buildSingleListView() {
    return ListView(
      scrollDirection: scrollDirection,
      controller: controller,
      children: randomList.map<Widget>((data) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: _getRow(data[0], math.max(data[1].toDouble(), 50.0)),
        );
      }).toList(),
    );
  }

  Widget _buildNestedListView() {
    return SingleChildScrollView(
      key: nestedParentScrollViewKey,
      scrollDirection: Axis.vertical,
      controller: controller,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(40),
            child: Text('Nested Demo', style: TextStyle(fontSize: 48)),
          ),
          ListView(
            scrollDirection: scrollDirection,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: randomList.map<Widget>((data) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: _getRow(data[0], math.max(data[1].toDouble(), 50.0)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int counter = -1;
  Future _nextCounter() {
    setState(() => counter = (counter + 1) % maxCount);
    return _scrollToCounter();
  }

  Future _scrollToCounter() async {
    await controller.scrollToIndex(counter,
        preferPosition: AutoScrollPosition.begin);
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
