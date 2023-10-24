import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';

import '../ArduinoNetwork/message.dart';
import '../ArduinoNetwork/network_entity.dart';
import '../ArduinoNetwork/network_manager.dart';

class GVSUpdateRecord extends SegmentMessage {
  GVSUpdateRecord({int index = 0, double value = 0.0, int lastUpdateTime = 0}) {
    add("index", MessageUint16(index));
    add("value", MessageFloat32(value));
    add("lastUpdateTime", MessageInt64(lastUpdateTime));
  }

  get index => (segments["index"] as MessageUint16).value;
  get value => (segments["value"] as MessageFloat32).value;
  get lastUpdateTime => (segments["lastUpdateTime"] as MessageInt64).value;
}

typedef GVSUpdateMessage = NetworkMessage<ListMessage>;
typedef GVSUpdateRequest = NetworkMessage<EmptyMessage>;

enum GlobalValueStoreMessageTypes { updateMessage, updateRequest }

class GVSValue {
  double value;
  int lastUpdateTime;
  bool changed;

  GVSValue({this.value = 0, this.lastUpdateTime = 0, this.changed = false});
}

class GlobalValueStore extends NetworkEntity {
  static const messagePrimaryType = 1;

  static GVSUpdateMessage createGVSUpdateMessage(
      {IP source = const IP(0, 0), List<GVSUpdateRecord> changed = const []}) {
    return GVSUpdateMessage(
      MessageHeader(
        source: source,
        destination: source,
        messageType: MessageType(messagePrimaryType,
            GlobalValueStoreMessageTypes.updateMessage.index),
      ),
      ListMessage(
        (size) => List.filled(size, GVSUpdateRecord(), growable: true),
        data: changed,
      ),
    );
  }

  static GVSUpdateRequest createGVSUpdateRequestMessage(
      {IP source = const IP(0, 0)}) {
    return GVSUpdateRequest(
      MessageHeader(
        source: source,
        destination: source,
        messageType: MessageType(messagePrimaryType,
            GlobalValueStoreMessageTypes.updateRequest.index),
      ),
      EmptyMessage(),
    );
  }

  void handleGVSUpdateMessage(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    GVSUpdateMessage update = createGVSUpdateMessage();
    update.build(buffer);

    for (Message message in update.second.data) {
      GVSUpdateRecord record = message as GVSUpdateRecord;
      setValue(
        index: record.index,
        value: record.value,
        updateTime: record.lastUpdateTime,
      );
    }
  }

  void handleUpdateRequest(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    NetworkManager.handleMessage(
      createGVSUpdateMessage(source: getIp(), changed: getAllChangedValues())
          .buildBuffer(),
      this,
    );
  }

  void handleSyncNotification(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    for (int i = 0; i < numberOfFloats32; i++) {
      if (values[i].changed) {
        values[i].lastUpdateTime =
            NetworkClock.convertLocalToServer(values[i].lastUpdateTime);
      }
    }
    NetworkManager.handleMessage(
      createGVSUpdateRequestMessage(source: getIp()).buildBuffer(),
      this,
    );
    handleUpdateRequest(buffer, src, header);
  }

  static const numberOfFloats32 = 1024;

  static int updateTime = 0;
  static int lastUpdate = 0;

  static List<GVSValue> values = List.filled(numberOfFloats32, GVSValue());

  static Set<int> changedIds = {};

  static List<GVSUpdateRecord> getChangedValues(Set<int> changedIds) {
    List<GVSUpdateRecord> out = [];
    for (int index in changedIds) {
      out.add(
        GVSUpdateRecord(
          index: index,
          value: values.elementAt(index).value,
          lastUpdateTime: values.elementAt(index).lastUpdateTime,
        ),
      );
    }
    return out;
  }

  static List<GVSUpdateRecord> getAllChangedValues() {
    Set<int> changed = {};
    for (int i = 0; i < numberOfFloats32; i++) {
      if (values[i].changed) {
        changed.add(i);
      }
    }
    return getChangedValues(changed);
  }

  GlobalValueStore(int updateTime) {
    GlobalValueStore.updateTime = updateTime;
  }

  static void setValue(
      {required int index, required double value, required int updateTime}) {
    if (updateTime < values[index].lastUpdateTime && values[index].changed) {
      return;
    }
    changedIds.add(index);
    values[index] = GVSValue(
      value: value,
      lastUpdateTime: updateTime,
      changed: true,
    );
  }

  static double getValue(int index) {
    return values[index].value;
  }

  @override
  void handle() {
    if (!NetworkClock.synced) {
      return;
    }
    if (DateTime.now().millisecondsSinceEpoch - lastUpdate > updateTime) {
      sendUpdate();
      lastUpdate = DateTime.now().millisecondsSinceEpoch;
    }
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (header.messageType ==
        MessageType(messagePrimaryType,
            GlobalValueStoreMessageTypes.updateMessage.index)) {
      handleGVSUpdateMessage(buffer, src, header);
    } else if (header.messageType ==
        MessageType(messagePrimaryType,
            GlobalValueStoreMessageTypes.updateRequest.index)) {
      handleUpdateRequest(buffer, src, header);
    } else if (header.messageType ==
        MessageType(NetworkClock.messagePrimaryType,
            NetworkClockMessageTypes.syncNotification.index)) {
      handleSyncNotification(buffer, src, header);
    }
  }

  void sendUpdate() {
    if (changedIds.isEmpty) {
      return;
    }
    NetworkManager.handleMessage(
        createGVSUpdateMessage(
                source: getIp(), changed: getChangedValues(changedIds))
            .buildBuffer(),
        this);
    changedIds.clear();
  }

  @override
  IP getIp() {
    return const IP(0, 1);
  }

  @override
  void initialize() {
    values = List.filled(numberOfFloats32, GVSValue());
  }
}
