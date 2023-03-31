import '../ArduinoNetwork/message.dart';
import '../ArduinoNetwork/network_entity.dart';
import '../ArduinoNetwork/network_manager.dart';

class GVSUpdateRecord {
  int index;
  double value;

  GVSUpdateRecord(this.index, this.value);
}

class GVSUpdateRecordData extends PairMessage<MessageUint16, MessageFloat32> {
  GVSUpdateRecordData(MessageUint16 first, MessageFloat32 second)
      : super(first, second);
}

class GvsUpdate extends NetworkMessage<ListMessage> {
  GvsUpdate()
      : super(
            MessageHeader(
              protocol: NetworkManager.protocol,
              source: GlobalValueStore.globalValueStoreIp,
              destination: GlobalValueStore.globalValueStoreIp,
              messageType: const MessageType(
                GlobalValueStore.messagePrimaryType,
                GlobalValueStore.updateMessageSecondaryType,
              ),
            ),
            ListMessage(
              (int size) => List.filled(size,
                  GVSUpdateRecordData(MessageUint16(0), MessageFloat32(0))),
            ));
}

class GlobalValueStore extends NetworkEntity {
  static const int numberOfFloats32 = 256;
  static int updateTime = 0;
  static int lastUpdate = 0;

  static const int messagePrimaryType = 2;
  static const int updateMessageSecondaryType = 1;

  static const IP globalValueStoreIp = IP(2);

  static List<double> floats32 = List.filled(numberOfFloats32, 0.0);

  static Set<int> changedIds = {};

  void sendUpdate() {
    // No need to implement, the phone isn't supposed to send gvs updates
  }

  void handleUpdate(GvsUpdate msg) {
    for (var element in msg.second.data) {
      var record = (element as GVSUpdateRecordData);
      set(record.first.value, record.second.value);
    }
  }

  GlobalValueStore(int updateTime) {
    // ignore: prefer_initializing_formals
    GlobalValueStore.updateTime = updateTime;
  }

  static void set(int index, double value) {
    if (floats32[index] == value) {
      return;
    }
    floats32[index] = value;
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (header.messageType ==
        const MessageType(messagePrimaryType, updateMessageSecondaryType)) {
      GvsUpdate update = GvsUpdate();
      update.build(buffer);
      handleUpdate(update);
    }
  }

  @override
  void handle() {
    // The phone isn't supposed to send update messages, so this doesn't need to be implemented
  }
}
