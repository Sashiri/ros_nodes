import 'dart:async';
import 'package:xmlrpc_server/xmlrpc_server.dart';
import 'package:xml_rpc/client.dart' as xml_rpc;
import 'package:xml/xml.dart';

import 'ros_config.dart';
import 'ros_topic.dart';
import 'ros_message.dart';
import 'ros_publisher.dart';
import 'ros_subscriber.dart';
import 'protocol_info.dart';

class RosClient {
  final RosConfig config;
  XmlRpcServer _server;

  final Map<String, RosPublisher> _topicPublishers = {};
  final Map<String, RosSubscriber> _topicSubscribers = {};

  RosClient(this.config) {
    _server = XmlRpcServer(host: config.host, port: config.port);
    _server.bind('getBusStats', onGetBusStats);
    _server.bind('getBusInfo', onGetBusInfo);
    _server.bind('getMasterUri', onGetMasterUri);
    _server.bind('shutdown', onShutdown);
    _server.bind('getPid', onGetPid);
    _server.bind('getSubscriptions', onGetSubscriptions);
    _server.bind('getPublications', onGetPublications);
    _server.bind('paramUpdate', onParamUpdate);
    _server.bind('publisherUpdate', onPublisherUpdate);
    _server.bind('requestTopic', onRequestTopic);
    _server.startServer();
  }

  Future<void> close() async {
    var subcribtionsToClose = _topicSubscribers.values.map((subscriber) =>
        unsubscribe(subscriber.topic)
            .timeout(Duration(seconds: 3), onTimeout: subscriber.forceStop));

    var publishersToClose = _topicPublishers.values.map((publisher) =>
        unregister(publisher.topic)
            .timeout(Duration(seconds: 3), onTimeout: () => publisher.close()));

    await Future.wait([...subcribtionsToClose, ...publishersToClose]);
    return _server.stopServer();
  }

  Future<XmlDocument> onGetBusStats(List<dynamic> params) async {
    final callerId = params[0] as String;
    final publishStats = _topicPublishers.entries.map<List<dynamic>>(
      (e) {
        return [e.key, 0, []];
      },
    );
    final subscribeStats = [];
    final serviceStats = [0, 0, 0];

    return generateXmlResponse([
      [
        1,
        'Not implemented',
        [
          publishStats,
          subscribeStats,
          serviceStats,
        ],
      ]
    ]);
  }

  Future<XmlDocument> onGetBusInfo(List<dynamic> params) async {
    final callerId = params[0] as String;

    return generateXmlResponse([
      [
        1,
        'Not implemented',
        [],
      ]
    ]);
  }

  Future<XmlDocument> onPublisherUpdate(List<dynamic> params) async {
    final callerId = params[0] as String;
    final topic = params[1] as String;
    final publishers = List<String>.from(params[2]);

    if (!_topicSubscribers.containsKey(topic)) {
      return generateXmlResponse([
        -1,
        'No subscribers for this topic',
        1,
      ]);
    }

    var sub = _topicSubscribers[topic];
    var ignored = await sub.updatePublisherList(publishers);

    return generateXmlResponse([
      [
        1,
        'Updated subscribers',
        ignored,
      ]
    ]);
  }

  Future<XmlDocument> onParamUpdate(List<dynamic> params) async {
    final callerId = params[0] as String;
    final parameter_key = params[1] as String;
    final parameter_value = params[2];

    throw UnimplementedError();
  }

  Future<XmlDocument> onGetPublications(List<dynamic> params) async {
    final callerId = params[0] as String;

    throw UnimplementedError();
  }

  Future<XmlDocument> onGetSubscriptions(List<dynamic> params) async {
    final callerId = params[0] as String;

    throw UnimplementedError();
  }

  Future<XmlDocument> onGetPid(List<dynamic> params) async {
    final callerId = params[0] as String;

    throw UnimplementedError();
  }

  Future<XmlDocument> onShutdown(List<dynamic> params) async {
    final callerId = params[0] as String;
    final msg = params[1] as String;

    throw UnimplementedError();
  }

  Future<XmlDocument> onGetMasterUri(List<dynamic> params) async {
    final callerId = params[0] as String;

    return generateXmlResponse([
      [
        1,
        'Node is connected to ${config.masterUri}',
        config.masterUri,
      ]
    ]);
  }

  Future<XmlDocument> onRequestTopic(List<dynamic> params) async {
    final callerId = params[0] as String;
    final topic = params[1] as String;
    final protocols = List<List<dynamic>>.from(params[2])
        .map<ProtocolInfo>((x) => ProtocolInfo(
              x[0],
              x.sublist(1),
            ));

    if (!_topicPublishers.containsKey(topic)) {
      return generateXmlResponse([
        [1, 'No active publishers for topic ${topic}', []]
      ]);
    }

    final publisher = _topicPublishers[topic];

    final validProtocols = [];
    for (final protocol in protocols) {
      if (publisher.validateProtocolSettings(protocol)) {
        validProtocols.add([protocol.name, publisher.address, publisher.port]);
      }
    }

    var selectedProtocol =
        validProtocols.firstWhere((element) => true, orElse: () => null);

    return generateXmlResponse([
      [
        1,
        'ready on ${selectedProtocol[1]}:${selectedProtocol[2]}',
        selectedProtocol ?? []
      ]
    ]);
  }

  Future<RosPublisher> register(RosTopic topic,
      {int port, Duration publishInterval}) async {
    var publisher = RosPublisher(
      topic,
      config.host,
      port: port,
      publishInterval: publishInterval,
    );

    final result = await xml_rpc.call(
      config.masterUri,
      'registerPublisher',
      [
        '/${config.name}',
        '/${topic.name}',
        '${topic.msg.message_type}',
        'http://${_server.host}:${_server.port}/',
      ],
    ).catchError((err) async {
      await publisher.close();
      throw err;
    });

    final code = result[0] as int;
    final statusMessage = result[1] as String;
    final subscriberApis = List<String>.from(result[2]);

    if (code != 1) {
      await publisher.close();
      throw statusMessage;
    }

    _topicPublishers.putIfAbsent('/${topic.name}', () => publisher);
    return publisher;
  }

  Future<void> unregister(RosTopic topic) async {
    final result = await xml_rpc.call(config.masterUri, 'unregisterPublisher', [
      '/${config.name}',
      '/${topic.name}',
      'http://${_server.host}:${_server.port}/',
    ]);

    final int code = result[0];
    final String statusMessage = result[1];

    if (code == -1) {
      throw statusMessage;
    }

    final int numUnregistered = result[2];
    if (numUnregistered == 0) {
      return;
    }

    if (_topicPublishers.containsKey('/${topic.name}')) {
      await _topicPublishers['/${topic.name}'].close();
      _topicPublishers.remove('/${topic.name}');
    }
  }

  Future<RosSubscriber<Message>> subscribe<Message extends RosMessage>(
      RosTopic<Message> topic) async {
    if (_topicSubscribers.containsKey(topic.msg.message_type)) {
      return _topicSubscribers[topic.msg.message_type];
    }

    var sub = RosSubscriber<Message>(topic, config);

    final result = await xml_rpc.call(config.masterUri, 'registerSubscriber', [
      '/${config.name}',
      '/${topic.name}',
      '${topic.msg.message_type}',
      'http://${_server.host}:${_server.port}/'
    ]);

    var code = result[0] as int;
    var status = result[1] as String;

    if (code == -1) {
      throw status;
    }

    sub = _topicSubscribers.putIfAbsent(topic.msg.message_type, () => sub);
    var publishers = List<String>.from(result[2]);
    await sub.updatePublisherList(publishers);
    return sub;
  }

  Future<void> unsubscribe(RosTopic topic) async {
    final result =
        await xml_rpc.call(config.masterUri, 'unregisterSubscriber', [
      '/${config.name}',
      '/${topic.name}',
      'http://${_server.host}:${_server.port}/',
    ]);

    var code = result[0] as int;
    var status = result[1] as String;

    if (code == -1) {
      throw status;
    }

    var numUnsubscribed = result[2] as int;
    if (numUnsubscribed > 0) {
      _topicPublishers.removeWhere((key, _) => key == topic.msg.message_type);
    }
  }
}
