import 'message.dart';

abstract class NetworkEntity {
  void handleMessage(List<int> buffer, NetworkEntity src);
  void handle() {}
  void initialize() {}
}
