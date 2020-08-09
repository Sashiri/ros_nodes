import 'dart:convert';
import 'dart:typed_data';
import 'type_apis/int_apis.dart';

abstract class BinaryConvertable {
  List<int> toBytes();
  int fromBytes(Uint8List bytes, {int offset = 0});
}

abstract class RosMessage implements BinaryConvertable {
  final String message_definition;
  final String message_type;
  final String type_md5;
  final List<int> binaryHeader;

  List<BinaryConvertable> params = [];

  RosMessage(this.message_definition, this.message_type, this.type_md5)
      : binaryHeader =
            _calculateHeader(message_definition, message_type, type_md5);

  static List<int> _calculateHeader(
      String message_definition, String message_type, String type_md5) {
    var header_message_definition = 'message_definition=$message_definition';
    var header_message_type = 'type=$message_type';
    var header_type_md5 = 'md5sum=$type_md5';

    var bytes = <int>[];
    bytes.addAll(header_message_definition.length.toBytes());
    bytes.addAll(utf8.encode(header_message_definition));
    bytes.addAll(header_message_type.length.toBytes());
    bytes.addAll(utf8.encode(header_message_type));
    bytes.addAll(header_type_md5.length.toBytes());
    bytes.addAll(utf8.encode(header_type_md5));
    return bytes;
  }

  @override
  List<int> toBytes() {
    var bytes = <int>[];
    for (var param in params) {
      var paramBytes = param.toBytes();
      bytes.addAll(paramBytes);
    }
    return bytes;
  }

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    var size = 0;
    for (var param in params) {
      size += param.fromBytes(bytes, offset: offset + size);
    }
    return size;
  }
}
