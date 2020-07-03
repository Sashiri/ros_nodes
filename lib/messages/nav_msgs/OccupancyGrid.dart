import 'dart:typed_data';
import 'package:ros_nodes/messages/Int8List.dart';
import 'package:ros_nodes/messages/nav_msgs/MapMetaData.dart';
import 'package:ros_nodes/messages/std_msgs/Header.dart';
import 'package:ros_nodes/src/ros_message.dart';

class NavMsgsOccupancyGrid extends RosMessage {
  var header = StdMsgsHeader();
  var info = NavMsgsMapMetaData();
  final _data = RosInt8List();

  Int8List get data => _data.list;
  set data(Int8List list) => _data.list = list;

  NavMsgsOccupancyGrid()
      : super('OccupancyGrid msg definition', 'nav_msgs/OccupancyGrid',
            '3381f2d731d4076ec5c71b0759edbe4e') {
    params.add(header);
    params.add(info);
    params.add(_data);
  }
}
