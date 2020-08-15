import 'package:ros_nodes/ros_nodes.dart';
import '../std_msgs/Header.dart';
import 'Pose.dart';

class PoseStamped extends RosMessage {
  final header = StdMsgsHeader();
  final pose = GeometryMsgsPose();

  PoseStamped()
      : super('A Pose with reference coordinate frame and timestamp',
            'geometry_msgs/PoseStamped', 'd3812c3cbc69362b77dc0b19b345f8f5') {
    params.add(header);
    params.add(pose);
  }
}
