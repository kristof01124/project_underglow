import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

const int ledControllerMessagePrimaryType = 4;

enum LedControllerMessageType {
  setAnimation,
  getAnimation,
  resize,
  getSize,
  setBrigthness,
  getBrigthness,
  setPowerState,
  getPowerState
}

class SetAnimationMessage extends NetworkMessage {
  SetAnimationMessage(
    Message animation, {
    required IP destination,
  }) : super(
          MessageHeader(
            protocol: NetworkManager.protocol,
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.setAnimation.index),
            source: const IP(0),
            destination: destination,
          ),
          animation,
        );
}
