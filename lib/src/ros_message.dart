import 'dart:convert';
import 'dart:typed_data';
import 'package:ros_nodes/src/type_apis/int_apis.dart';

abstract class BinaryConvertable {
  List<int> toBytes();
  int fromBytes(Uint8List bytes, {int offset = 0});
}

abstract class RosMessage implements BinaryConvertable {
  String _message_definition;
  String _message_type;
  String _type_md5;

  String get message_definition => _message_definition;
  String get message_type => _message_type;
  String get type_md5 => _type_md5;

  List<int> get binaryHeader {
    var message_definition = 'message_definition=$_message_definition';
    var message_type = 'type=$_message_type';
    var type_md5 = 'md5sum=$_type_md5';

    var bytes = <int>[];
    bytes.addAll(message_definition.length.toBytes());
    bytes.addAll(utf8.encode(message_definition));
    bytes.addAll(message_type.length.toBytes());
    bytes.addAll(utf8.encode(message_type));
    bytes.addAll(type_md5.length.toBytes());
    bytes.addAll(utf8.encode(type_md5));
    return bytes;
  }

  List<BinaryConvertable> params = [];

  RosMessage(String message_definition, String message_type, String type_md5) {
    _message_definition = message_definition;
    _message_type = message_type;
    _type_md5 = type_md5;
  }

  @override
  List<int> toBytes() {
    var bytes = <int>[];
    params.forEach((param) {
      var paramBytes = param.toBytes();
      bytes.addAll(paramBytes);
    });
    return bytes;
  }

  @override
  int fromBytes(Uint8List bytes, {int offset = 0}) {
    var size = 0;
    params.forEach((param) {
      size += param.fromBytes(bytes, offset: offset + size);
    });
    return size;
  }
}
