import 'dart:convert';
import 'dart:typed_data';
import 'package:ros_nodes/src/ros_message.dart';

class RosString implements BinaryConvertable {
  String val;

  RosString({String value}) {
    val = value ?? '';
  }

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    var size = ByteData.view(bytes.buffer).getUint32(offset, Endian.little);
    offset += 4;
    val = utf8.decode(bytes.sublist(offset, offset + size));
    return 4 + size;
  }

  @override
  List<int> toBytes() {
    return utf8.encode(val);
  }

  @override
  String toString() {
    return val;
  }
}
