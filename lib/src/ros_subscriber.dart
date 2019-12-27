import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:xmlrpc_server/xmlrpc_server.dart';
import 'package:xml_rpc/client.dart' as xml_rpc;
import 'package:xml/xml.dart';

import 'ros_message.dart';
import 'type_apis/int_apis.dart';

//TODO: RosSubscriber uses static MASTER hostname
class RosSubscriber<Message extends RosMessage> {
  final String nodeName;
  final String topic;
  final Message type;
  final Map<String, Socket> _tcprosConnections = {};

  Stream<Message> onValueUpdate;
  StreamController<Message> valueUpdate;
  XmlRpcServer _server;

  RosSubscriber(this.nodeName, this.topic, this.type) {
    _server = XmlRpcServer();
    _server.bind('publisherUpdate', onPublisherUpdate);
    _server.startServer();

    valueUpdate = StreamController<Message>();
    onValueUpdate = valueUpdate.stream.asBroadcastStream();
  }

  List<int> _tcprosHeader() {
    final callerId = 'callerid=/$nodeName';
    final tcpNoDelay = 'tcp_nodelay=0';
    final topic = 'topic=/${this.topic}';

    var messageHeader = type.binaryHeader;
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

  Future<XmlDocument> onPublisherUpdate(List<dynamic> values) async {
    //TODO: values[0] is name of the node calling api
    //TODO: values[0] is operation result if called master

    _tcprosConnections.removeWhere((apiAddress, connection) {
      final remove = !(values[2] as List).contains(apiAddress);
      if (remove) {
        connection.close();
      }
      return remove;
    });

    for (var connection in values[2]) {
      final response = await xml_rpc.call(connection, 'requestTopic', [
        '/$nodeName',
        '/$topic',
        [
          ['TCPROS']
        ]
      ]);

      var connectionValues = response[2];
      if (!_tcprosConnections.keys.contains(connection)) {
        var socket =
            await Socket.connect(connectionValues[1], connectionValues[2]);

        socket.add(_tcprosHeader());

        var done = false;

        socket.listen((data) {
          if (!done) {
            done = true;
            return;
          }
          type.fromBytes(data, offset: 4);
          valueUpdate.add(type);
        });

        _tcprosConnections.putIfAbsent(connection, () => socket);
      }
    }
    return generateXmlResponse([1]);
  }

  void subscribe() async {
    try {
      final result = await xml_rpc
          .call('http://DESKTOP-L2R4GKN:11311/', 'registerSubscriber', [
        '/$nodeName',
        '/$topic',
        '${type.message_type}',
        'http://${_server.host}:${_server.port}/'
      ]);
      await onPublisherUpdate(result);
    } catch (e) {
      //TODO: Error while registering
    }
  }

  void unsubscribe() async {
    try {
      final result = await xml_rpc.call(
          'http://DESKTOP-L2R4GKN:11311',
          'unregisterSubscriber',
          ['/$nodeName', '/$topic', 'http://${_server.host}:${_server.port}/']);
    } catch (e) {
      //TODO: Error while registering
    }
  }
}
