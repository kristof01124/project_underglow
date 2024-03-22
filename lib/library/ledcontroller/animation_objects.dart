import 'dart:developer';

import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ledcontroller/animation.dart';
import 'package:learning_dart/testing.dart';

class AnimationObjectMessage<T extends Message> extends ArduinoAnimation {
  PairMessage<PairMessage<MessageUint16, MessageUint16>, T> data;

  AnimationObjectMessage(int animationObjectId, T value)
      : data = PairMessage(
            PairMessage(MessageUint16(AnimationType.basicAnimation.index),
                MessageUint16(animationObjectId)),
            value);

  @override
  void build(List<int> buffer) {
    var testIds = PairMessage(MessageUint16(0), MessageUint16(0));
    testIds.build(buffer);
    if (testIds.first.value != data.first.first.value ||
        testIds.second.value != data.first.second.value) {
      log("Wrong effectmessagebuilder has been called");
      throw 1;
    }
    data.build(buffer);
  }

  @override
  List<int> buildBuffer() {
    return data.buildBuffer();
  }

  @override
  int size() {
    return data.size();
  }

  T get animation => data.second;
}

enum AnimationObjects {
  animationGroup,
  sequentialAnimation,
  reversedAnimation,
  mirroredAnimation,
  fadeAnimation,
  animationLoop,
  delayedAnimation
}

class AnimationGroupMessageBody extends SegmentMessage {
  AnimationGroupMessageBody({required int start, ListMessage? data}) {
    data ??= ListMessage(
      (size) => List<AnimationMessage>.filled(
        size,
        AnimationMessage(),
      ),
    );
    add("start", MessageUint64(start));
    add("data", data);
  }

  int get start => (segments["start"] as MessageUint64).value;
  ListMessage get data => (segments["data"] as ListMessage);
}

class AnimationLoopMessageBody extends SegmentMessage {
  AnimationLoopMessageBody(
      {required int repeats, required AnimationMessage animation}) {
    add("repeats", MessageUint32(repeats));
    add("animation", animation);
  }

  int get repeats => (segments["repeats"] as MessageUint32).value;
  AnimationMessage get animation => (segments["animation"] as AnimationMessage);
}

class DelayedAnimationMessageBody extends SegmentMessage {
  DelayedAnimationMessageBody(
      {required int delay, required AnimationMessage animation}) {
    add("delay", MessageUint32(delay));
    add("animation", animation);
  }

  int get delay => (segments["delay"] as MessageUint32).value;
  AnimationMessage get animatoin => (segments["animation"] as AnimationMessage);
}

class FadeAnimationMessageBody extends SegmentMessage {
  FadeAnimationMessageBody(
      {required int fadeInDuration,
      required int fadeOutDuration,
      required AnimationMessage animation}) {
    add("fadeInDuration", MessageUint32(fadeInDuration));
    add("fadeOutDuration", MessageUint32(fadeOutDuration));
    add("animation", animation);
  }

  int get fadeInDuration => (segments["fadeInDuration"] as MessageUint32).value;
  int get fadeOutDuration =>
      (segments["fadeOutDuration"] as MessageUint32).value;
  AnimationMessage get animation => (segments["animation"] as AnimationMessage);
}

class AnimationGroupMessage
    extends AnimationObjectMessage<AnimationGroupMessageBody> {
  AnimationGroupMessage(AnimationGroupMessageBody body)
      : super(AnimationObjects.animationGroup.index, body);
}

class SequentialAnimationMessage
    extends AnimationObjectMessage<AnimationGroupMessageBody> {
  SequentialAnimationMessage(AnimationGroupMessageBody body)
      : super(AnimationObjects.sequentialAnimation.index, body);
}

class ReversedAnimationMessage
    extends AnimationObjectMessage<AnimationMessage> {
  ReversedAnimationMessage(AnimationMessage body)
      : super(AnimationObjects.reversedAnimation.index, body);
}

class MirroredAnimationMessage
    extends AnimationObjectMessage<AnimationMessage> {
  MirroredAnimationMessage(AnimationMessage body)
      : super(AnimationObjects.mirroredAnimation.index, body);
}

class DelayedAnimationAnimationMessage
    extends AnimationObjectMessage<DelayedAnimationMessageBody> {
  DelayedAnimationAnimationMessage(DelayedAnimationMessageBody body)
      : super(AnimationObjects.delayedAnimation.index, body);
}

class AnimationLoopMessage
    extends AnimationObjectMessage<AnimationLoopMessageBody> {
  AnimationLoopMessage(AnimationLoopMessageBody body)
      : super(AnimationObjects.animationLoop.index, body);
}
