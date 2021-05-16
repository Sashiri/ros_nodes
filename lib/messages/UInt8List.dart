import 'dart:typed_data';

import 'NativeList.dart';

class RosUint8List extends NativeList<Uint8List> {
  RosUint8List({int? fixedLength}) : super(fixedLength: fixedLength) {
    list = Uint8List(fixedLength ?? 0);
  }

  @override
  RosUint8List.fromList(Uint8List list, {bool isFixedLength = true})
      : super.fromList(list, isFixedLength: isFixedLength);

  @override
  Uint8List convertFromBuffer(ByteBuffer buffer) {
    return buffer.asUint8List();
  }
}
