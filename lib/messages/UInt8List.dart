import 'dart:typed_data';
import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/src/type_apis/int_apis.dart';

class RosUint8List implements BinaryConvertable {
  Uint8List list;
  final isFixed;

  RosUint8List({int lenght}) : isFixed = lenght ?? false {
    list = Uint8List(lenght ?? 0);
  }

  RosUint8List.fromList(this.list, {this.isFixed});

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    if (isFixed) {
      var listLength =
          ByteData.view(bytes.buffer).getUint32(offset, Endian.little);
      offset += 4;
      list =
          Uint8List.fromList(Uint8List.view(bytes.buffer, offset, listLength));
      return 4 + listLength;
    } else {
      final listLength = list.length;
      list.setAll(0, Uint8List.view(bytes.buffer, offset, listLength));
      return listLength;
    }
  }

  @override
  List<int> toBytes() {
    final listLength = list.length;

    Uint8List bytes;
    if (isFixed) {
      bytes = Uint8List(listLength);
      bytes.setRange(0, bytes.length, list);
    } else {
      bytes = Uint8List(4 + listLength);
      bytes.setRange(0, 4, listLength.toBytes());
      bytes.setRange(4, bytes.length, list);
    }
    return bytes;
  }

  @override
  String toString() {
    return list.toString();
  }
}
