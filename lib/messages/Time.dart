import 'dart:typed_data';
import 'package:ros_nodes/src/ros_message.dart';

class RosTime implements BinaryConvertable {
  int sec;
  int nsec;

  RosTime({int? sec, int? nsec})
      : sec = sec ?? 0,
        nsec = nsec ?? 0;

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    sec = ByteData.view(bytes.buffer).getInt32(offset, Endian.little);
    nsec = ByteData.view(bytes.buffer).getInt32(offset + 4, Endian.little);
    return 8;
  }

  @override
  List<int> toBytes() {
    var bytes = Uint8List(8);
    ByteData.view(bytes.buffer).setUint32(0, sec, Endian.little);
    ByteData.view(bytes.buffer).setUint32(4, nsec, Endian.little);
    return bytes;
  }

  @override
  String toString() {
    return '$sec:$nsec';
  }
}
