import 'package:ros_nodes/messages/geometry_msgs/Point.dart';
import 'package:ros_nodes/messages/geometry_msgs/Quaternion.dart';
import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/messages/Float64.dart';

class GeometryMsgsPose extends RosMessage {
  var position = GeometryMsgsPoint();
  var orientation = GeometryMsgsQuaternion();

  GeometryMsgsPose()
      : super('pose data', 'geometry_msgs/Pose',
            'e45d45a5a1ce597b249e23fb30fc871f') {
    params.add(position);
    params.add(orientation);
  }
}
