import 'package:flutter/services.dart';

import '../ArduinoNetwork/message.dart';

class RgbMessageData extends SegmentMessage {
  RgbMessageData(Color color) {
    add('r', MessageUint8(color.red));
    add('g', MessageUint8(color.green));
    add('b', MessageUint8(color.blue));
  }

  int get r => (segments['r'] as MessageUint8).value;
  int get g => (segments['g'] as MessageUint8).value;
  int get b => (segments['b'] as MessageUint8).value;
  Color get color => Color.fromARGB(255, r, g, b);
}

class AnimationSwitchMessage extends Message {
  Message current = MessageUint16(0); // just a placeholder

  List<Message Function()> options;
  MessageUint16 index = MessageUint16(0);

  AnimationSwitchMessage(this.options);

  @override
  void build(List<int> buffer) {
    index.build(buffer);
    current = options[index.value]();
    current.build(buffer.sublist(index.size()));
  }

  @override
  List<int> buildBuffer() {
    List<int> out = index.buildBuffer();
    out.addAll(current.buildBuffer());
    return out;
  }

  @override
  int size() {
    return current.size() + index.size();
  }
}

enum AnimationType { animationObject, effect, basicAnimation }

class AnimationBuilderMessage extends AnimationSwitchMessage {
  AnimationBuilderMessage()
      : super([
          () => AnimationObjectSwitch(),
          () => EffectSwitch(),
          () => BasicAnimationSwitch()
        ]);
}

enum AnimationObjectType {
  animationGroup,
  dynamicAnimation,
  sequentialAnimation,
  reversedAnimation,
  animationLoop,
  fadeAnimation,
  mirroredAnimation
}

class AnimationGroupMessage extends SequentialAnimationMessage {}

class DynamicAnimationMessageBody extends SegmentMessage {
  DynamicAnimationMessageBody(
      {double delta = 0, double min = 0, double max = 0, int index = 0}) {
    add('delta', MessageFloat32(delta));
    add('min', MessageFloat32(min));
    add('max', MessageFloat32(max));
    add('index', MessageUint16(index));
  }

  double get delta => (segments['delta'] as MessageFloat32).value;
  double get min => (segments['min'] as MessageFloat32).value;
  double get max => (segments['max'] as MessageFloat32).value;
  int get index => (segments['index'] as MessageUint16).value;
}

class SequentialAnimationMessage extends ListMessage {
  SequentialAnimationMessage()
      : super((int size) => List.filled(size, AnimationBuilderMessage()));
}

class ReversedAnimationMessage extends AnimationBuilderMessage {}

class AnimationLoopMessage extends PairMessage<MessageUint16, Message> {
  AnimationLoopMessage.empty()
      : super(MessageUint16(0), AnimationBuilderMessage());
  AnimationLoopMessage(
      {required MessageUint16 body, required Message animation})
      : super(body, animation);
}

class FadeAnimationMessageBody extends SegmentMessage {
  FadeAnimationMessageBody({int fadeInDuration = 0, int fadeOutDuration = 0}) {
    add('fadeInDuration', MessageUint16(fadeInDuration));
    add('fadeOutDuration', MessageUint16(fadeOutDuration));
  }

  int get fadeInDuration => (segments['fadeInDuration'] as MessageUint16).value;
  int get fadeOutDuration =>
      (segments['fadeOutDuration'] as MessageUint16).value;
}

class MirroredAnimationMessage extends AnimationBuilderMessage {}

class DynamicAnimationMessage
    extends PairMessage<DynamicAnimationMessageBody, Message> {
  DynamicAnimationMessage.empty()
      : super(DynamicAnimationMessageBody(), AnimationBuilderMessage());
  DynamicAnimationMessage(DynamicAnimationMessageBody body, Message animation)
      : super(body, animation);
}

class FadeAnimationMessage
    extends PairMessage<FadeAnimationMessageBody, AnimationBuilderMessage> {
  FadeAnimationMessage()
      : super(FadeAnimationMessageBody(), AnimationBuilderMessage());
}

class AnimationMessageBuilder extends SegmentMessage {
  AnimationMessageBuilder(
      {required Message header,
      required Message animationData,
      required Message animation}) {
    add('header', header);
    add('animationData', animationData);
    add('animation', animation);
  }
}

class GenericAnimationData extends SegmentMessage {
  GenericAnimationData({required int start, required int duration}) {
    add('start', MessageUint64(start));
    add('duration', MessageUint64(duration));
  }
}

class DynamicAnimationMessageBuilder extends AnimationMessageBuilder {
  DynamicAnimationMessageBuilder(
      {required DynamicAnimationMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.animationObject.index),
              MessageUint16(AnimationObjectType.dynamicAnimation.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class AnimationLoopMessageBuilder extends AnimationMessageBuilder {
  AnimationLoopMessageBuilder(
      {required AnimationLoopMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.animationObject.index),
              MessageUint16(AnimationObjectType.animationLoop.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class FadeAnimationMessageBuilder extends AnimationMessageBuilder {
  FadeAnimationMessageBuilder(
      {required FadeAnimationMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.animationObject.index),
              MessageUint16(AnimationObjectType.fadeAnimation.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class AnimationGroupMessageBuilder extends AnimationMessageBuilder {
  AnimationGroupMessageBuilder(
      {required AnimationGroupMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.animationObject.index),
              MessageUint16(AnimationObjectType.animationGroup.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class SequentialAnimationBuilder extends AnimationMessageBuilder {
  SequentialAnimationBuilder(
      {required SequentialAnimationMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.animationObject.index),
              MessageUint16(AnimationObjectType.sequentialAnimation.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class ReversedAnimationBuilder extends AnimationMessageBuilder {
  ReversedAnimationBuilder(
      {required ReversedAnimationMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.animationObject.index),
              MessageUint16(AnimationObjectType.reversedAnimation.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class MirroredAnimationBuilder extends AnimationMessageBuilder {
  MirroredAnimationBuilder(
      {required MirroredAnimationMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.animationObject.index),
              MessageUint16(AnimationObjectType.mirroredAnimation.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class AnimationObjectSwitch extends AnimationSwitchMessage {
  AnimationObjectSwitch()
      : super([
          () => AnimationGroupMessage(),
          () => DynamicAnimationMessage.empty(),
          () => SequentialAnimationMessage(),
          () => ReversedAnimationMessage(),
          () => AnimationLoopMessage.empty(),
          () => FadeAnimationMessage(),
          () => MirroredAnimationMessage()
        ]);
}

enum EffectType {
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
  breathe
}

class FillEffectMessage extends SegmentMessage {
  FillEffectMessage({Color color = const Color.fromARGB(255, 0, 0, 0)}) {
    add('color', RgbMessageData(color));
  }

  Color get color => (segments['color'] as RgbMessageData).color;
}

class RunningEffectMessage extends FillEffectMessage {
  RunningEffectMessage({Color color = const Color.fromARGB(255, 0, 0, 0)})
      : super(color: color);
}

class FillupEffectMessage extends FillEffectMessage {
  FillupEffectMessage({Color color = const Color.fromARGB(255, 0, 0, 0)})
      : super(color: color);
}

class HarmonikaEffectMessage extends FillEffectMessage {
  HarmonikaEffectMessage({Color color = const Color.fromARGB(255, 0, 0, 0)})
      : super(color: color);
}

class FilloutEffectMessage extends FillEffectMessage {
  FilloutEffectMessage({Color color = const Color.fromARGB(255, 0, 0, 0)})
      : super(color: color);
}

class PewPewEffectMessage extends SegmentMessage {
  PewPewEffectMessage(
      {Color color = const Color.fromARGB(255, 0, 0, 0),
      double length = 0,
      double gap = 0,
      int n = 0}) {
    add('color', RgbMessageData(color));
    add('length', MessageFloat32(length));
    add('gap', MessageFloat32(gap));
    add('n', MessageUint16(n));
  }

  Color get color => (segments['color'] as RgbMessageData).color;
  double get length => (segments['length'] as MessageFloat32).value;
  double get gap => (segments['gap'] as MessageFloat32).value;
  int get n => (segments['n'] as MessageUint32).value;
}

class RgbWaveEffectMessage extends SegmentMessage {
  RgbWaveEffectMessage({double speed = 0}) {
    add('speed', MessageFloat32(speed));
  }
  double get speed => (segments['speed'] as MessageFloat32).value;
}

class RgbCycleEffectMessage extends EmptyMessage {}

class TwoColorWaveEffectMessage extends SegmentMessage {
  TwoColorWaveEffectMessage(
      {Color color1 = const Color.fromARGB(255, 0, 0, 0),
      Color color2 = const Color.fromARGB(255, 0, 0, 0),
      double a = 0,
      double b = 0,
      double c = 0,
      double d = 0}) {
    add('color1', RgbMessageData(color1));
    add('color2', RgbMessageData(color2));
    add('a', MessageFloat32(a));
    add('b', MessageFloat32(b));
    add('c', MessageFloat32(c));
    add('d', MessageFloat32(d));
  }
  Color get color1 => (segments['color1'] as RgbMessageData).color;
  Color get color2 => (segments['color2'] as RgbMessageData).color;
  double get a => (segments['a'] as MessageFloat32).value;
  double get b => (segments['b'] as MessageFloat32).value;
  double get c => (segments['c'] as MessageFloat32).value;
  double get d => (segments['d'] as MessageFloat32).value;
}

class ParticleFillupEffectMessage extends FillEffectMessage {
  ParticleFillupEffectMessage(
      {Color color = const Color.fromARGB(255, 0, 0, 0)})
      : super(color: color);
}

class BreatheEffectMessage extends SegmentMessage {
  BreatheEffectMessage(
      {Color color = const Color.fromARGB(255, 0, 0, 0), int fadeTime = 0}) {
    add('color', RgbMessageData(color));
    add('fadeTime', MessageUint32(fadeTime));
  }

  Color get color => (segments['color'] as RgbMessageData).color;
  int get fadeTime => (segments['fadeTime'] as MessageUint32).value;
}

class FillEffectMessageBuilder extends AnimationMessageBuilder {
  FillEffectMessageBuilder(
      {required FillEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.fill.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class RunningEffectMessageBuilder extends AnimationMessageBuilder {
  RunningEffectMessageBuilder(
      {required RunningEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.running.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class FillupEffectMessageBuilder extends AnimationMessageBuilder {
  FillupEffectMessageBuilder(
      {required FillupEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.fillup.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class FilloutEffectMessageBuilder extends AnimationMessageBuilder {
  FilloutEffectMessageBuilder(
      {required FilloutEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.fillout.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class HarmonikaEffectMessageBuilder extends AnimationMessageBuilder {
  HarmonikaEffectMessageBuilder(
      {required HarmonikaEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.harmonika.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class PewPewEffectMessageBuilder extends AnimationMessageBuilder {
  PewPewEffectMessageBuilder(
      {required PewPewEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.pewPew.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class RgbWaveEffectMessageBuilder extends AnimationMessageBuilder {
  RgbWaveEffectMessageBuilder(
      {required RgbWaveEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.rgbWave.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class RgbCycleEffectMessageBuilder extends AnimationMessageBuilder {
  RgbCycleEffectMessageBuilder(
      {required RgbCycleEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.rgbCycle.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class TwoColorWaveEffectMessageBuilder extends AnimationMessageBuilder {
  TwoColorWaveEffectMessageBuilder(
      {required TwoColorWaveEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.twoColorWave.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class ParticleFillupEffectMessageBuilder extends AnimationMessageBuilder {
  ParticleFillupEffectMessageBuilder(
      {required ParticleFillupEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.particleFillup.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class BreatheEffectMessageBuilder extends AnimationMessageBuilder {
  BreatheEffectMessageBuilder(
      {required BreatheEffectMessage animation,
      required GenericAnimationData data})
      : super(
          header: MessageArray(
            [
              MessageUint16(AnimationType.effect.index),
              MessageUint16(EffectType.breathe.index)
            ],
          ),
          animationData: data,
          animation: animation,
        );
}

class EffectSwitch extends AnimationSwitchMessage {
  EffectSwitch()
      : super([
          () => FillEffectMessage(),
          () => RunningEffectMessage(),
          () => FillupEffectMessage(),
          () => HarmonikaEffectMessage(),
          () => FilloutEffectMessage(),
          () => PewPewEffectMessage(),
          () => RgbWaveEffectMessage(),
          () => RgbCycleEffectMessage(),
          () => TwoColorWaveEffectMessage(),
          () => ParticleFillupEffectMessage(),
          () => BreatheEffectMessage()
        ]);
}

enum BasicAnimationType {
  basicFill,
  basicRgbWave,
  basicTransition,
  basicParticleFillup
}

// TODO: Implement basic animation fully

class BasicAnimationSwitch extends AnimationSwitchMessage {
  BasicAnimationSwitch()
      : super([
          () => FillBasicAnimationMessage.empty(),
          () => RgbWaveBasicAnimationMessage.empty(),
          () => TransitionBasicAnimationMessage.empty(),
          () => ParticleFillupBasicAnimationMessage.empty()
        ]);
}

class BasicFillState extends SegmentMessage {
  BasicFillState([
    double start = 0,
    double length = 0,
    Color color = const Color.fromARGB(255, 0, 0, 0),
  ]) {
    add('start', MessageFloat32(start));
    add('length', MessageFloat32(length));
    add('color', RgbMessageData(color));
  }

  double get start => (segments['start'] as MessageFloat32).value;
  double get length => (segments['length'] as MessageFloat32).value;
  Color get color => (segments['color'] as RgbMessageData).color;
}

class BasicRgbWaveState extends SegmentMessage {
  BasicRgbWaveState([
    double start = 0,
    double length = 0,
    double transitionSpeed = 0,
  ]) {
    add('start', MessageFloat32(start));
    add('length', MessageFloat32(length));
    add('transitionSpeed', MessageFloat32(transitionSpeed));
  }

  double get start => (segments['start'] as MessageFloat32).value;
  double get length => (segments['length'] as MessageFloat32).value;
  double get transitionSpeed =>
      (segments['transitionSpeed'] as MessageFloat32).value;
}

class BasicTransitionState extends SegmentMessage {
  BasicTransitionState(
      [double start = 0,
      double length = 0,
      int n = 0,
      double gap = 0,
      Color color1 = const Color.fromARGB(255, 0, 0, 0),
      Color color2 = const Color.fromARGB(255, 0, 0, 0)]) {
    add('start', MessageFloat32(start));
    add('length', MessageFloat32(length));
    add('n', MessageUint8(n));
    add('gap', MessageFloat32(gap));
    add('color1', RgbMessageData(color1));
    add('color2', RgbMessageData(color2));
  }

  double get start => (segments['start'] as MessageFloat32).value;
  double get length => (segments['length'] as MessageFloat32).value;
  int get n => (segments['n'] as MessageUint8).value;
  double get gap => (segments['gap'] as MessageFloat32).value;
  Color get color1 => (segments['color1'] as RgbMessageData).color;
  Color get color2 => (segments['color2'] as RgbMessageData).color;
}

class BasicParticleFillupState extends BasicFillState {
  BasicParticleFillupState([
    double start = 0,
    double length = 0,
    Color color = const Color.fromARGB(255, 0, 0, 0),
  ]) : super(start, length, color);
}

class BasicAnimation<T extends SegmentMessage> extends PairMessage<T, T> {
  BasicAnimation(T first, T second) : super(first, second);
}

class FillBasicAnimationMessage extends BasicAnimation<BasicFillState> {
  FillBasicAnimationMessage(BasicFillState first, BasicFillState second)
      : super(first, second);
  FillBasicAnimationMessage.empty() : super(BasicFillState(), BasicFillState());
}

class RgbWaveBasicAnimationMessage extends BasicAnimation<BasicRgbWaveState> {
  RgbWaveBasicAnimationMessage(
      BasicRgbWaveState first, BasicRgbWaveState second)
      : super(first, second);
  RgbWaveBasicAnimationMessage.empty()
      : super(BasicRgbWaveState(), BasicRgbWaveState());
}

class TransitionBasicAnimationMessage
    extends BasicAnimation<BasicTransitionState> {
  TransitionBasicAnimationMessage(
      BasicTransitionState first, BasicTransitionState second)
      : super(first, second);
  TransitionBasicAnimationMessage.empty()
      : super(BasicTransitionState(), BasicTransitionState());
}

class ParticleFillupBasicAnimationMessage
    extends BasicAnimation<BasicParticleFillupState> {
  ParticleFillupBasicAnimationMessage(
      BasicParticleFillupState first, BasicParticleFillupState second)
      : super(first, second);
  ParticleFillupBasicAnimationMessage.empty()
      : super(BasicParticleFillupState(), BasicParticleFillupState());
}

class FillBasicAnimationMessageBuilder extends SegmentMessage {
  FillBasicAnimationMessageBuilder(FillBasicAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(BasicAnimationType.basicFill.index)
        ]));
    add('animation', animation);
  }
}

class ParticleFillupBasicAnimationMessageBuilder extends SegmentMessage {
  ParticleFillupBasicAnimationMessageBuilder(
      ParticleFillupBasicAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(BasicAnimationType.basicParticleFillup.index)
        ]));
    add('animation', animation);
  }
}

class RgbWaveBasicAnimationMessageBuilder extends SegmentMessage {
  RgbWaveBasicAnimationMessageBuilder(RgbWaveBasicAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(BasicAnimationType.basicRgbWave.index)
        ]));
    add('animation', animation);
  }
}

class TransitionBasicAnimationMessageBuilder extends SegmentMessage {
  TransitionBasicAnimationMessageBuilder(
      TransitionBasicAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(BasicAnimationType.basicTransition.index)
        ]));
    add('animation', animation);
  }
}
