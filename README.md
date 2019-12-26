
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
  subscriber.onValueUpdate = () {
    print(msg.data);
  };
}
```

A simple publisher example:
```dart
import 'dart:async';
import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';

void main() {
  var msg = StdMsgsString();
  var publisher = RosPublisher('ros_nodes_example_publisher', 'chatter', msg);
  publisher.register();

  //Default publishing interval is 1 sec, i is gonna increment by ~2 every publish tick.
  //To change publish intervals, set optional publishInterval to needed duration.

  var i = 0;
  Timer.periodic(Duration(milliseconds: 500), (_) {
    i += 1;
    msg.data = i.toString();
  });
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Sashiri/ros_nodes/issues
