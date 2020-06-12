import 'ros_message.dart';

class RosTopic<Message extends RosMessage> {
  final String name;
  final Message msg;
  RosTopic(this.name, this.msg);
}
