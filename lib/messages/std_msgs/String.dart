import 'package:ros_nodes/messages/String.dart';
import 'package:ros_nodes/src/ros_message.dart';

class StdMsgsString extends RosMessage {
  final RosString _data = RosString();

  String get data => _data.val;
  set data(value) {
    _data.val = value;
  }

  StdMsgsString()
      : super('string data', 'std_msgs/String',
            '992ce8a1687cec8c8bd883ec73ca41d1') {
    params.add(_data);
  }
}
