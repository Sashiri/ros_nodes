import 'package:ros_nodes/messages/String.dart';
import 'package:ros_nodes/src/ros_message.dart';

class StdMsgsString extends RosMessage {
  final RosString _string = RosString();

  String get val => _string.val;
  set val(value) {
    _string.val = value;
  }

  StdMsgsString()
      : super('string data', 'std_msgs/String',
            '992ce8a1687cec8c8bd883ec73ca41d1') {
    params.add(_string);
  }
}
