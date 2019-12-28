import 'package:ros_nodes/messages/geometry_msgs/TransformStamped.dart';
import 'package:ros_nodes/messages/List.dart';
import 'package:ros_nodes/src/ros_message.dart';

class TfTfMessage extends RosMessage {
  final RosList<GeometryMsgsTransformStamped> _transforms =
      RosList<GeometryMsgsTransformStamped>(
          () => GeometryMsgsTransformStamped());

  List<GeometryMsgsTransformStamped> get transforms => _transforms.list;

  TfTfMessage()
      : super('transform stamped data', 'tf/tfMessage',
            '94810edda583a504dfda3829e70d7eec') {
    params.add(_transforms);
  }
}
