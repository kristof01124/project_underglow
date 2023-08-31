import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
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

enum GlobalValueStoreMessageTypes { updateRequest, updateMessage }

class GVSValue {
  double value;
  int lastUpdate;
  bool updated;

  GVSValue({this.value = 0, this.lastUpdate = 0, this.updated = false});
}

class GlobalValueStore extends NetworkEntity {
  static const messagePrimaryType = 2;
  static const numberOfFloats32 = 1024;
  static const globalValueStoreIp = IP(4);

  static int updateTime = 0;
  static int lastUpdate = 0;

  static List<GVSValue> values = List.filled(numberOfFloats32, GVSValue());

  static Set<int> changedIds = {};

  List<GVSUpdateRecord> getChangedValues(Set<int> changedIds) {
    List<GVSUpdateRecord> out = [];
    for (int index in changedIds) {
      out.add(
        GVSUpdateRecord(
          index: index,
          value: values.elementAt(index).value,
          lastUpdateTime: values.elementAt(index).lastUpdate,
        ),
      );
    }
    return out;
  }

  static GVSUpdateMessage createGVSUpdateMessage(
      {IP source = const IP(0), List<GVSUpdateRecord> changed = const []}) {
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
      {IP source = const IP(0)}) {
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

  void handleUpdate(List<int> buffer, NetworkEntity src, MessageHeader header) {
    GVSUpdateMessage update = createGVSUpdateMessage();
    update.build(buffer);

    for (Message message in update.second.data) {
      GVSUpdateRecord record = message as GVSUpdateRecord;
      set(
          index: record.index,
          value: record.value,
          updateTime: record.lastUpdateTime,
          local: false);
    }
  }

  void handleUpdateRequest(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    Set<int> changed = {};
    for (int i = 0; i < numberOfFloats32; i++) {
      if (values[i].updated) {
        changed.add(i);
      }
    }
    if (changed.isNotEmpty) {
      NetworkManager.handleMessage(
        createGVSUpdateMessage(
                source: GlobalValueStore.globalValueStoreIp,
                changed: getChangedValues(changed))
            .buildBuffer(),
        this,
      );
    }
  }

  void handleSyncNotification(
      List<int> buffer, NetworkEntity src, MessageHeader header) {
    for (int i = 0; i < numberOfFloats32; i++) {
      if (values[i].updated) {
        values[i].lastUpdate += NetworkClock.timeDifference;
      }
    }
    NetworkManager.handleMessage(
      createGVSUpdateRequestMessage(source: globalValueStoreIp).buildBuffer(),
      this,
    );
  }

  @override
  void handle() {
    if (!NetworkClock.synced) {
      return;
    }
    if (DateTime.now().millisecondsSinceEpoch - lastUpdate > updateTime) {
      sendUpdate();
    }
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader header = MessageHeader();
    header.build(buffer);
    if (header.messageType ==
        MessageType(messagePrimaryType,
            GlobalValueStoreMessageTypes.updateMessage.index)) {
      handleUpdate(buffer, src, header);
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
    lastUpdate = DateTime.now().millisecondsSinceEpoch;
    if (changedIds.isEmpty) {
      return;
    }
    NetworkManager.handleMessage(
        createGVSUpdateMessage(
                source: globalValueStoreIp,
                changed: getChangedValues(changedIds))
            .buildBuffer(),
        this);
    changedIds.clear();
  }

  static void set(
      {required int index,
      required double value,
      required int updateTime,
      bool local = true}) {
    if (!local && updateTime <= values[index].lastUpdate) {
      return;
    }
    if (value == values.elementAt(index).value) {
      return;
    }
    values[0] = GVSValue(value: value, updated: true, lastUpdate: updateTime);
    changedIds.add(index);
  }

  static void setLocally({required int index, required double value}) {
    set(index: index, value: value, updateTime: NetworkClock.millis());
  }

  GlobalValueStore() : super(ip: globalValueStoreIp);
}
