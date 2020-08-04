import 'dart:typed_data';
import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/src/type_apis/int_apis.dart';

class RosUint8List implements BinaryConvertable {
  Uint8List list;
  final int fixedLength;

  RosUint8List({this.fixedLength}) {
    list = Uint8List(fixedLength ?? 0);
  }

  RosUint8List.fromList(this.list, {this.fixedLength});

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    var size;
    var data;
    if (fixedLength == null) {
      size = ByteData.view(bytes.buffer).getUint32(offset, Endian.little);
      data = size + 4;
    } else {
      size = list.length;
      data = size;
    }
    list = Uint8List.view(bytes.buffer, offset, size);
    return data;
  }

  @override
  List<int> toBytes() {
    final listLength = list.length;

    Uint8List bytes;
    if (fixedLength == null) {
      bytes = Uint8List(4 + listLength);
      bytes.setRange(0, 4, listLength.toBytes());
      bytes.setRange(4, bytes.length, list);
    } else {
      bytes = list.buffer.asUint8List();
    }
    return bytes;
  }

  @override
  String toString() {
    return list.toString();
  }
}
