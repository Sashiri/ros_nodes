import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/messages/geometry_msgs/Pose.dart';
import 'package:ros_nodes/messages/Float64List.dart';

class PoseWithCovariance extends RosMessage {
  var pose = GeometryMsgsPose();
  var covariance = RosFloat64List();

  PoseWithCovariance()
      : super(
            'pose in free space with uncertainty',
            'geometry_msgs/PoseWithCovariance',
            'c23e848cf1b7533a8d7c259073a97e6f') {
    params.add(pose);
    params.add(covariance);
  }
}
