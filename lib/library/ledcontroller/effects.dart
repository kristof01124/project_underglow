import 'dart:developer';
import 'dart:ui';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ledcontroller/animation.dart';

class EffectMessage<T extends Message> extends ArduinoAnimation {
  PairMessage<PairMessage<MessageUint16, MessageUint16>, T> data;

  EffectMessage(int effectId, T value)
      : data = PairMessage(
            PairMessage(MessageUint16(AnimationType.effect.index),
                MessageUint16(effectId)),
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

enum Effects {
  fill,
  running,
  fillup,
  harmonika,
  fillout,
  pewPew,
  rgbWave,
  rgbCycle,
  twoColorWave,
  particleFillup,
  breathe,
  strobe
}

class FillEffectMessageBody extends SegmentMessage {
  FillEffectMessageBody(
      {required int start, required int duration, required Color color}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color", ColorMessage(color));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color => (segments['color'] as ColorMessage).color;
}

class FillEffectMessage extends EffectMessage<FillEffectMessageBody> {
  FillEffectMessage(FillEffectMessageBody value)
      : super(Effects.fill.index, value);
}

class RunningEffectMessageBody extends SegmentMessage {
  RunningEffectMessageBody(
      {required int start,
      required int duration,
      required Color color,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color", ColorMessage(color));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color => (segments['color'] as ColorMessage).color;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class RunningEffectMessage extends EffectMessage<RunningEffectMessageBody> {
  RunningEffectMessage(RunningEffectMessageBody value)
      : super(Effects.running.index, value);
}

class FillupEffectMessageBody extends SegmentMessage {
  FillupEffectMessageBody(
      {required int start,
      required int duration,
      required Color color,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color", ColorMessage(color));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color => (segments['color'] as ColorMessage).color;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class FillupEffectMessage extends EffectMessage<FillupEffectMessageBody> {
  FillupEffectMessage(FillupEffectMessageBody value)
      : super(Effects.fillup.index, value);
}

class FilloutEffectMessageBody extends SegmentMessage {
  FilloutEffectMessageBody(
      {required int start,
      required int duration,
      required Color color,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color", ColorMessage(color));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color => (segments['color'] as ColorMessage).color;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class FilloutEffectMessage extends EffectMessage<FilloutEffectMessageBody> {
  FilloutEffectMessage(FilloutEffectMessageBody value)
      : super(Effects.fillout.index, value);
}

class HarmonikaEffectMessageBody extends SegmentMessage {
  HarmonikaEffectMessageBody(
      {required int start,
      required int duration,
      required Color color,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color", ColorMessage(color));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color => (segments['color'] as ColorMessage).color;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class HarmonikaEffectMessage extends EffectMessage<HarmonikaEffectMessageBody> {
  HarmonikaEffectMessage(HarmonikaEffectMessageBody value)
      : super(Effects.harmonika.index, value);
}

class PewPewEffectMessageBody extends SegmentMessage {
  PewPewEffectMessageBody(
      {required int start,
      required int duration,
      required Color color,
      required double length,
      required double gap,
      required int n,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color", ColorMessage(color));
    add("length", MessageFloat32(length));
    add("gap", MessageFloat32(gap));
    add("n", MessageUint8(n));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color => (segments['color'] as ColorMessage).color;
  double get length => (segments['length'] as MessageFloat32).value;
  double get gap => (segments['gap'] as MessageFloat32).value;
  int get n => (segments['n'] as MessageUint8).value;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class PewPewEffectMessage extends EffectMessage<PewPewEffectMessageBody> {
  PewPewEffectMessage(PewPewEffectMessageBody value)
      : super(Effects.pewPew.index, value);
}

class RgbWaveEffectMessageBody extends SegmentMessage {
  RgbWaveEffectMessageBody(
      {required int start, required int duration, required double speed}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("speed", MessageFloat32(speed));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  double get color => (segments['speed'] as MessageFloat32).value;
}

class RgbWaveEffectMessage extends EffectMessage<RgbWaveEffectMessageBody> {
  RgbWaveEffectMessage(RgbWaveEffectMessageBody value)
      : super(Effects.rgbWave.index, value);
}

class RgbCycleEffectMessageBody extends SegmentMessage {
  RgbCycleEffectMessageBody({required int start, required int duration}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
}

class RgbCycleEffectMessage extends EffectMessage<RgbCycleEffectMessageBody> {
  RgbCycleEffectMessage(RgbCycleEffectMessageBody value)
      : super(Effects.rgbCycle.index, value);
}

class TwoColorWaveEffectMessageBody extends SegmentMessage {
  TwoColorWaveEffectMessageBody(
      {required int start,
      required int duration,
      required Color color1,
      required Color color2,
      required double a,
      required double b,
      required double c,
      required double d}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color1", ColorMessage(color1));
    add("color2", ColorMessage(color2));
    add("a", MessageFloat32(a));
    add("b", MessageFloat32(b));
    add("c", MessageFloat32(c));
    add("d", MessageFloat32(d));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color1 => (segments['color1'] as ColorMessage).color;
  Color get color2 => (segments['color2'] as ColorMessage).color;
  double get a => (segments['a'] as MessageFloat32).value;
  double get b => (segments['b'] as MessageFloat32).value;
  double get c => (segments['c'] as MessageFloat32).value;
  double get d => (segments['d'] as MessageFloat32).value;
}

class TwoColorWaveEffectMessage
    extends EffectMessage<TwoColorWaveEffectMessageBody> {
  TwoColorWaveEffectMessage(TwoColorWaveEffectMessageBody value)
      : super(Effects.twoColorWave.index, value);
}

class ParticleFillupEffectMessageBody extends SegmentMessage {
  ParticleFillupEffectMessageBody(
      {required int start,
      required int duration,
      required Color color,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color", ColorMessage(color));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color => (segments['color'] as ColorMessage).color;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class ParticleFillupEffectMessage extends EffectMessage<ParticleFillupEffectMessageBody> {
  ParticleFillupEffectMessage(ParticleFillupEffectMessageBody value)
      : super(Effects.particleFillup.index, value);
}

class BreatheEffectMessageBody extends SegmentMessage {
  BreatheEffectMessageBody(
      {required int start,
      required int duration,
      required Color fullColor,
      required Color fadeColor,
      required double fadeDuration,
      required double stayTime,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("fullColor", ColorMessage(fullColor));
    add("fadeColor", ColorMessage(fadeColor));
    add("fadeDuration", MessageFloat32(fadeDuration));
    add("stayTime", MessageFloat32(stayTime));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get fullColor => (segments['fullColor'] as ColorMessage).color;
  Color get fadeColor => (segments['fadeColor'] as ColorMessage).color;
  double get fadeDuration => (segments['fadeDuration'] as MessageFloat32).value;
  double get stayTime => (segments['stayTime'] as MessageFloat32).value;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class BreatheEffectMessage extends EffectMessage<BreatheEffectMessageBody> {
  BreatheEffectMessage(BreatheEffectMessageBody value)
      : super(Effects.breathe.index, value);
}

class StrobeEffectMessageBody extends SegmentMessage {
  StrobeEffectMessageBody(
      {required int start,
      required int duration,
      required Color color1,
      required Color color2,
      required int numberOfStrobes,
      required double delay,
      required int numberOfRepeats}) {
    add("start", MessageUint64(start));
    add("duration", MessageUint32(duration));
    add("color1", ColorMessage(color1));
    add("color2", ColorMessage(color2));
    add("numberOfStrobes", MessageUint8(numberOfStrobes));
    add("delay", MessageFloat32(delay));
    add("numberOfRepeats", MessageUint8(numberOfRepeats));
  }

  int get start => (segments['start'] as MessageUint64).value;
  int get duration => (segments['duration'] as MessageUint32).value;
  Color get color1 => (segments['color1'] as ColorMessage).color;
  Color get color2 => (segments['color2'] as ColorMessage).color;
  int get numberOfStrobes => (segments['numberOfStrobes'] as MessageUint8).value;
  double get delay => (segments['delay'] as MessageFloat32).value;
  int get numberOfRepeats =>
      (segments['numberOfRepeats'] as MessageUint8).value;
}

class StrobeEffectMessage extends EffectMessage<StrobeEffectMessageBody> {
  StrobeEffectMessage(StrobeEffectMessageBody value)
      : super(Effects.strobe.index, value);
}
