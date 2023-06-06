import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';

class MessageRouterRecord {
  final IP ipOfDevice;
  final int numberOfHops;
  final int lastUpdate;
  final NetworkEntity destinationEntity;
  final double distance;

  MessageRouterRecord({
    required this.ipOfDevice,
    required this.numberOfHops,
    required this.lastUpdate,
    required this.destinationEntity,
    required this.distance,
  });
}

class MessageRouterRecordUpdate extends SegmentMessage {
  MessageRouterRecordUpdate({
    IP ipOfDevice = const IP(0),
    int numberOfHops = 0,
    double distance = 0,
  }) {
    add('ipOfDevice', IpMessageData(ipOfDevice));
    add('numberOfHops', MessageUint8(numberOfHops));
    add('distance', MessageUint64(distance.toInt()));
  }

  IP get ipOfDevice => (segments['ipOfDevice'] as IpMessageData).value;
  int get numberOfHops => (segments['numberOfHops'] as MessageUint8).value;
  double get distance =>
      (segments['distance'] as MessageUint64).value.toDouble();
}

class MeRUpdateMessage extends NetworkMessage<ListMessage> {
  MeRUpdateMessage()
      : super(
            MessageHeader(
              protocol: NetworkManager.protocol,
              source: MessageRouter.messageRouterIp,
              destination: MessageRouter.messageRouterIp,
              messageType: const MessageType(
                MessageRouter.messagePrimaryType,
                MessageRouter.updateMessageSecondaryType,
              ),
            ),
            ListMessage(
              (int size) => List.filled(size, MessageRouterRecordUpdate(),
                  growable: true),
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
      update.second.data.add(
        MessageRouterRecordUpdate(
          ipOfDevice: element.ipOfDevice,
          numberOfHops: element.numberOfHops,
        ),
      );
    }
    NetworkManager.handleMessage(update.buildBuffer(), this);
  }

  void handleUpdateMessage(MeRUpdateMessage msg, NetworkEntity src) {
    Map<IP, MessageRouterRecord> changed = {};
    double delay = double.infinity;
    if (NetworkClock.isSynced) {
      delay = (NetworkClock.millis() - msg.first.time).toDouble();
    }
    for (var element in msg.second.data) {
      var record = (element as MessageRouterRecordUpdate);
      MessageRouterRecord newRecord = MessageRouterRecord(
        ipOfDevice: record.ipOfDevice,
        numberOfHops: record.numberOfHops,
        distance: record.distance + delay,
        lastUpdate: NetworkClock.millis(),
        destinationEntity: src,
      );
      if (foundBetterDestinationEntity(newRecord)) {
        advertisedRecords[record.ipOfDevice] = newRecord;
        changed[record.ipOfDevice] = newRecord;
      }
    }
    sendUpdateMessageChanged(changed);
  }

  void broadcastMessage(List<int> buffer, NetworkEntity src) {
    for (var value in advertisedRecords.values) {
      sendLocal(value, buffer, src);
    }
    for (var value in notAdvertisedRecords) {
      sendLocal(value, buffer, src);
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

  static MessageRouterRecord findRecord(IP ip) {
    var element = advertisedRecords[ip];
    if (element != null) {
      return element;
    }
    return notAdvertisedRecords.reduce(
        (value, element) => element.ipOfDevice == ip ? value = element : value);
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
    advertisedRecords.removeWhere(
      (key, value) =>
          DateTime.now().millisecondsSinceEpoch - value.lastUpdate >=
          timeoutTime,
    );
  }

  static bool foundBetterDestinationEntity(MessageRouterRecord newValue) {
    // If the new device is closer, than returns true
    if (advertisedRecords[newValue.ipOfDevice] != null) {
      if ((advertisedRecords[newValue.ipOfDevice]?.distance ??
              double.infinity) >
          newValue.distance) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    MessageHeader msg = MessageHeader();
    msg.build(buffer);
    if (msg.destination == messageRouterIp && msg.numberOfHops > 0) {
      // This part only works, because the only messsage that should be sent to the MeR is an update message!!!!!
      MeRUpdateMessage update = MeRUpdateMessage();
      update.build(buffer);
      handleUpdateMessage(update, src);
      return;
    }
    if (msg.destination == broadcastIP) {
      broadcastMessage(buffer, src);
      return;
    }
    if (!containsRecord(msg.destination)) {
      return;
    }
    // This should not throw, because of the previous statement
    var element = findRecord(msg.destination);
    if (element.destinationEntity == src) {
      broadcastMessage(buffer, src);
      return;
    }
    element.destinationEntity.handleMessage(buffer, src);
  }

  @override
  void handle() {
    int time = DateTime.now().millisecondsSinceEpoch;
    if (time - lastUpdate >= updateTime) {
      // sendUpdateMessage(); This is probably not neccessary for the phone part
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
      advertisedRecords[entity.getIp()] = MessageRouterRecord(
        ipOfDevice: entity.getIp(),
        numberOfHops: 0,
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        distance: 0,
        destinationEntity: entity,
      );
    } else {
      notAdvertisedRecords.add(
        MessageRouterRecord(
          ipOfDevice: entity.getIp(),
          numberOfHops: 0,
          lastUpdate: DateTime.now().millisecondsSinceEpoch,
          distance: 0,
          destinationEntity: entity,
        ),
      );
    }
  }
}
