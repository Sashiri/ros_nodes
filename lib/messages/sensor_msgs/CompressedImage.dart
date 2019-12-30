import 'dart:typed_data';

import 'package:ros_nodes/messages/UInt8List.dart';
import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/messages/String.dart';
import 'package:ros_nodes/messages/std_msgs/Header.dart';

class SensorMsgsCompressedImage extends RosMessage {
  final StdMsgsHeader header = StdMsgsHeader();
  final RosString _format = RosString();
  final RosUint8List _data = RosUint8List();

  String get format => _format.val;
  set format(String value) {
    _format.val = value;
  }

  Uint8List get data => _data.list;
  set frame_id(Uint8List value) {
    _data.list = value;
  }

  SensorMsgsCompressedImage()
      : super('compressed image data', 'sensor_msgs/CompressedImage',
            '8f7a12909da2c9d3332d540a0977563f') {
    params.add(header);
    params.add(_format);
    params.add(_data);
  }
}
