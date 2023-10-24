import 'dart:developer';
import 'dart:typed_data';

import 'package:learning_dart/library/ArduinoNetwork/network_clock.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

class IP {
  final int primaryValue, secondaryValue;

  const IP(this.primaryValue, this.secondaryValue);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IP &&
          runtimeType == other.runtimeType &&
          primaryValue == other.primaryValue &&
          secondaryValue == other.secondaryValue;

  int get value => primaryValue * 256 + secondaryValue;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "$primaryValue.$secondaryValue";
  }
}

class IpMessageData extends SegmentMessage {
  IpMessageData([IP value = const IP(0, 0)]) {
    add('secondaryValue', MessageUint8(value.secondaryValue));
    add('primaryValue', MessageUint8(value.primaryValue));
  }

  IP get value => IP((segments['primaryValue'] as MessageUint8).value,
      (segments['secondaryValue'] as MessageUint8).value);
}

class MessageType {
  final int primaryValue, secondaryValue; // unsigned16

  const MessageType(this.primaryValue, this.secondaryValue);

  int get value => primaryValue * (256 * 256) + secondaryValue;

  @override
  String toString() {
    return "$primaryValue.$secondaryValue";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageType &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class MessageTypeMessageData extends SegmentMessage {
  MessageTypeMessageData([MessageType value = const MessageType(0, 0)]) {
    add('secondaryValue', MessageUint16(value.secondaryValue));
    add('primaryValue', MessageUint16(value.primaryValue));
  }

  MessageType get value => MessageType(
        (segments['primaryValue'] as MessageUint16).value,
        (segments['secondaryValue'] as MessageUint16).value,
      );
}

class MessageHeader extends SegmentMessage {
  MessageHeader({
    int protocol = NetworkManager.protocol,
    IP source = const IP(0, 0),
    IP destination = const IP(0, 0),
    MessageType messageType = const MessageType(0, 0),
    int time = 0,
    int checksum = 0,
    int sizeOfPayload = 0,
    int numberOfHops = 0,
  }) {
    add('protocol', MessageUint8(protocol));
    add('source', IpMessageData(source));
    add('destination', IpMessageData(destination));
    add('messageType', MessageTypeMessageData(messageType));
    add('time', MessageUint64(time));
    add('checksum', MessageUint16(checksum));
    add('sizeOfPayload', MessageUint16(sizeOfPayload));
    add('numberOfHops', MessageUint8(numberOfHops));
  }

  int get protocol => (segments['protocol'] as MessageUint8).value;
  IP get source => (segments['source'] as IpMessageData).value;
  IP get destination => (segments['destination'] as IpMessageData).value;
  MessageType get messageType =>
      (segments['messageType'] as MessageTypeMessageData).value;
  int get time => (segments['time'] as MessageUint64).value;
  int get checksum => (segments['checksum'] as MessageUint16).value;
  int get sizeOfPayload => (segments['sizeOfPayload'] as MessageUint16).value;
  int get numberOfHops => (segments['numberOfHops'] as MessageUint8).value;

  int calculateChecksum() {
    if (checksum > 0) {
      return MessageHeader(
        protocol: protocol,
        source: source,
        destination: destination,
        messageType: messageType,
        time: time,
        sizeOfPayload: sizeOfPayload,
        numberOfHops: numberOfHops,
      ).calculateChecksum();
    }
    int out = 0;
    for (int element in (buildBuffer().map((e) => (e < 0 ? e + 256 : e)))) {
      out += element;
    }
    return out;
  }

  bool check(int size) {
    if (size != sizeOfPayload + this.size()) {
      log("The size of the payload doesnt match the expectation!(Expected: $sizeOfPayload + ${this.size()}, got $size)");
      return false;
    }
    if (checksum != calculateChecksum()) {
      log("The checksum isnt correct(got $checksum, expected $calculateChecksum())");
      return false;
    }
    return true;
  }

  void setup(int sizeOfPayload) {
    segments['sizeOfPayload'] = MessageUint16(sizeOfPayload);
    segments['numberOfHops'] = MessageUint8(numberOfHops + 1);
    segments['time'] = MessageUint64(NetworkClock.millis());
    segments['checksum'] = MessageUint16(calculateChecksum());
  }
}

class EmptyMessage extends Message {
  @override
  void build(List<int> buffer) {}

  @override
  List<int> buildBuffer() {
    return [];
  }

  @override
  int size() {
    return 0;
  }
}

abstract class Message {
  // This is the abstract class for everything representing a message or segment of a message
  List<int> buildBuffer();

  void build(List<int> buffer); // This builds the entity from a buffer

  int size();
}

abstract class MessageGenericType<T> extends Message {
  T value;
  late ByteData byteData;
  late void Function(int, T) creatorFunc;
  late T Function(int) builderFunc;

  MessageGenericType(this.value) {
    byteData = ByteData(size());
    setup();
  }

  void setup();

  @override
  void build(List<int> buffer) {
    for (int i = 0; i < size(); i++) {
      byteData.buffer.asUint8List()[size() - i - 1] = buffer[i];
    }
    value = builderFunc(0);
  }

  @override
  List<int> buildBuffer() {
    creatorFunc(0, value);
    return byteData.buffer.asInt8List().reversed.toList();
  }
}

class MessageUint8 extends MessageGenericType<int> {
  MessageUint8(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setUint8;
    builderFunc = byteData.getUint8;
  }

  @override
  int size() {
    return 1;
  }
}

class MessageUint16 extends MessageGenericType<int> {
  MessageUint16(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setUint16;
    builderFunc = byteData.getUint16;
  }

  @override
  int size() {
    return 2;
  }
}

class MessageUint32 extends MessageGenericType<int> {
  MessageUint32(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setUint32;
    builderFunc = byteData.getUint32;
  }

  @override
  int size() {
    return 4;
  }
}

class MessageUint64 extends MessageGenericType<int> {
  MessageUint64(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setUint64;
    builderFunc = byteData.getUint64;
  }

  @override
  int size() {
    return 8;
  }
}

class MessageInt8 extends MessageGenericType<int> {
  MessageInt8(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setInt8;
    builderFunc = byteData.getInt8;
  }

  @override
  int size() {
    return 1;
  }
}

class MessageInt16 extends MessageGenericType<int> {
  MessageInt16(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setInt16;
    builderFunc = byteData.getInt16;
  }

  @override
  int size() {
    return 2;
  }
}

class MessageInt32 extends MessageGenericType<int> {
  MessageInt32(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setInt32;
    builderFunc = byteData.getInt32;
  }

  @override
  int size() {
    return 4;
  }
}

class MessageInt64 extends MessageGenericType<int> {
  MessageInt64(int value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setInt64;
    builderFunc = byteData.getInt64;
  }

  @override
  int size() {
    return 8;
  }
}

class MessageFloat32 extends MessageGenericType<double> {
  MessageFloat32(double value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setFloat32;
    builderFunc = byteData.getFloat32;
  }

  @override
  int size() {
    return 4;
  }
}

class MessageFloat64 extends MessageGenericType<double> {
  MessageFloat64(double value) : super(value);

  @override
  void setup() {
    creatorFunc = byteData.setFloat64;
    builderFunc = byteData.getFloat64;
  }

  @override
  int size() {
    return 8;
  }
}

class PairMessage<A extends Message, B extends Message> extends Message {
  A first;
  B second;

  PairMessage(this.first, this.second);

  @override
  void build(List<int> buffer) {
    first.build(buffer);
    second.build(buffer.sublist(first.size()));
  }

  @override
  List<int> buildBuffer() {
    List<int> out = first.buildBuffer();
    out.addAll(second.buildBuffer());
    return out;
  }

  @override
  int size() {
    return first.size() + second.size();
  }
}

class MessageArray<T extends Message> extends Message {
  List<T> value;

  MessageArray(this.value);

  @override
  int size() {
    int out = 0;
    for (T element in value) {
      out += element.size();
    }
    return out;
  }

  @override
  void build(List<int> buffer) {
    int index = 0;
    for (T element in value) {
      element.build(buffer.sublist(index));
      index += element.size();
    }
  }

  @override
  List<int> buildBuffer() {
    List<int> out = [];
    for (T element in value) {
      out.addAll(element.buildBuffer());
    }
    return out;
  }
}

class SegmentMessage extends Message {
  Map<String, Message> segments = {};
  List<String> order = [];

  void add(String key, Message message) {
    segments[key] = message;
    order.add(key);
  }

  @override
  int size() {
    int out = 0;
    for (var element in segments.values) {
      out += element.size();
    }
    return out;
  }

  @override
  void build(List<int> buffer) {
    int index = 0;
    for (String key in order) {
      segments[key]?.build(buffer.sublist(index));
      index += segments[key]?.size() ?? 0;
    }
  }

  @override
  List<int> buildBuffer() {
    List<int> out = [];
    for (String key in order) {
      out.addAll(segments[key]?.buildBuffer() ?? []);
    }
    return out;
  }
}

class NetworkMessage<T extends Message> extends PairMessage<MessageHeader, T> {
  NetworkMessage(MessageHeader header, T value) : super(header, value);

  void setup() {
    first.setup(second.size());
  }
}

class IndexedMessages<T extends Message> extends PairMessage<MessageUint16, T> {
  IndexedMessages(int id, T value) : super(MessageUint16(id), value) {
    first.value = id;
  }
}

class ListMessage extends PairMessage<MessageUint16, MessageArray> {
  List<Message> Function(int size) builder;

  ListMessage(this.builder, {List<Message> data = const []})
      : super(MessageUint16(0), MessageArray(data));
  List<Message> get data => second.value;

  @override
  List<int> buildBuffer() {
    first.value = data.length;
    return super.buildBuffer();
  }

  @override
  void build(List<int> buffer) {
    MessageUint16 size = MessageUint16(0);
    size.build(buffer);
    second = MessageArray(builder(size.value));
    super.build(buffer);
  }
}
