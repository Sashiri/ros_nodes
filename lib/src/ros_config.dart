class RosConfig {
  final String name;
  final Uri masterUri;
  final String host;
  final int port;

  RosConfig(this.name, String masterUri, this.host, this.port) : masterUri = Uri.parse(masterUri);
}
