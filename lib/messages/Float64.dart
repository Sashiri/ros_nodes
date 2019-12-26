import 'dart:typed_data';
import 'package:ros_nodes/src/ros_message.dart';

class RosFloat64 implements BinaryConvertable {
  double val;

  RosFloat64({double value}) {
    val = value ?? 0;
  }

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    val = ByteData.view(bytes.buffer).getFloat64(offset, Endian.little);
    return 8;
  }

  @override
  List<int> toBytes() {
    var bytes = Uint8List(8);
    ByteData.view(bytes.buffer).setFloat64(0, val, Endian.little);
    return bytes;
  }

  @override
  String toString() {
    return val.toString();
  }
}
