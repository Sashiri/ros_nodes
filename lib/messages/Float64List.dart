import 'dart:typed_data';
import 'package:ros_nodes/src/ros_message.dart';

class RosFloat64List implements BinaryConvertable {
  Float64List list;

  RosFloat64List({Float64List list}) {
    this.list = list ?? Float64List(36);
  }

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    var size = this.list.length;
    list = Float64List.view(bytes.buffer, offset, size);
    return size;
  }

  @override
  List<int> toBytes() {
    var bytes = list.buffer.asUint8List();
    return bytes;
  }

  @override
  String toString() {
    return list.toString();
  }
}
