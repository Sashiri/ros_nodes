
Library template made by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple subscriber example:
```dart
import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';

void main() {
  var msg = StdMsgsString();
  var subscriber =
      RosSubscriber('ros_nodes_example_subscriber', 'chatter', msg);
  subscriber.subscribe();
  subscriber.onValueUpdate.listen((type) => print('Listener 1: ${type.data}'));
  subscriber.onValueUpdate.listen((_) => print('Listener 2: ${msg.data}'));
}
```

`onValueUpdate` is broadcast `Stream`. This stream emmits suppplied `RosMessage` as stream parameter, so we don't need to save it as a variable.

```dart
subscriber.onValueUpdate.listen((type) => print('Listener 1: ${type.data}'));
subscriber.onValueUpdate.listen((_) => print('Listener 2: ${msg.data}'));
```

It's important to say, that supplied `RosMessage` object, here `StdMsgsString`, is used as container for all data changes, both for publishing and getting data from other nodes. That's why both listeners will print the same data, both approaches are consider valid.

A simple publisher example:

```dart
import 'dart:async';
import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';

void main() {
  var msg = StdMsgsString();
  var publisher = RosPublisher('ros_nodes_example_publisher', 'chatter', msg);
  publisher.register();

  var i = 0;
  Timer.periodic(Duration(milliseconds: 500), (_) {
    i += 1;
    msg.data = i.toString();
  });
}
```

By default `RosPublisher` will send updates every second. 
To change the interval you need to supply `publishInterval` parameter.

``` dart
var i = 0;
Timer.periodic(Duration(milliseconds: 500), (_) {
  i += 1;
  msg.data = i.toString();
});
```
To change the published data we operate on supplied `RosMessage` type, in this case it's `StdMsgsString`.

All currently implemented messages are placed in lib/messages, where direct .dart files are wrappers for base type messages like `RosString` in String.dart file, and subfolders are meant for published messages like tf/tfMessage.dart as `TfTfMessage` or std_msgs/String.dart for aforementioned `StdMsgsString`.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Sashiri/ros_nodes/issues
