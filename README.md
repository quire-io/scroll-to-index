# scroll-to-index

This package provides the scroll to index mechanism for fixed/variable row height for Flutter scrollable widget.

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  scroll_to_index: any
```

In your library add the following import:

```dart
import 'package:scroll_to_index/scroll_to_index.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage

This is a widget level library, means you can use this mechanism inside any Flutter scrollable widget.

Example for Flutter ListView

``` dart
ListView(
  scrollDirection: scrollDirection,
  controller: controller,
  children: randomList.map<Widget>((data) {
  	final index = data[0];
  	final height = data[1];
    return AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: Text('index: $index, height: $height'),
      highlightColor: Colors.black.withOpacity(0.1),
    );
  }).toList(),
)

```

you can wrap any of your row widget which has dynamic row height

``` dart
AutoScrollTag(
  key: ValueKey(index),
  controller: controller,
  index: index,
  child: child
)
```

with the `AutoScrollController` controller.

when you need to trigger scroll to a specified index, you can call

```
controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin)
```

even more, with a fixed row height, you can give it a suggested height for more efficient scrolling. there are more configuration.

```
final controller = AutoScrollController(
  //add this for advanced viewport boundary. e.g. SafeArea
  viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),

  //choose vertical/horizontal
  axis: scrollDirection,

  //this given value will bring the scroll offset to the nearest position in fixed row height case.
  //for variable row height case, you can still set the average height, it will try to get to the relatively closer offset 
  //and then start searching.
  suggestedRowHeight: 200
);
```

for full example, please see this [Demo](https://github.com/quire-io/scroll-to-index/blob/master/example/lib/main.dart).

## Who Uses

* [Quire](https://quire.io) - a simple, collaborative, multi-level task management tool.
