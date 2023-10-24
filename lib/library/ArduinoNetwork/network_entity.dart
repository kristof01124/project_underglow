import 'message.dart';

abstract class NetworkEntity {
  IP getIp();

  void handleMessage(List<int> buffer, NetworkEntity src);
  void handle() {}
  void initialize() {}
}
