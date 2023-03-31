import 'package:flutter/material.dart';
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

class LedControllerGetterMessage extends NetworkMessage {
  LedControllerGetterMessage(
      {IP destination = const IP(0), int secondaryType = 0})
      : super(
          MessageHeader(
              destination: destination,
              messageType: MessageType(
                ledControllerMessagePrimaryType,
                secondaryType,
              )),
          EmptyMessage(),
        );
}

class SetAnimationMessage extends NetworkMessage {
  SetAnimationMessage({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.setAnimation.index),
            source: const IP(0),
            destination: destination,
          ),
          animation ?? AnimationBuilderMessage(),
        );

  Message get animation => second;
}

class GetAnimationMessage extends LedControllerGetterMessage {
  GetAnimationMessage({
    IP destination = const IP(0),
  }) : super(
          destination: destination,
          secondaryType: LedControllerMessageType.getAnimation.index,
        );
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

  Message get animation => second;
}

class ResizeMessage extends NetworkMessage {
  ResizeMessage({
    int length = 0,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.resize.index),
          ),
          MessageUint16(length),
        );

  int get length => (second as MessageUint16).value;
}

class GetSizeMessage extends LedControllerGetterMessage {
  GetSizeMessage({
    IP destination = const IP(0),
  }) : super(
          destination: destination,
          secondaryType: LedControllerMessageType.getSize.index,
        );
}

class GetSizeMessageResponse extends NetworkMessage {
  GetSizeMessageResponse({IP destination = const IP(0), int length = 0})
      : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getSize.index,
            ),
          ),
          MessageUint16(length),
        );

  int get length => (second as MessageUint16).value;
}

class SetBrigthnessMessage extends NetworkMessage {
  SetBrigthnessMessage({IP destination = const IP(0), int brightness = 0})
      : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.setBrigthness.index),
          ),
          MessageUint8(brightness),
        );

  int get brightness => (second as MessageUint8).value;
}

class GetBrightnessMessage extends NetworkMessage {
  GetBrightnessMessage({IP destination = const IP(0)})
      : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getBrigthness.index,
            ),
          ),
          EmptyMessage(),
        );
}

class GetBrightnessMessageResponse extends NetworkMessage {
  GetBrightnessMessageResponse(
      {IP destination = const IP(0), int brightness = 0})
      : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getBrightnessResponse.index,
            ),
          ),
          MessageUint8(brightness),
        );

  int get brigthness => (second as MessageUint8).value;
}

class SetPowerStateMessage extends NetworkMessage {
  SetPowerStateMessage({IP destination = const IP(0), int state = 0})
      : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.setPowerState.index,
            ),
          ),
          MessageUint8(state),
        );

  int get state => (second as MessageUint8).value;
}

class GetPowerStateMessage extends LedControllerGetterMessage {
  GetPowerStateMessage({IP destination = const IP(0)})
      : super(
          destination: destination,
          secondaryType: LedControllerMessageType.getPowerState.index,
        );
}

class GetPowerStateMessageResponse extends NetworkMessage {
  GetPowerStateMessageResponse({IP destination = const IP(0), int state = 0})
      : super(
          MessageHeader(
              destination: destination,
              messageType: MessageType(
                ledControllerMessagePrimaryType,
                LedControllerMessageType.getPowerStateResponse.index,
              )),
          MessageUint8(state),
        );

  int get state => (second as MessageUint8).value;
}
