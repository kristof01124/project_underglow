import 'message.dart';

abstract class NetworkEntity {
  IP ip = const IP(0);
  bool shouldBeAdvertised = false;

  IP getIp() {
    return ip;
  }

  bool advertised() {
    return shouldBeAdvertised;
  }

  void handleMessage(List<int> buffer, NetworkEntity src);
  void handle();
  void initialize() {}

  NetworkEntity({this.ip = const IP(0)});
}
