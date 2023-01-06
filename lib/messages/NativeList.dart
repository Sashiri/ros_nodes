import 'dart:typed_data';

import 'package:ros_nodes/src/ros_message.dart';
import 'package:ros_nodes/src/type_apis/int_apis.dart';

abstract class NativeList<T extends TypedData> implements BinaryConvertable {
  late T list;
  final int? fixedLength;

  NativeList({this.fixedLength});

  NativeList.fromList(this.list, {bool isFixedLength = true})
      : fixedLength = isFixedLength
            ? list.buffer.lengthInBytes ~/ list.elementSizeInBytes
            : null;

  T convertFromBuffer(ByteBuffer buffer);

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    int sizeInBytes;
    int bytesUsed;
    final _len = fixedLength;
    if (_len == null) {
      sizeInBytes = bytes.buffer.asByteData().getUint32(offset, Endian.little) *
          list.elementSizeInBytes;
      bytesUsed = sizeInBytes + 4;
      offset += 4;
    } else {
      sizeInBytes = _len * list.elementSizeInBytes;
      bytesUsed = sizeInBytes;
    }
    list =
        convertFromBuffer(bytes.sublist(offset, offset + sizeInBytes).buffer);
    return bytesUsed;
  }

  @override
  List<int> toBytes() {
    Uint8List bytes;
    if (fixedLength == null) {
      final listLength = list.lengthInBytes;
      bytes = Uint8List(4 + listLength);
      bytes.setRange(0, 4, listLength.toBytes());
      bytes.setRange(4, bytes.length, list.buffer.asUint8List());
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
