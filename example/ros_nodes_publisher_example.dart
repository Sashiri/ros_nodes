import 'dart:async';
import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';
import 'package:ros_nodes/src/ros_node.dart';

void main() {
  var config = RosNode('http://MASTER_URI:11311/', '192.168.1.2', 24125);
  var msg = StdMsgsString();
  var publisher =
      RosPublisher('ros_nodes_example_publisher', 'chatter', msg, config);
  publisher.register();

  var i = 0;
  Timer.periodic(Duration(milliseconds: 500), (_) {
    i += 1;
    msg.data = i.toString();
  });
}
