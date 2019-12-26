import 'package:ros_nodes/src/ros_message.dart';
import 'Vector3.dart';
import 'Quaternion.dart';

class GeometryMsgsTransform extends RosMessage {
  final GeometryMsgsVector3 translation = GeometryMsgsVector3();
  final GeometryMsgsQuaternion rotation = GeometryMsgsQuaternion();

  GeometryMsgsTransform()
      : super('transform data', 'geometry_msgs/Transform',
            'ac9eff44abf714214112b05d54a3cf9b') {
    params.add(translation);
    params.add(rotation);
  }
}
