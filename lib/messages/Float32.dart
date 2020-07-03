import 'dart:typed_data';
import 'package:ros_nodes/src/ros_message.dart';

class RosFloat32 implements BinaryConvertable {
  double val;

  RosFloat32({double value}) {
    val = value ?? 0;
  }

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    val = ByteData.view(bytes.buffer).getFloat32(offset, Endian.little);
    return 4;
  }

  @override
  List<int> toBytes() {
    var bytes = Uint8List(4);
    ByteData.view(bytes.buffer).setFloat32(0, val, Endian.little);
    return bytes;
  }

  @override
  String toString() {
    return val.toString();
  }
}
