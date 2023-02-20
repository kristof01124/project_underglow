import 'message.dart';

class RGB {
  final int r, g, b;

  const RGB([this.r = 0, this.g = 0, this.b = 0]);
}

class RgbMessageData extends SegmentMessage {
  RgbMessageData(RGB rgb) {
    add('r', MessageUint8(rgb.r));
    add('g', MessageUint8(rgb.g));
    add('b', MessageUint8(rgb.b));
  }

  int get r => (segments['r'] as MessageUint8).value;
  int get g => (segments['g'] as MessageUint8).value;
  int get b => (segments['b'] as MessageUint8).value;
  RGB get color => RGB(r, g, b);
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
    return current.buildBuffer();
  }

  @override
  int size() {
    return current.size();
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

class BasicAnimationSwitch extends AnimationSwitchMessage {
  BasicAnimationSwitch()
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

class AnimationObjectSwitch extends AnimationSwitchMessage {
  AnimationObjectSwitch()
      : super([
          () => FillBasicAnimationMessage.empty(),
          () => RgbWaveBasicAnimationMessage.empty(),
          () => TransitionBasicAnimationMessage.empty(),
          () => ParticleFillupBasicAnimationMessage.empty()
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

class DynamicAnimationMessageBody extends SegmentMessage {
  DynamicAnimationMessageBody(
      [double delta = 0, double min = 0, double max = 0, int index = 0]) {
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

class DynamicAnimationMessage
    extends PairMessage<DynamicAnimationMessageBody, Message> {
  DynamicAnimationMessage.empty()
      : super(DynamicAnimationMessageBody(), AnimationBuilderMessage());
  DynamicAnimationMessage(DynamicAnimationMessageBody body, Message animation)
      : super(body, animation);
}

class AnimationLoopMessage
    extends PairMessage<MessageUint16, Message> {
  AnimationLoopMessage.empty() : super(MessageUint16(0), AnimationBuilderMessage());
  AnimationLoopMessage(MessageUint16 body, Message animation)
      : super(body, animation);
}

class FadeAnimationMessageBody extends SegmentMessage {
  FadeAnimationMessageBody([int fadeInDuration = 0, int fadeOutDuration = 0]) {
    add('fadeInDuration', MessageUint16(fadeInDuration));
    add('fadeOutDuration', MessageUint16(fadeOutDuration));
  }

  int get fadeInDuration => (segments['fadeInDuration'] as MessageUint16).value;
  int get fadeOutDuration =>
      (segments['fadeOutDuration'] as MessageUint16).value;
}

class FadeAnimationMessage
    extends PairMessage<FadeAnimationMessageBody, AnimationBuilderMessage> {
  FadeAnimationMessage()
      : super(FadeAnimationMessageBody(), AnimationBuilderMessage());
}

class SequentialAnimationMessage extends ListMessage {
  SequentialAnimationMessage()
      : super((int size) => List.filled(size, AnimationBuilderMessage()));
}

class AnimationGroupMessage extends SequentialAnimationMessage {}

class ReversedAnimationMessage extends AnimationBuilderMessage {}

class MirroredAnimationMessage extends AnimationBuilderMessage {}

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
  FillEffectMessage([int duration = 0, RGB color = const RGB(0, 0, 0)]) {
    add('duration', MessageUint32(duration));
    add('color', RgbMessageData(color));
  }

  int get duration => (segments['duration'] as MessageUint32).value;
  RGB get color => (segments['color'] as RgbMessageData).color;
}

class RunningEffectMessage extends FillEffectMessage {
  RunningEffectMessage([int duration = 0, RGB color = const RGB(0, 0, 0)])
      : super(duration, color);
}

class FillupEffectMessage extends FillEffectMessage {
  FillupEffectMessage([int duration = 0, RGB color = const RGB(0, 0, 0)])
      : super(duration, color);
}

class HarmonikaEffectMessage extends FillEffectMessage {
  HarmonikaEffectMessage([int duration = 0, RGB color = const RGB(0, 0, 0)])
      : super(duration, color);
}

class FilloutEffectMessage extends FillEffectMessage {
  FilloutEffectMessage([int duration = 0, RGB color = const RGB(0, 0, 0)])
      : super(duration, color);
}

class PewPewEffectMessage extends SegmentMessage {
  PewPewEffectMessage(
      [int duration = 0,
      RGB color = const RGB(0, 0, 0),
      double length = 0,
      double gap = 0,
      int n = 0]) {
    add('duration', MessageUint32(duration));
    add('color', RgbMessageData(color));
    add('length', MessageFloat32(length));
    add('gap', MessageFloat32(gap));
    add('n', MessageUint16(n));
  }

  int get duration => (segments['duration'] as MessageUint32).value;
  RGB get color => (segments['color'] as RgbMessageData).color;
  double get length => (segments['length'] as MessageFloat32).value;
  double get gap => (segments['gap'] as MessageFloat32).value;
  int get n => (segments['n'] as MessageUint32).value;
}

class RgbWaveEffectMessage extends SegmentMessage {
  RgbWaveEffectMessage([int duration = 0, double speed = 0]) {
    add('duration', MessageUint32(duration));
    add('speed', MessageFloat32(speed));
  }

  int get duration => (segments['duration'] as MessageUint32).value;
  double get speed => (segments['speed'] as MessageFloat32).value;
}

class RgbCycleEffectMessage extends SegmentMessage {
  RgbCycleEffectMessage([int duration = 0]) {
    add('duration', MessageUint32(duration));
  }

  int get duration => (segments['duration'] as MessageUint32).value;
}

class TwoColorWaveEffectMessage extends SegmentMessage {
  TwoColorWaveEffectMessage(
      [int duration = 0,
      RGB color1 = const RGB(0, 0, 0),
      RGB color2 = const RGB(0, 0, 0),
      double a = 0,
      double b = 0,
      double c = 0,
      double d = 0]) {
    add('duration', MessageUint32(duration));
    add('color1', RgbMessageData(color1));
    add('color2', RgbMessageData(color2));
    add('a', MessageFloat32(a));
    add('b', MessageFloat32(b));
    add('c', MessageFloat32(c));
    add('d', MessageFloat32(d));
  }

  int get duration => (segments['duration'] as MessageUint32).value;
  RGB get color1 => (segments['color1'] as RgbMessageData).color;
  RGB get color2 => (segments['color2'] as RgbMessageData).color;
  double get a => (segments['a'] as MessageFloat32).value;
  double get b => (segments['b'] as MessageFloat32).value;
  double get c => (segments['c'] as MessageFloat32).value;
  double get d => (segments['d'] as MessageFloat32).value;
}

class ParticleFillupEffectMessage extends FillEffectMessage {
  ParticleFillupEffectMessage([int duration = 0, RGB color = const RGB(0, 0, 0)])
      : super(duration, color);
}

class BreatheEffectMessage extends SegmentMessage {
  BreatheEffectMessage(
      [int duration = 0, RGB color = const RGB(0, 0, 0), int fadeTime = 0]) {
    add('duration', MessageUint32(duration));
    add('color', RgbMessageData(color));
    add('fadeTime', MessageUint32(fadeTime));
  }

  int get duration => (segments['duration'] as MessageUint32).value;
  RGB get color => (segments['color'] as RgbMessageData).color;
  int get fadeTime => (segments['fadeTime'] as MessageUint32).value;
}

enum BasicAnimationType {
  basicFill,
  basicRgbWave,
  basicTransition,
  basicParticleFillup
}

class BasicFillState extends SegmentMessage {
  BasicFillState([
    double start = 0,
    double length = 0,
    RGB color = const RGB(0, 0, 0),
  ]) {
    add('start', MessageFloat32(start));
    add('length', MessageFloat32(length));
    add('color', RgbMessageData(color));
  }

  double get start => (segments['start'] as MessageFloat32).value;
  double get length => (segments['length'] as MessageFloat32).value;
  RGB get color => (segments['color'] as RgbMessageData).color;
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
      RGB color1 = const RGB(0, 0, 0),
      RGB color2 = const RGB(0, 0, 0)]) {
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
  RGB get color1 => (segments['color1'] as RgbMessageData).color;
  RGB get color2 => (segments['color2'] as RgbMessageData).color;
}

class BasicParticleFillupState extends BasicFillState {
  BasicParticleFillupState([
    double start = 0,
    double length = 0,
    RGB color = const RGB(0, 0, 0),
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

class DynamicAnimationMessageBuilder extends SegmentMessage {
  DynamicAnimationMessageBuilder(DynamicAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(AnimationObjectType.dynamicAnimation.index)
        ]));
    add('animatoin', animation);
  }
}

class AnimationLoopMessageBuilder extends SegmentMessage {
  AnimationLoopMessageBuilder(AnimationLoopMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(AnimationObjectType.animationLoop.index)
        ]));
    add('animation', animation);
  }
}

class FadeAnimationMessageBuilder extends SegmentMessage {
  FadeAnimationMessageBuilder(FadeAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(AnimationObjectType.fadeAnimation.index)
        ]));
    add('animation', animation);
  }
}

class AnimationGroupMessageBuilder extends SegmentMessage {
  AnimationGroupMessageBuilder(AnimationGroupMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(AnimationObjectType.animationGroup.index)
        ]));
    add('animation', animation);
  }
}

class SequentialAnimationBuilder extends SegmentMessage {
  SequentialAnimationBuilder(SequentialAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(AnimationObjectType.sequentialAnimation.index)
        ]));
    add('animation', animation);
  }
}

class ReversedAnimationBuilder extends SegmentMessage {
  ReversedAnimationBuilder(ReversedAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(AnimationObjectType.reversedAnimation.index)
        ]));
    add('animation', animation);
  }
}

class MirroredAnimationBuilder extends SegmentMessage {
  MirroredAnimationBuilder(MirroredAnimationMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.animationObject.index),
          MessageUint16(AnimationObjectType.mirroredAnimation.index)
        ]));
    add('animation', animation);
  }
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

class FillEffectMessageBuilder extends SegmentMessage {
  FillEffectMessageBuilder(FillEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.fill.index)
        ]));
    add('animation', animation);
  }
}
class RunningEffectMessageBuilder extends SegmentMessage {
  RunningEffectMessageBuilder(RunningEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.running.index)
        ]));
    add('animation', animation);
    }
}
class FillupEffectMessageBuilder extends SegmentMessage {
  FillupEffectMessageBuilder(FillupEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.fillup.index)
        ]));
    add('animation', animation);
    }
}
class FilloutEffectMessageBuilder extends SegmentMessage {
FilloutEffectMessageBuilder(FilloutEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.fillout.index)
        ]));
    add('animation', animation);
    }
}
class HarmonikaEffectMessageBuilder extends SegmentMessage {
HarmonikaEffectMessageBuilder(HarmonikaEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.harmonika.index)
        ]));
    add('animation', animation);
    }
}
class PewPewEffectMessageBuilder extends SegmentMessage {
PewPewEffectMessageBuilder(PewPewEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.pewPew.index)
        ]));
    add('animation', animation);
    }
}
class RgbWaveEffectMessageBuilder extends SegmentMessage {
RgbWaveEffectMessageBuilder(RgbWaveEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.rgbWave.index)
        ]));
    add('animation', animation);
    }
}
class RgbCycleEffectMessageBuilder extends SegmentMessage {
RgbCycleEffectMessageBuilder(RgbCycleEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.rgbCycle.index)
        ]));
    add('animation', animation);
    }
}
class TwoColorWaveEffectMessageBuilder extends SegmentMessage {
TwoColorWaveEffectMessageBuilder(TwoColorWaveEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.twoColorWave.index)
        ]));
    add('animation', animation);
    }
}
class ParticleFillupEffectMessageBuilder extends SegmentMessage {
ParticleFillupEffectMessageBuilder(ParticleFillupEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.particleFillup.index)
        ]));
    add('animation', animation);
    }
}
class BreatheEffectMessageBuilder extends SegmentMessage {
BreatheEffectMessageBuilder(BreatheEffectMessage animation) {
    add(
        'index',
        MessageArray([
          MessageUint16(AnimationType.effect.index),
          MessageUint16(EffectType.breathe.index)
        ]));
    add('animation', animation);
    }
}