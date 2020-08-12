import 'package:ros_nodes/messages/geometry_msgs/TwistWithCovariance.dart';
import '../../ros_nodes.dart';
import '../String.dart';
import '../geometry_msgs/PoseWithCovariance.dart';
import '../std_msgs/Header.dart';

class NavMsgsOdometry extends RosMessage {
  final header = StdMsgsHeader();
  final _child_frame_id = RosString();
  String get child_frame_id => _child_frame_id.val;
  set child_frame_id(String val) => _child_frame_id.val = val;
  final pose = PoseWithCovariance();
  final twist = GeometryMsgsTwistWithCovariance();

  NavMsgsOdometry()
      : super(
            'This represents an estimate of a position and velocity in free space.',
            'nav_msgs/Odometry',
            'cd5e73d190d741a2f92e81eda573aca7') {
    params.add(header);
    params.add(_child_frame_id);
    params.add(pose);
    params.add(twist);
  }
}
