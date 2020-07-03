import 'package:ros_nodes/messages/UInt32.dart';
import 'package:ros_nodes/messages/Float32.dart';
import 'package:ros_nodes/messages/Time.dart';
import 'package:ros_nodes/src/ros_message.dart';

class NavMsgsMapMetaData extends RosMessage {
  var map_load_time = RosTime();
  final _resolution = RosFloat32();
  final _width = RosUint32();
  final _height = RosUint32();

  double get resolution => _resolution.val;
  set resolution(double val) => _resolution.val = val;

  int get width => _width.val;
  set width(int val) => _width.val = val;

  int get height => _height.val;
  set height(int val) => _height.val = val;

  NavMsgsMapMetaData()
      : super('MapMetaData msg definition', 'nav_msgs/MapMetaData',
            '10cfc8a2818024d3248802c00c95f11b') {
    params.add(map_load_time);
    params.add(_resolution);
    params.add(_width);
    params.add(_height);
  }
}
