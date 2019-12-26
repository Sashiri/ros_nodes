import 'dart:async';
import 'dart:io';
import 'ros_message.dart';
import 'package:xmlrpc_server/xmlrpc_server.dart';
import 'package:xml_rpc/client.dart' as xml_rpc;
import 'package:xml/xml.dart' as xml;
import 'package:ros_nodes/src/type_apis/int_apis.dart';

//TODO: RosSubscriber uses static MASTER hostname
class RosPublisher<MessageType extends RosMessage> {
  String _nodeName;
  String _topic;
  MessageType _type;
  XmlRpcServer _server;
  ServerSocket _tcpros_server;
  final List<Socket> _publishSockets = <Socket>[];

  String get topic => _topic;
  MessageType get topicType => _type;

  RosPublisher(String nodeName, String topic, MessageType topicType,
      {Duration publishInterval}) {
    _nodeName = nodeName;
    _topic = topic;
    _type = topicType;

    var ip = '';

    _server = XmlRpcServer(host: InternetAddress.anyIPv4, port: 54231);
    _server.bind('requestTopic', onTopicRequest);
    _server.bind('publisherUpdate', (_) async {
      return generateXmlResponse([1]);
    });
    _server.startServer();

    ServerSocket.bind(InternetAddress.loopbackIPv4, 33241).then((server) {
      _tcpros_server = server;
      server.listen((socket) {
        socket.listen((data) {
          socket.add(_tcpros_header());
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
      var data = topicType.toBytes();
      packet.addAll((data.length).toBytes());
      packet.addAll(data);
      socket.add(packet);
    });
  }

  List<int> _tcpros_header() {
    var messageHeader = _type.binaryHeader;

    var header = <int>[];
    header.addAll(messageHeader.length.toBytes());
    header.addAll(messageHeader);
    return header;
  }

  Future<xml.XmlDocument> onTopicRequest(List<dynamic> values) async {
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
      final result = await xml_rpc
          .call('http://DESKTOP-L2R4GKN:11311/', 'registerPublisher', [
        '/$_nodeName',
        '/$_topic',
        '${_type.message_type}',
        'http://${_server.host}:${_server.port}/'
      ]);
      print(result);
    } catch (e) {
      print(e);
    }
  }

  void unregister() async {
    try {
      final result = await xml_rpc.call(
          'http://DESKTOP-L2R4GKN:11311', 'unregisterPublisher', [
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
