//Copyright (C) 2019 Potix Corporation. All Rights Reserved.
//History: Tue Apr 24 09:29 CST 2019
// Author: Jerry Chen

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final controller = AutoScrollController();
  final random = math.Random();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Demo'),
        ),
        body: ListView(
          controller: controller,
          children: List
            .generate(100, (index) => <int>[index, (1000 * random.nextDouble()).toInt()])
            .map((data) => _getRow(data[0], data[1].toDouble())),
        ),
      ),
    );
  }

  Widget _getRow(int index, double height) {
    return _wrapScrollTag(
      index: index,
      child: Container(
        alignment: Alignment.topCenter,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.lightBlue,
            width: 4
          ),
          borderRadius: BorderRadius.circular(4)
        ),
        child: Text('index: $index, height: $height'),
      )
    );
  }

  Widget _wrapScrollTag({int index, Widget child})
  => AutoScrollTag(
    key: ValueKey(index),
    controller: controller,
    index: index,
    child: child,
    highlightColor: Colors.lime,
  );
}