import 'package:ros_nodes/src/ros_message.dart';
import 'Vector3.dart';

class GeometryMsgsTwist extends RosMessage {
  final GeometryMsgsVector3 linear = GeometryMsgsVector3();
  final GeometryMsgsVector3 angular = GeometryMsgsVector3();

  GeometryMsgsTwist()
      : super('vector data', 'geometry_msgs/Twist',
            '9f195f881246fdfa2798d1d3eebca84a') {
    params.add(linear);
    params.add(angular);
  }
}
