import 'package:ros_nodes/src/ros_message.dart';
import '../Time.dart';

class StdMsgsTime extends RosMessage {
  final RosTime _time = RosTime();

  RosTime get time => _time;

  StdMsgsTime()
      : super(
            'time data', 'std_msgs/Time', 'cd7166c74c552c311fbcc2fe5a7bc289') {
    params.add(_time);
  }
}
