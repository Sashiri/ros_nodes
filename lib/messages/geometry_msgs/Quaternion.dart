import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/messages/Float64.dart';

class GeometryMsgsQuaternion extends RosMessage {
  final RosFloat64 _x = RosFloat64();
  final RosFloat64 _y = RosFloat64();
  final RosFloat64 _z = RosFloat64();
  final RosFloat64 _w = RosFloat64();

  double get x => _x.val;
  set x(double value) {
    _x.val = value;
  }

  double get y => _y.val;
  set y(double value) {
    _y.val = value;
  }

  double get z => _z.val;
  set z(double value) {
    _z.val = value;
  }

  double get w => _w.val;
  set w(double value) {
    _w.val = value;
  }

  GeometryMsgsQuaternion()
      : super('quaternion data', 'geometry_msgs/Quaternion',
            'a779879fadf0160734f906b8c19c7004') {
    params.add(_x);
    params.add(_y);
    params.add(_z);
    params.add(_w);
  }
}
