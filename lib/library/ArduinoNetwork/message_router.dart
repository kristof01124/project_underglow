import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

import 'message.dart';
import 'network_entity.dart';

class MessageRouterRecord {
  IP ipOfDevice;
  int numberOfHops;
  int lastUpdate;
  NetworkEntity destinationEntity;

  MessageRouterRecord(this.ipOfDevice, this.numberOfHops, this.lastUpdate,
      this.destinationEntity);
}

class MessageRouterRecordUpdate extends SegmentMessage {
  MessageRouterRecordUpdate(
      [IP ipOfDevice = const IP(0), int numberOfHops = 0]) {
    add('ipOfDevice', IpMessageData(ipOfDevice));
    add('numberOfHops', MessageUint8(numberOfHops));
  }

  IP get ipOfDevice => (segments['ipOfDevice'] as IpMessageData).value;
  int get numberOfHops => (segments['numberOfHops'] as MessageUint8).value;
}

class MeRUpdateMessage extends NetworkMessage<ListMessage> {
  MeRUpdateMessage()
      : super(
            MessageHeader(
              NetworkManager.protocol,
              MessageRouter.messageRouterIp,
              MessageRouter.messageRouterIp,
              const MessageType(
                MessageRouter.messagePrimaryType,
                MessageRouter.updateMessageSecondaryType,
              ),
              0,
              0,
              0,
            ),
            ListMessage(
              (int size) => List.filled(size, MessageRouterRecordUpdate()),
            ));
}

class MessageRouter extends NetworkEntity {
  static const int messagePrimaryType = 4;
  static const int updateMessageSecondaryType = 1;

  static const IP messageRouterIp = IP(1);

  static const int timeoutTime = 0;
  static const int updateTime = 1000;

  static int lastUpdate = 0;
  static Map<IP, MessageRouterRecord> advertisedRecords = {};
  static List<MessageRouterRecord> notAdvertisedRecords = [];

  void sendUpdateMessage() {
    sendUpdateMessageChanged(advertisedRecords);
  }

  void sendUpdateMessageChanged(Map<IP, MessageRouterRecord> changed) {
    if (changed.isEmpty) {
        return;
    }
    MeRUpdateMessage update = MeRUpdateMessage();
    for (var element in changed.values) {
        update.second.data.add(MessageRouterRecordUpdate(element.ipOfDevice, element.numberOfHops + 1));
    }
    NetworkManager.handleMessage(update.buildBuffer(), this);
  }

  void handleUpdateMessage(MeRUpdateMessage msg, NetworkEntity src) {
    int time = DateTime.now().millisecondsSinceEpoch;
    Map<IP, MessageRouterRecord> changed = {};
    for (var element in msg.second.data) {
        var record = (element as MessageRouterRecordUpdate);
        MessageRouterRecord newRecord = MessageRouterRecord(record.ipOfDevice, record.numberOfHops, time, src);
        if (foundBetterDestinationEntity(newRecord)) {
          advertisedRecords[record.ipOfDevice] = newRecord;
          changed[record.ipOfDevice] = newRecord;
        }
        
    }
    if (changed.isEmpty) {
        return;
    }
    sendUpdateMessageChanged(changed);
  }

  void broadcastMessage(List<int> buffer, NetworkEntity src) {
    for (var element in advertisedRecords.values) {
        sendLocal(element, buffer, src);
    }
    for (var element in notAdvertisedRecords) {
        sendLocal(element, buffer, src);
    }
  }

  static bool containsRecord(IP value) {
    if (value == defautltIP) {
      return false;
    }
    if (advertisedRecords.containsKey(value)) {
      return true;
    }
    for (var element in notAdvertisedRecords) {
            if (element.ipOfDevice.entityIp == value.entityIp) {
                return true;
                  }
        }
    return false;
    }

  static MessageRouterRecord findRecord(IP value) {
    var element = advertisedRecords[value];
    if (element != null) {
      return element;
    }
    for (var element in notAdvertisedRecords) {
            if (element.ipOfDevice.entityIp == value.entityIp) {
                return element;
        }
    }
    throw Exception();
  }

  void send(List<int> buffer, NetworkEntity src, NetworkEntity dst) {
    if (src != dst) {
      dst.handleMessage(buffer, src);
    }
  }

  void sendLocal(
      MessageRouterRecord record, List<int> buffer, NetworkEntity src) {
    if (record.numberOfHops == 0) {
      send(buffer, src, record.destinationEntity);
    }
  }

  static void pruneInactiveRecords() {
    if (timeoutTime == 0) {
        return;
    }
    List<IP> shouldBeDeleted = [];
    int time = DateTime.now().millisecondsSinceEpoch;
    for (var element in advertisedRecords.entries) {
        if (element.value.lastUpdate + timeoutTime < time) {
            shouldBeDeleted.add(element.key);
        }
    }
    for (var key in shouldBeDeleted) {
        advertisedRecords.remove(key);
    }
  }
  static void reinforceRecord(MessageHeader header, NetworkEntity src) {
    int time = DateTime.now().millisecondsSinceEpoch;
    if (advertisedRecords[header.source] != null) {
        MessageRouterRecord record = (advertisedRecords[header.source] as MessageRouterRecord);
        if (record.destinationEntity == src) {
            record.lastUpdate = time;
        }
    }
  }

  static bool foundBetterDestinationEntity(MessageRouterRecord newValue) {
    if (advertisedRecords[newValue.ipOfDevice] != null) {
        return ((advertisedRecords[newValue.ipOfDevice])?.numberOfHops ?? 0) > newValue.numberOfHops;
    }
    return true;
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader msg = MessageHeader();
    msg.build(buffer);
    if (msg.destination == broadcastIP) {
        broadcastMessage(buffer, src);
    } else {
        if (!containsRecord(msg.destination)) {
            return;
        }
        var element = findRecord(msg.destination);
        if (element.destinationEntity == src) {
            broadcastMessage(buffer, src);
            return;
        }
        element.destinationEntity.handleMessage(buffer, src);
    }
  }

  @override
  void handle() {
    int time = DateTime.now().millisecondsSinceEpoch;
    if (time - lastUpdate >= updateTime) {
      sendUpdateMessage();
      pruneInactiveRecords();
    }
  }

  @override
  void initialize() {
    advertisedRecords.clear();
    notAdvertisedRecords.clear();
    for (NetworkEntity entity in NetworkManager.entities) {
        addEntity(entity);
    }
    sendUpdateMessage();
  }

  static const IP defautltIP = IP(0);
  static const IP broadcastIP = IP(255);

  static void addEntity(NetworkEntity entity) {
    if (entity.advertised()) {
        advertisedRecords[entity.getIp()] = MessageRouterRecord(entity.getIp(), 0, 0, entity);
    } else {
        notAdvertisedRecords.add(MessageRouterRecord(entity.getIp(), 0, 0, entity));
    }
  }
}
