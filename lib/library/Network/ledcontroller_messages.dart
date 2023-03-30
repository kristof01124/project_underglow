import 'package:learning_dart/library/ArduinoNetwork/animation_message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ArduinoNetwork/network_manager.dart';

const int ledControllerMessagePrimaryType = 4;

enum LedControllerMessageType {
  setAnimation,
  getAnimation,
  getAnimationResponse,
  resize,
  getSize,
  getSizeResponse,
  setBrigthness,
  getBrigthness,
  getBrightnessResponse,
  setPowerState,
  getPowerState,
  getPowerStateResponse
}

class SetAnimationMessage extends NetworkMessage {
  SetAnimationMessage({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            protocol: NetworkManager.protocol,
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.setAnimation.index),
            source: const IP(0),
            destination: destination,
          ),
          animation ?? AnimationBuilderMessage(),
        );
}

class GetAnimationMesage extends NetworkMessage {
  GetAnimationMesage({
    IP destination = const IP(0),
  }) : super(
            MessageHeader(
                destination: destination,
                messageType: MessageType(ledControllerMessagePrimaryType,
                    LedControllerMessageType.getAnimation.index)),
            EmptyMessage());
}

class GetAnimationMessageResponse extends NetworkMessage {
  GetAnimationMessageResponse({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
              destination: destination,
              messageType: MessageType(ledControllerMessagePrimaryType,
                  LedControllerMessageType.getAnimationResponse.index)),
          animation ?? AnimationBuilderMessage(),
        );
}
