import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/messages/String.dart';
import 'package:ros_nodes/messages/std_msgs/Header.dart';
import 'Transform.dart';

class GeometryMsgsTransformStamped extends RosMessage {
  final StdMsgsHeader header = StdMsgsHeader();
  final RosString _child_frame_id = RosString();
  final GeometryMsgsTransform transform = GeometryMsgsTransform();

  String get child_frame_id => _child_frame_id.val;
  set child_frame_id(value) {
    _child_frame_id.val = value;
  }

  GeometryMsgsTransformStamped()
      : super('transform stamped data', 'geometry_msgs/TransformStamped',
            'b5764a33bfeb3588febc2682852579b0') {
    params.add(header);
    params.add(_child_frame_id);
    params.add(transform);
  }
}
