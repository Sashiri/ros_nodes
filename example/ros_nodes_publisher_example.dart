import 'dart:async';
import 'dart:io';
import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';

void main() async {
  var config = RosConfig(
    'ros_nodes_example_node',
    'http://192.168.1.12:11311/',
    '192.168.1.12',
    24125,
  );
  var client = RosClient(config);
  var topic = RosTopic('chatter', StdMsgsString());
  await client.unregister(topic);
  var publisher = await client.register(topic);

  var i = 0;
  Timer.periodic(
    Duration(milliseconds: 500),
    (timer) async {
      i += 1;
      topic.msg.data = i.toString();
      if (i > 20) {
        await client.unregister(topic);
        timer.cancel();
      }
    },
  );
}
