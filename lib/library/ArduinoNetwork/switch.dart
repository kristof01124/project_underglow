import 'dart:collection';

import 'package:learning_dart/library/ArduinoNetwork/network_entity.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';
import 'package:learning_dart/library/ArduinoNetwork/serial.dart';

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

  Queue<List<int>> messages = Queue();
  List<int> currentBuffer = [];

  ReadingState readingState = ReadingState.start;

  Serial serial;

  // WRITING

  bool shouldBeCancelled(int value) {
    return (value >= cancelCharacter && value <= endCharacter);
  }

  void sendMessages() async {
    if (currentlyWriting) {
      return;
    }
    currentlyWriting = true;
    while (available() != 0) {
        sendOneMessage(messages.removeFirst());
        await Future.delayed(Duration.zero);
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

  // READING

  int startValues = 0, endValues = 0;

  int lastCharacterReadTime = 0;

  bool cancelNextCharacter = true;

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
      if (value == startCharacter) {
        startValues++;
        if (startValues == numberOfDelimiterCharacters) {
          readingState = ReadingState.messsage;
        }
      } else {
        clear();
      }
    } else if (readingState == ReadingState.messsage) {
      if (value == endCharacter) {
        readingState = ReadingState.end;
        endValues++;
        return;
      } else if (!cancelNextCharacter && shouldBeCancelled(value)) {
        clear();
        return;
      }
      currentBuffer.add(value);
    } else if (readingState == ReadingState.end) {
      if (value == endCharacter) {
        endValues++;
        if (endValues == numberOfDelimiterCharacters) {
          finalizeCurrentMessage();
        }
      } else {
        clear();
      }
    }
  }

  void clear() {
    currentBuffer.clear();
    readingState = ReadingState.start;
    cancelNextCharacter = false;
    startValues = 0;
    endValues = 0;
  }

  bool reading() {
    return true; // TODO
  }

  bool writing() {
    return currentlyWriting;
  }

  bool disabled = false;

  int available() {
    return messages.length;
  }

  Switch(this.serial) {
    clear();
  }

  void handleMessage(List<int> buffer, NetworkEntity src) {
    messages.add(buffer);
    sendMessages();
  }

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
}
