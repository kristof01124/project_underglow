import 'dart:developer';
import 'dart:ui';

import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ledcontroller/animation.dart';

class BasicAnimationMessage<T extends Message> extends ArduinoAnimation {
  PairMessage<PairMessage<MessageUint16, MessageUint16>, T> data;

  BasicAnimationMessage(int basicAnimationId, T value)
      : data = PairMessage(
            PairMessage(MessageUint16(AnimationType.basicAnimation.index),
                MessageUint16(basicAnimationId)),
            value);

  @override
  void build(List<int> buffer) {
    var testIds = PairMessage(MessageUint16(0), MessageUint16(0));
    testIds.build(buffer);
    if (testIds.first.value != data.first.first.value ||
        testIds.second.value != data.first.second.value) {
      log("Wrong basicAnimationBuilder has been called");
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

enum BasicAnimations {
  basicFill,
  basicRgbWave,
  basicTransition,
  basicParticleFillup,
}

class BasicAnimationMessageBody<T extends Message> extends SegmentMessage {
  BasicAnimationMessageBody(
      {required int start,
      required int duration,
      required T from,
      required T to}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("from", from);
    add("to", to);
  }

  int get start => (segments["start"] as MessageUint64).value;
  int get duration => (segments["duration"] as MessageUint32).value;
  T get from => (segments["from"] as T);
  T get to => (segments["to"] as T);
}

class FillBasicAnimationMessageState extends SegmentMessage {
  FillBasicAnimationMessageState(
      {required double start, required double length, required Color color}) {
    add("start", MessageFloat32(start));
    add("length", MessageFloat32(length));
    add("color", ColorMessage(color));
  }

  double get start => (segments["start"] as MessageFloat32).value;
  double get length => (segments["length"] as MessageFloat32).value;
  Color get color => (segments["color"] as ColorMessage).color;
}

class ParticleFillupBasicAnimationMessageState extends SegmentMessage {
  ParticleFillupBasicAnimationMessageState(
      {required double start, required double length, required Color color}) {
    add("start", MessageFloat32(start));
    add("length", MessageFloat32(length));
    add("color", ColorMessage(color));
  }

  double get start => (segments["start"] as MessageFloat32).value;
  double get length => (segments["length"] as MessageFloat32).value;
  Color get color => (segments["color"] as ColorMessage).color;
}

class RgbWaveBasicAnimationMessageState extends SegmentMessage {
  RgbWaveBasicAnimationMessageState(
      {required double start,
      required double length,
      required int startValue,
      required double transitionSpeed}) {
    add("start", MessageFloat32(start));
    add("length", MessageFloat32(length));
    add("startValue", MessageUint8(startValue));
    add("transitionSpeed", MessageFloat32(transitionSpeed));
  }

  double get start => (segments["start"] as MessageFloat32).value;
  double get length => (segments["length"] as MessageFloat32).value;
  int get startValue => (segments["startValue"] as MessageUint8).value;
  double get transitionSpeed =>
      (segments["transitionSpeed"] as MessageFloat32).value;
}

class TransitionBasicAnimationMessageState extends SegmentMessage {
  TransitionBasicAnimationMessageState(
      {required double start,
      required double length,
      required int n,
      required double gap,
      required Color color1,
      required Color color2}) {
    add("start", MessageFloat32(start));
    add("length", MessageFloat32(length));
    add("n", MessageUint8(n));
    add("gap", MessageFloat32(gap));
    add("color1", ColorMessage(color1));
    add("color2", ColorMessage(color2));
  }

  double get start => (segments["start"] as MessageFloat32).value;
  double get length => (segments["length"] as MessageFloat32).value;
  int get n => (segments["n"] as MessageUint8).value;
  double get gap => (segments["gap"] as MessageFloat32).value;
  Color get color1 => (segments["color1"] as ColorMessage).color;
  Color get color2 => (segments["color2"] as ColorMessage).color;
}

typedef FillBasicAnimationMessageBody
    = BasicAnimationMessageBody<FillBasicAnimationMessageState>;

class FillBasicAnimationMessage
    extends BasicAnimationMessage<FillBasicAnimationMessageBody> {
  FillBasicAnimationMessage(FillBasicAnimationMessageBody body)
      : super(BasicAnimations.basicFill.index, body);
}

typedef RgbWaveBasicAnimationMessageBody
    = BasicAnimationMessageBody<RgbWaveBasicAnimationMessageState>;

class RgbWaveBasicAnimationMessage
    extends BasicAnimationMessage<RgbWaveBasicAnimationMessageBody> {
  RgbWaveBasicAnimationMessage(RgbWaveBasicAnimationMessageBody body)
      : super(BasicAnimations.basicRgbWave.index, body);
}

typedef TransitionBasicAnimationMessageBody
    = BasicAnimationMessageBody<TransitionBasicAnimationMessageState>;

class TransitionBasicAnimationMessage
    extends BasicAnimationMessage<TransitionBasicAnimationMessageBody> {
  TransitionBasicAnimationMessage(TransitionBasicAnimationMessageBody body)
      : super(BasicAnimations.basicTransition.index, body);
}

typedef ParticleFillupBasicAnimationMessageBody
    = BasicAnimationMessageBody<ParticleFillupBasicAnimationMessageState>;

class ParticleFillupBasicAnimationMessage
    extends BasicAnimationMessage<ParticleFillupBasicAnimationMessageBody> {
  ParticleFillupBasicAnimationMessage(
      ParticleFillupBasicAnimationMessageBody body)
      : super(BasicAnimations.basicParticleFillup.index, body);
}
