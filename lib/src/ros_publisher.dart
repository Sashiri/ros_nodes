import 'dart:async';
import 'dart:io';
import 'package:xmlrpc_server/xmlrpc_server.dart';
import 'package:xml_rpc/client.dart' as xml_rpc;
import 'package:xml/xml.dart';

import 'ros_message.dart';
import 'ros_node.dart';
import 'type_apis/int_apis.dart';

//TODO: RosSubscriber uses static MASTER hostname
class RosPublisher<Message extends RosMessage> {
  final String nodeName;
  final String topic;
  final Message type;
  final List<Socket> _publishSockets = <Socket>[];
  final RosNode config;

  XmlRpcServer _server;
  ServerSocket _tcpros_server;

  RosPublisher(this.nodeName, this.topic, this.type, this.config,
      {Duration publishInterval}) {
    var ip = '';

    _server = XmlRpcServer(host: InternetAddress(config.ip), port: config.port);
    _server.bind('requestTopic', onTopicRequest);
    _server.startServer();

    ServerSocket.bind(InternetAddress(config.ip), 33241).then((server) {
      _tcpros_server = server;
      server.listen((socket) {
        socket.listen((data) {
          socket.add(_tcprosHeader());
          _publishSockets.add(socket);
        });
      });
    });

    Timer.periodic(
        publishInterval ?? Duration(seconds: 1), (_) => publishData());
  }

  void publishData() {
    _publishSockets.forEach((socket) {
      var packet = <int>[];
      var data = type.toBytes();
      packet.addAll((data.length).toBytes());
      packet.addAll(data);
      socket.add(packet);
    });
  }

  List<int> _tcprosHeader() {
    var messageHeader = type.binaryHeader;
    var fullSize = messageHeader.length;

    var header = <int>[];
    header.addAll(fullSize.toBytes());
    header.addAll(messageHeader);
    return header;
  }

  Future<XmlDocument> onTopicRequest(List<dynamic> values) async {
    final requestedSettings = values[2][0];
    if (requestedSettings.contains('TCPROS')) {
      return generateXmlResponse([
        [
          1,
          'ready on ${_tcpros_server.address.address}:${_tcpros_server.port}',
          ['TCPROS', _tcpros_server.address.address, _tcpros_server.port]
        ]
      ]);
    } else {
      throw ArgumentError();
    }
  }

  void register() async {
    try {
      final result = await xml_rpc.call(config.masterUri, 'registerPublisher', [
        '/$nodeName',
        '/$topic',
        '${type.message_type}',
        'http://${_server.host}:${_server.port}/'
      ]);
    } catch (e) {
      //TODO: Error while registering
    }
  }

  void unregister() async {
    try {
      final result = await xml_rpc.call(config.masterUri, 'unregisterPublisher',
          ['/$nodeName', '/$topic', 'http://${_server.host}:${_server.port}/']);
    } catch (e) {
      //TODO: Error while registering
    }
  }
}
