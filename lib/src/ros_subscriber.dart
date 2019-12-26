import 'dart:convert';
import 'dart:io';
import 'package:xmlrpc_server/xmlrpc_server.dart';
import 'package:xml_rpc/client.dart' as xml_rpc;
import 'package:xml/xml.dart';

import 'type_apis/int_apis.dart';
import 'ros_message.dart';

//TODO: RosSubscriber uses static MASTER hostname
class RosSubscriber<MessageType extends RosMessage> {
  String _nodeName;
  String _topic;
  MessageType _type;
  XmlRpcServer _server;
  final Map<String, Socket> _tcprosConnections = {};
  Function onValueUpdate;

  String get topic => _topic;
  MessageType get topicType => _type;

  RosSubscriber(String nodeName, String topic, MessageType topicType) {
    _nodeName = nodeName;
    _topic = topic;
    _type = topicType;

    _server = XmlRpcServer(host: InternetAddress.anyIPv4, port: 21451);
    _server.bind('publisherUpdate', onPublisherUpdate);
    _server.startServer();
  }

  List<int> _tcpros_header() {
    final callerId = 'callerid=/$_nodeName';
    final tcpNoDelay = 'tcp_nodelay=0';
    final topic = 'topic=/$_topic';

    var messageHeader = _type.binaryHeader;

    var header = <int>[];
    header.addAll((messageHeader.length +
            4 +
            callerId.length +
            4 +
            topic.length +
            4 +
            tcpNoDelay.length)
        .toBytes());
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

    _tcprosConnections.removeWhere((x, connection) {
      final remove = !(values[2] as List).contains(x);
      if (remove) {
        connection.close();
      }
      return remove;
    });

    for (var connection in values[2]) {
      final response = await xml_rpc.call(connection, 'requestTopic', [
        '/$_nodeName',
        '/$_topic',
        [
          ['TCPROS']
        ]
      ]);

      var connectionValues = response[2];
      if (!_tcprosConnections.keys.contains(connection)) {
        var socket =
            await Socket.connect(connectionValues[1], connectionValues[2]);

        socket.add(_tcpros_header());

        var done = false;

        socket.listen((data) {
          if (!done) {
            done = true;
            return;
          }
          topicType.fromBytes(data, offset: 4);
          if (onValueUpdate != null) onValueUpdate();
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
        '/$_nodeName',
        '/$_topic',
        '${_type.message_type}',
        'http://${_server.host}:${_server.port}/'
      ]);
      await onPublisherUpdate(result);
      print(result);
    } catch (e) {
      print(e);
    }
  }

  void unsubscribe() async {
    try {
      final result = await xml_rpc.call(
          'http://DESKTOP-L2R4GKN:11311', 'unregisterSubscriber', [
        '/$_nodeName',
        '/$_topic',
        'http://${_server.host}:${_server.port}/'
      ]);
      print(result);
    } catch (e) {
      print(e);
    }
  }
}
