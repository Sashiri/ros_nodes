import 'package:ros_nodes/messages/String.dart';
import 'package:ros_nodes/messages/UInt32.dart';
import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/messages/Time.dart';

class StdMsgsHeader extends RosMessage {
  final RosUInt32 _seq = RosUInt32();
  final RosTime _time = RosTime();
  final RosString _frame_id = RosString();

  int get seq => _seq.val;
  set seq(int value) {
    _seq.val = value;
  }

  RosTime get time => _time;

  String get frame_id => _frame_id.val;
  set frame_id(String value) {
    _frame_id.val = value;
  }

  StdMsgsHeader()
      : super('header data', 'std_msgs/Header',
            '2176decaecbce78abc3b96ef049fabed') {
    params.add(_seq);
    params.add(_time);
    params.add(_frame_id);
  }
}
