import 'dart:typed_data';

extension IntToBinaryExtension on int {
  Uint8List toBytes({Endian endian = Endian.little}) {
    var space = Uint8List(4);
    ByteData.view(space.buffer).setUint32(0, this, endian);
    return space;
  }
}
