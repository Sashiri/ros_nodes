import 'dart:typed_data';

import 'package:ros_nodes/src/ros_message.dart';

import '../Float64List.dart';
import '../String.dart';
import 'Twist.dart';

class GeometryMsgsTwistWithCovariance extends RosMessage {
  final twist = GeometryMsgsTwist();
  final _covariance = RosFloat64List(fixedLength: 36);
  Float64List get covariance => _covariance.list;

  GeometryMsgsTwistWithCovariance()
      : super(
            'This expresses velocity in free space with uncertainty.',
            'geometry_msgs/TwistWithCovariance',
            '1fe8a28e6890a4cc3ae4c3ca5c7d82e6') {
    params.add(twist);
    params.add(_covariance);
  }
}
