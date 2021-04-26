import 'dart:async';
import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';

void main() async {
  var config = RosConfig(
    'ros_nodes_example_node',
    'http://127.0.0.1:11311/',
    '127.0.0.1',
    24125,
  );
  var client = RosClient(config);
  var topic = RosTopic('chatter', StdMsgsString());
  await client.unregister(topic);

  var publisher = await client.register(topic,
      publishInterval: Duration(milliseconds: 1000));

  var i = 0;
  Timer.periodic(
    Duration(milliseconds: 500),
    (_) {
      i += 1;
      topic.msg.data = i.toString();
    },
  );
}
