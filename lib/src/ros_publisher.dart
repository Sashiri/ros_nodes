import 'dart:async';
import 'dart:io';
import 'package:ros_nodes/src/protocol_info.dart';
import 'package:ros_nodes/src/ros_topic.dart';
import 'type_apis/int_apis.dart';

class RosPublisher {
  final List<Socket> _subscribers = <Socket>[];
  final RosTopic topic;
  ServerSocket? _tcprosServer;
  Timer? _publishTimer;

  Duration _publishInterval;
  Duration get publishInterval => _publishInterval;

  ///Changing publishing interval stops publishing
  set publishInterval(Duration value) {
    _publishInterval = value;
    _publishTimer?.cancel();
    stopPublishing();
  }

  int? get port => _tcprosServer?.port;

  String? get address => _tcprosServer?.address.address;

  ///If [port] is ommited, it will be selected at random by ServerSocket.bind
  ///You can disable automatic start of publishing data by passing false to [publish]
  RosPublisher(this.topic, dynamic host,
      {int? port, Duration? publishInterval, bool publish = true})
      : assert(
            host.runtimeType == String || host.runtimeType == InternetAddress),
        _publishInterval = publishInterval ?? Duration(seconds: 1) {
    if (publish) {
      startPublishing();
    }

    port ??= 0;

    ServerSocket.bind(host, port).then((server) {
      _tcprosServer = server;
      server.listen((socket) {
        socket.listen(
          (data) {
            socket.add(_tcprosHeader());
            _subscribers.add(socket);
          },
          onDone: () => _subscribers.remove(socket),
        );
      });
    });
  }

  void startPublishing() {
    _publishTimer ??=
        Timer.periodic(publishInterval, (_) async => await publishData());
  }

  void stopPublishing() {
    var timer = _publishTimer;
    if (timer != null) {
      timer.cancel();
    }
  }

  Future<void> close() async {
    stopPublishing();
    await Future.wait(_subscribers.map((subscriber) => subscriber.close()));
    var server = _tcprosServer;
    if (server != null) {
      await server.close();
      _tcprosServer = null;
    }
  }

  Future<void> publishData() async {
    for (var subscriber in _subscribers) {
      var packet = <int>[];
      var data = topic.msg.toBytes();
      packet.addAll((data.length).toBytes());
      packet.addAll(data);
      try {
        subscriber.add(packet);
        await subscriber.flush();
      } catch (err) {
        print(err);
      }
    }
    ;
  }

  List<int> _tcprosHeader() {
    var messageHeader = topic.msg.binaryHeader;
    var fullSize = messageHeader.length;

    var header = <int>[];
    header.addAll(fullSize.toBytes());
    header.addAll(messageHeader);
    return header;
  }

  bool validateProtocolSettings(ProtocolInfo protocolInfo) {
    switch (protocolInfo.name) {
      case 'TCPROS':
        return true;
    }
    return false;
  }
}
