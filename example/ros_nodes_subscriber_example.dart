import 'package:ros_nodes/messages/std_msgs/String.dart';
import 'package:ros_nodes/ros_nodes.dart';

Future<void> main() async {
  var config = RosConfig(
    'ros_nodes_example_node_subscriber',
    'http://127.0.0.1:11311/',
    '127.0.0.1',
    24125,
  );
  var client = RosClient(config);
  var msg = StdMsgsString();
  var topic = RosTopic('chatter', msg);
  await client.unsubscribe(topic);

  var subscriber = await client.subscribe(topic);
  subscriber.onValueUpdate.listen((type) => print('Listener 1: ${type.data}'));
  subscriber.onValueUpdate.listen((_) => print('Listener 2: ${msg.data}'));
}
