import 'dart:typed_data';
import 'package:ros_nodes/src/type_apis/int_apis.dart';
import 'package:ros_nodes/src/ros_message.dart';

class RosList<T extends BinaryConvertable> implements BinaryConvertable {
  List<T> list;
  T Function() _factoryMethod;

  RosList(T Function() factoryMethod, {List<T> list}) {
    _factoryMethod = factoryMethod;
    this.list = list ?? <T>[];
  }

  //TODO: Possible data race condition
  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    var size = ByteData.view(bytes.buffer).getUint32(offset, Endian.little);
    var list = List<T>(size);
    var index = 4;
    for (var i = 0; i < size; ++i) {
      var value = _factoryMethod();
      index += value.fromBytes(bytes, offset: offset + index);
      list.add(value);
    }
    this.list = list;
    return 4 + size;
  }

  @override
  List<int> toBytes() {
    var bytes = <int>[];
    bytes.addAll(list.length.toBytes());
    list.forEach((element) {
      var result = element.toBytes();
      bytes.addAll(result);
    });
    return bytes;
  }

  @override
  String toString() {
    return list.toString();
  }
}
