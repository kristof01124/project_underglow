import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ledcontroller/animation.dart';

enum LedControllerMessageTypes {
  setAnimationMessage,
  appendAnimationMessage,
  setPowerMessage,
  setBrightnessMessage,
  syncMessage
}

typedef SetBrightnessMessage = PairMessage<MessageHeader, MessageUint8>;
typedef SetPowerMessage = PairMessage<MessageHeader, MessageUint8>;
typedef SetAnimationMessage
    = PairMessage<MessageHeader, PairMessage<MessageUint8, ArduinoAnimation>>;
typedef AppendAnimationMessage = SetAnimationMessage;
typedef SyncMessage = PairMessage<MessageHeader, MessageUint64>;

class Ledcontroller {
  static const int messagePrimaryType = 5;
  static SetBrightnessMessage createSetBrightnessMessage(
      IP source, IP destination, int brightness) {
    return SetBrightnessMessage(
        MessageHeader(
          source: source,
          destination: destination,
          messageType: MessageType(
            messagePrimaryType,
            LedControllerMessageTypes.setBrightnessMessage.index,
          ),
        ),
        MessageUint8(brightness));
  }

  static SetPowerMessage createSetPowerMessage(
      IP source, IP destination, bool state) {
    return SetBrightnessMessage(
      MessageHeader(
        source: source,
        destination: destination,
        messageType: MessageType(
          messagePrimaryType,
          LedControllerMessageTypes.setPowerMessage.index,
        ),
      ),
      MessageUint8(state ? 1 : 0),
    );
  }

  static SetAnimationMessage crateSetAnimationMessage(
      IP source, IP destination, int index, ArduinoAnimation animation) {
    return SetAnimationMessage(
        MessageHeader(
          source: source,
          destination: destination,
          messageType: MessageType(
            messagePrimaryType,
            LedControllerMessageTypes.setAnimationMessage.index,
          ),
        ),
        PairMessage(
          MessageUint8(index),
          animation,
        ));
  }

  static AppendAnimationMessage createAppendAnimationMessage(
      IP source, IP destination, int index, ArduinoAnimation animation) {
    return AppendAnimationMessage(
        MessageHeader(
          source: source,
          destination: destination,
          messageType: MessageType(
            messagePrimaryType,
            LedControllerMessageTypes.appendAnimationMessage.index,
          ),
        ),
        PairMessage(
          MessageUint8(index),
          animation,
        ));
  }

  static SyncMessage createSyncMessage(IP source, IP destination, int time) {
    return SyncMessage(
      MessageHeader(
        source: source,
        destination: destination,
        messageType: MessageType(
          messagePrimaryType,
          LedControllerMessageTypes.syncMessage.index,
        ),
      ),
      MessageUint64(time),
    );
  }
}
