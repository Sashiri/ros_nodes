import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ros_nodes/ros_nodes.dart';
import 'package:ros_nodes/src/protocol_info.dart';
import 'package:xml_rpc/client.dart' as xml_rpc;

import 'type_apis/int_apis.dart';
import 'ros_config.dart';

class TcpHandShake {
  int size;
  List<String> headers;

  TcpHandShake(this.size, this.headers);
}

TcpHandShake decodeHeader(Uint8List header) {
  var data = ByteData.view(header.buffer);
  var size = data.getUint32(0, Endian.little);
  var index = 4;
  var decodedHeader = <String>[];
  while (index < size) {
    var size = data.getUint32(index, Endian.little);
    index += 4;
    var param = utf8.decode(header.sublist(index, index + size));
    decodedHeader.add(param);
    index += size;
  }
  return TcpHandShake(index, decodedHeader);
}

extension IterableExtension<T> on Iterable<T> {
  T firstOrNull() {
    return firstWhere((_) => false, orElse: () => null);
  }
}

class RosSubscriber<Message extends RosMessage> {
  final Map<String, Socket> _connections = {};
  StreamController<Message> _valueUpdate;
  RosConfig config;

  final RosTopic<Message> topic;
  Stream<Message> onValueUpdate;

  RosSubscriber(this.topic, this.config) {
    _valueUpdate = StreamController<Message>();
    onValueUpdate = _valueUpdate.stream.asBroadcastStream();
  }

  List<int> _tcprosHeader() {
    final callerId = 'callerid=/${config.name}';
    final tcpNoDelay = 'tcp_nodelay=0';
    final topic = 'topic=/${this.topic.name}';

    var messageHeader = this.topic.msg.binaryHeader;
    var fullSize = messageHeader.length +
        4 +
        callerId.length +
        4 +
        topic.length +
        4 +
        tcpNoDelay.length;

    var header = <int>[];
    header.addAll(fullSize.toBytes());
    header.addAll(messageHeader);
    header.addAll(callerId.length.toBytes());
    header.addAll(utf8.encode(callerId));
    header.addAll(tcpNoDelay.length.toBytes());
    header.addAll(utf8.encode(tcpNoDelay));
    header.addAll(topic.length.toBytes());
    header.addAll(utf8.encode(topic));
    return header;
  }

  Future<Socket> establishTCPROSConnection(ProtocolInfo protocolInfo) async {
    var socket =
        await Socket.connect(protocolInfo.params[0], protocolInfo.params[1]);

    socket.add(_tcprosHeader());
    var broadcast = socket.asBroadcastStream();

    //Message data
    var buffor = BytesBuilder();
    var recived = 0;
    var size = 0;

    //TCPROS Connection loop
    void loop(Uint8List data) {
      recived += data.length;
      buffor.add(data);

      while (true) {
        if (size == 0 && recived >= 4) {
          size = ByteData.view(buffor.toBytes().buffer, 0, 4)
                  .getUint32(0, Endian.little) +
              4;
        }
        if (recived < size || size == 0) {
          break;
        }

        var msgData = buffor.takeBytes();
        buffor.add(msgData.sublist(size));
        msgData = msgData.sublist(0, size);
        var usedbytes = topic.msg.fromBytes(msgData, offset: 4);

        assert(usedbytes == size - 4);

        _valueUpdate.add(topic.msg);
        recived -= size;
        size = 0;
      }
    }

    //Handshake only
    broadcast.take(1).listen((data) {
      var handshake = decodeHeader(data);
      var md5sum = handshake.headers
          .where((header) => header.contains('md5sum='))
          .first
          .substring(7);
      var type = handshake.headers
          .where((header) => header.contains('type='))
          .first
          .substring(5);

      assert(md5sum == topic.msg.type_md5);
      assert(type == topic.msg.message_type);

      var callerid = handshake.headers
          .where((header) => header.contains('callerid='))
          .firstOrNull();
      var latching = handshake.headers
          .where((header) => header.contains('latching='))
          .firstOrNull();

      loop(data.sublist(handshake.size));
    });

    //Data stream
    broadcast.skip(1).listen(loop);

    return socket;
  }

  Future<bool> updatePublisherList(List<String> publishers) async {
    _connections.removeWhere((apiAddress, connection) {
      final connected = !publishers.contains(apiAddress);
      if (!connected) {
        connection.close();
      }
      return connected == false;
    });

    for (var connection in publishers) {
      final response = await xml_rpc.call(connection, 'requestTopic', [
        '/${config.name}',
        '/${topic.name}',
        [
          ['TCPROS']
        ]
      ]);

      if ((response[2] as List<dynamic>).isEmpty) {
        continue;
      }

      final code = response[0] as int;
      final status = response[1] as String;
      final protocol = ProtocolInfo(
          response[2][0], (response[2] as List<dynamic>).sublist(1));

      Socket socket;
      switch (protocol.name) {
        case 'TCPROS':
          socket = await establishTCPROSConnection(protocol);
          break;
      }

      assert(socket != null);

      _connections.putIfAbsent(connection, () => socket);
    }
    return true;
  }

  Future<void> forceStop() {
    return Future.wait(_connections.values.map((e) async {
      await e.flush();
      return e.close();
    }));
  }
}
