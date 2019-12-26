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
