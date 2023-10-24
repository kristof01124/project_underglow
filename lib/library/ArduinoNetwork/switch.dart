import 'dart:collection';
import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';
import 'package:learning_dart/library/ArduinoNetwork/serial.dart';
import 'package:learning_dart/main.dart';

import 'message.dart';

Duration waitDuration = const Duration(milliseconds: 500);

enum ReadingState { start, messsage, end }

class Switch extends NetworkEntity {
  final int cancelCharacter = 170;
  final int startCharacter = 171;
  final int endCharacter = 172;
  final int numberOfDelimiterCharacters = 8;

  int timeoutTime = 100;

  bool currentlyWriting = false;
  List<int> currentBuffer = [];

  ReadingState readingState = ReadingState.start;

  Serial serial;

  bool cancelNextCharacter = false;

  bool disabled = false;

  int startValues = 0, endValues = 0;

  int lastCharacterReadTime = 0;

  Queue<List<int>> messages = Queue();

  bool shouldBeCancelled(int value) {
    return value >= cancelCharacter && value <= endCharacter;
  }

  void sendMessages() {
    currentlyWriting = true;
    while (messages.isNotEmpty) {
      sendOneMessage(messages.first);
      messages.removeFirst();
    }
    currentlyWriting = false;
  }

  void sendOneMessage(List<int> msg) {
    sendStartDelimiter();
    sendMessageData(msg);
    sendEndDelimiter();
  }

  void sendStartDelimiter() {
    for (int i = 0; i < numberOfDelimiterCharacters; i++) {
      serial.write(startCharacter);
    }
  }

  void sendMessageData(List<int> msg) {
    for (int value in msg) {
      if (shouldBeCancelled(value)) {
        serial.write(cancelCharacter);
      }
      serial.write(value);
    }
  }

  void sendEndDelimiter() {
    for (int i = 0; i < numberOfDelimiterCharacters; i++) {
      serial.write(endCharacter);
    }
  }

  void handleCurrentMessage(int value) {
    int time = DateTime.now().millisecondsSinceEpoch;
    if (time - lastCharacterReadTime > timeoutTime) {
      clear();
    }
    lastCharacterReadTime = time;
    if (!cancelNextCharacter && value == cancelCharacter) {
      cancelNextCharacter = true;
      return;
    }
    if (readingState == ReadingState.start) {
      handleCurrentMessageStartPhase(value);
    } else if (readingState == ReadingState.messsage) {
      handleCurrentMessageMessagePhase(value);
    } else if (readingState == ReadingState.end) {
      handleCurrentMessageEndPhase(value);
    }
  }

  void handleCurrentMessageStartPhase(int value) {
    if (value == startCharacter) {
      startValues++;
      if (startValues == numberOfDelimiterCharacters) {
        readingState = ReadingState.messsage;
      }
    } else {
      clear();
    }
  }

  void handleCurrentMessageMessagePhase(int value) {
    if (value == endCharacter) {
      readingState = ReadingState.end;
      endValues = 1;
    } else if (!cancelNextCharacter && shouldBeCancelled(value)) {
      clear();
    } else {
      currentBuffer.add(value);
      cancelNextCharacter = false;
    }
  }

  void handleCurrentMessageEndPhase(int value) {
    if (value == endCharacter) {
      endValues++;
      if (endValues == numberOfDelimiterCharacters) {
        finalizeCurrentMessage();
      }
    } else {
      clear();
    }
  }

  void clear() {
    currentBuffer.clear();
    readingState = ReadingState.start;
    cancelNextCharacter = false;
    startValues = 0;
    endValues = 0;
  }

  void setDisabled(bool value) {
    disabled = value;
  }

  bool writing() {
    return currentlyWriting;
  }

  Switch(this.serial) {
    clear();
  }

  int available() {
    return messages.length;
  }

  @override
  void handleMessage(List<int> buffer, NetworkEntity src) {
    if (disabled) {
      return;
    }
    messages.addFirst(buffer);
    if (!writing()) {
      sendMessages();
    }
  }

  @override
  void handle() {
    int time = DateTime.now().millisecondsSinceEpoch;
    if (disabled) {
      return;
    }
    if (time - lastCharacterReadTime > timeoutTime) {
      clear();
    }
    while (serial.available() != 0) {
      handleCurrentMessage(serial.read());
    }
  }

  void finalizeCurrentMessage() {
    MessageHeader msg = MessageHeader();
    msg.build(currentBuffer);
    if (msg.check(currentBuffer.length)) {
      NetworkManager.handleMessage(currentBuffer, this);
    }
    clear();
  }

  @override
  IP getIp() {
    return NetworkManager.switchIP;
  }
}
