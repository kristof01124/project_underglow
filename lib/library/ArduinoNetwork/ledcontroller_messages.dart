import 'package:learning_dart/library/ArduinoNetwork/animation_message.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';

const int ledControllerMessagePrimaryType = 5;

enum LedControllerMessageType {
  resize,
  getSize,
  getSizeResponse,
  setBrigthness,
  getBrightness,
  getBrightnessResponse,
  setPopupAnimation,
  getPopupAnimation,
  getPopupAnimationResponse,
  setMainAnimation,
  getMainAnimation,
  getMainAnimationResponse,
  setBackgroundAnimation,
  getBackgroundAnimation,
  getBackgroundAnimationResponse,
  setPowerState,
  getPowerState,
  getPowerStateResponse
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

class GetSizeMessage extends NetworkMessage {
  GetSizeMessage({
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getSize.index,
            ),
          ),
          EmptyMessage(),
        );
}

class GetSizeMessageResponse extends NetworkMessage {
  GetSizeMessageResponse({IP destination = const IP(0), int length = 0})
      : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getSizeResponse.index,
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
              LedControllerMessageType.getBrightness.index,
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

class SetMainAnimationMessage extends NetworkMessage {
  SetMainAnimationMessage({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.setMainAnimation.index),
            source: const IP(0),
            destination: destination,
          ),
          animation ?? AnimationBuilderMessage(),
        );

  Message get animation => second;
}

class GetMainAnimationMessage extends NetworkMessage {
  GetMainAnimationMessage({
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getMainAnimation.index,
            ),
          ),
          EmptyMessage(),
        );
}

class GetMainAnimationResponse extends NetworkMessage {
  GetMainAnimationResponse({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
              destination: destination,
              messageType: MessageType(ledControllerMessagePrimaryType,
                  LedControllerMessageType.getMainAnimationResponse.index)),
          animation ?? AnimationBuilderMessage(),
        );

  Message get animation => second;
}

class SetPopupAnimationMessage extends NetworkMessage {
  SetPopupAnimationMessage({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.setPopupAnimation.index),
            source: const IP(0),
            destination: destination,
          ),
          animation ?? AnimationBuilderMessage(),
        );

  Message get animation => second;
}

class GetPopupAnimationMessage extends NetworkMessage {
  GetPopupAnimationMessage({
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getPopupAnimation.index,
            ),
          ),
          EmptyMessage(),
        );
}

class GetPopupAnimationResponse extends NetworkMessage {
  GetPopupAnimationResponse({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
              destination: destination,
              messageType: MessageType(ledControllerMessagePrimaryType,
                  LedControllerMessageType.getPopupAnimationResponse.index)),
          animation ?? AnimationBuilderMessage(),
        );

  Message get animation => second;
}

class SetBackgroundAnimationMessage extends NetworkMessage {
  SetBackgroundAnimationMessage({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            messageType: MessageType(ledControllerMessagePrimaryType,
                LedControllerMessageType.setBackgroundAnimation.index),
            source: const IP(0),
            destination: destination,
          ),
          animation ?? AnimationBuilderMessage(),
        );

  Message get animation => second;
}

class GetBackgroundAnimationMessage extends NetworkMessage {
  GetBackgroundAnimationMessage({
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getBackgroundAnimation.index,
            ),
          ),
          EmptyMessage(),
        );
}

class GetBackgroundAnimationResponse extends NetworkMessage {
  GetBackgroundAnimationResponse({
    Message? animation,
    IP destination = const IP(0),
  }) : super(
          MessageHeader(
              destination: destination,
              messageType: MessageType(
                  ledControllerMessagePrimaryType,
                  LedControllerMessageType
                      .getBackgroundAnimationResponse.index)),
          animation ?? AnimationBuilderMessage(),
        );

  Message get animation => second;
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

class GetPowerStateMessage extends NetworkMessage {
  GetPowerStateMessage({IP destination = const IP(0)})
      : super(
          MessageHeader(
            destination: destination,
            messageType: MessageType(
              ledControllerMessagePrimaryType,
              LedControllerMessageType.getPowerState.index,
            ),
          ),
          EmptyMessage(),
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
