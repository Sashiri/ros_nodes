import 'dart:typed_data';

import 'NativeList.dart';

class RosFloat32List extends NativeList<Float32List> {
  RosFloat32List({int? fixedLength}) : super(fixedLength: fixedLength) {
    list = Float32List(fixedLength ?? 0);
  }

  @override
  RosFloat32List.fromList(Float32List list, {bool isFixedLength = true})
      : super.fromList(list, isFixedLength: isFixedLength);

  @override
  Float32List convertFromBuffer(ByteBuffer buffer) {
    return buffer.asFloat32List();
  }
}
