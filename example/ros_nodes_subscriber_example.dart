import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';
import 'package:ros_nodes/src/ros_node.dart';

void main() {
  var config = RosNode('http://tutibot:11311/', '192.168.1.2', 24125);
  var msg = StdMsgsString();
  var subscriber =
      RosSubscriber('ros_nodes_example_subscriber', 'chatter', msg, config);
  subscriber.subscribe();
  subscriber.onValueUpdate.listen((type) => print('Listener 1: ${type.data}'));
  subscriber.onValueUpdate.listen((_) => print('Listener 2: ${msg.data}'));
}
