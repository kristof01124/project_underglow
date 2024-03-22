import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:learning_dart/library/ArduinoNetwork/message.dart';
import 'package:learning_dart/library/ledcontroller/animation_objects.dart';
import 'package:learning_dart/library/ledcontroller/basic_animations.dart';
import 'package:learning_dart/library/ledcontroller/effects.dart';

abstract class ArduinoAnimation extends Message {}

class ColorMessage extends SegmentMessage {
  Color value;

  ColorMessage(this.value) {
    add('red', MessageUint8(value.red));
    add('green', MessageUint8(value.green));
    add('blue', MessageUint8(value.blue));
  }

  int get red => (segments['red'] as MessageUint8).value;
  int get green => (segments['green'] as MessageUint8).value;
  int get blue => (segments['blue'] as MessageUint8).value;
  Color get color => Color.fromARGB(255, red, green, blue);
}

enum AnimationType { effect, animationObject, basicAnimation }

class AnimationMessage extends Message {
  Message? animation;

  AnimationMessage({this.animation});

  @override
  void build(List<int> buffer) {
    var indices = PairMessage(MessageUint16(0), MessageUint16(0));
    indices.build(buffer);
    int firstIndex = indices.first.value, secondIndex = indices.second.value;
    animation = null;
    if (firstIndex == AnimationType.effect.index) {
      buildEffect(buffer, secondIndex);
    }
    if (firstIndex == AnimationType.animationObject.index) {
      buildAnimationObject(buffer, secondIndex);
    }
    if (firstIndex == AnimationType.basicAnimation.index) {
      buildBasicAnimation(buffer, secondIndex);
    }
    animation?.build(buffer);
  }

  void buildEffect(List<int> buffer, int index) {
    if (index == Effects.fill.index) {
      animation = FillEffectMessage(
        FillEffectMessageBody(
          color: Colors.black,
          duration: 0,
          start: 0,
        ),
      );
    }
    if (index == Effects.running.index) {
      animation = RunningEffectMessage(
        RunningEffectMessageBody(
          color: Colors.black,
          start: 0,
          duration: 0,
          numberOfRepeats: 0,
        ),
      );
    }
    if (index == Effects.fillup.index) {
      animation = FillupEffectMessage(
        FillupEffectMessageBody(
          color: Colors.black,
          start: 0,
          duration: 0,
          numberOfRepeats: 0,
        ),
      );
    }
    if (index == Effects.harmonika.index) {
      animation = HarmonikaEffectMessage(
        HarmonikaEffectMessageBody(
          color: Colors.black,
          start: 0,
          duration: 0,
          numberOfRepeats: 0,
        ),
      );
    }
    if (index == Effects.fillout.index) {
      animation = FilloutEffectMessage(
        FilloutEffectMessageBody(
            color: Colors.black, duration: 0, start: 0, numberOfRepeats: 0),
      );
    }
    if (index == Effects.pewPew.index) {
      animation = PewPewEffectMessage(
        PewPewEffectMessageBody(
          color: Colors.black,
          start: 0,
          duration: 0,
          length: 0,
          gap: 0,
          n: 0,
          numberOfRepeats: 0,
        ),
      );
    }
    if (index == Effects.rgbWave.index) {
      animation = RgbWaveEffectMessage(
        RgbWaveEffectMessageBody(
          duration: 0,
          speed: 0,
          start: 0,
        ),
      );
    }
    if (index == Effects.rgbCycle.index) {
      animation = RgbCycleEffectMessage(
        RgbCycleEffectMessageBody(
          duration: 0,
          start: 0,
        ),
      );
    }
    if (index == Effects.twoColorWave.index) {
      animation = TwoColorWaveEffectMessage(
        TwoColorWaveEffectMessageBody(
          start: 0,
          duration: 0,
          color1: Colors.black,
          color2: Colors.black,
          a: 0,
          b: 0,
          c: 0,
          d: 0,
        ),
      );
    }
    if (index == Effects.particleFillup.index) {
      animation = ParticleFillupEffectMessage(
        ParticleFillupEffectMessageBody(
          color: Colors.black,
          start: 0,
          duration: 0,
          numberOfRepeats: 0,
        ),
      );
    }
    if (index == Effects.breathe.index) {
      animation = BreatheEffectMessage(
        BreatheEffectMessageBody(
          duration: 0,
          start: 0,
          fadeColor: Colors.black,
          fullColor: Colors.black,
          fadeDuration: 0,
          stayTime: 0,
          numberOfRepeats: 0,
        ),
      );
    }
    if (index == Effects.strobe.index) {
      animation = StrobeEffectMessage(
        StrobeEffectMessageBody(
          color1: Colors.black,
          color2: Colors.black,
          start: 0,
          duration: 0,
          numberOfRepeats: 0,
          numberOfStrobes: 0,
          delay: 0,
        ),
      );
    }
  }

  void buildBasicAnimation(List<int> buffer, int index) {
    if (index == BasicAnimations.basicFill.index) {
      animation = FillBasicAnimationMessage(
        FillBasicAnimationMessageBody(
          duration: 0,
          start: 0,
          from: FillBasicAnimationMessageState(
            color: Colors.black,
            length: 0,
            start: 0,
          ),
          to: FillBasicAnimationMessageState(
            color: Colors.black,
            length: 0,
            start: 0,
          ),
        ),
      );
    }
    if (index == BasicAnimations.basicParticleFillup.index) {
      animation = ParticleFillupBasicAnimationMessage(
        ParticleFillupBasicAnimationMessageBody(
          duration: 0,
          start: 0,
          from: ParticleFillupBasicAnimationMessageState(
            color: Colors.black,
            length: 0,
            start: 0,
          ),
          to: ParticleFillupBasicAnimationMessageState(
            color: Colors.black,
            length: 0,
            start: 0,
          ),
        ),
      );
    }
    if (index == BasicAnimations.basicTransition.index) {
      animation = TransitionBasicAnimationMessage(
        TransitionBasicAnimationMessageBody(
          duration: 0,
          start: 0,
          from: TransitionBasicAnimationMessageState(
            start: 0,
            length: 0,
            n: 0,
            gap: 0,
            color1: Colors.black,
            color2: Colors.black,
          ),
          to: TransitionBasicAnimationMessageState(
            start: 0,
            length: 0,
            n: 0,
            gap: 0,
            color1: Colors.black,
            color2: Colors.black,
          ),
        ),
      );
    }
    if (index == BasicAnimations.basicRgbWave.index) {
      animation = RgbWaveBasicAnimationMessage(
        RgbWaveBasicAnimationMessageBody(
          duration: 0,
          start: 0,
          from: RgbWaveBasicAnimationMessageState(
            start: 0,
            length: 0,
            startValue: 0,
            transitionSpeed: 0,
          ),
          to: RgbWaveBasicAnimationMessageState(
            start: 0,
            length: 0,
            startValue: 0,
            transitionSpeed: 0,
          ),
        ),
      );
    }
  }

  void buildAnimationObject(List<int> buffer, int index) {
    if (index == AnimationObjects.animationGroup.index) {
      animation = AnimationGroupMessage(
        AnimationGroupMessageBody(
          start: 0,
        ),
      );
    }
    if (index == AnimationObjects.sequentialAnimation.index) {
      animation = SequentialAnimationMessage(
        AnimationGroupMessageBody(
          start: 0,
        ),
      );
    }
    if (index == AnimationObjects.reversedAnimation.index) {
      animation = ReversedAnimationMessage(
        AnimationMessage(),
      );
    }
    if (index == AnimationObjects.mirroredAnimation.index) {
      animation = MirroredAnimationMessage(
        AnimationMessage(),
      );
    }
    if (index == AnimationObjects.fadeAnimation.index) {
      animation = FadeAnimationMessageBody(
        fadeInDuration: 0,
        fadeOutDuration: 0,
        animation: AnimationMessage(),
      );
    }
    if (index == AnimationObjects.animationLoop.index) {
      animation = AnimationLoopMessage(
        AnimationLoopMessageBody(
          repeats: 0,
          animation: AnimationMessage(),
        ),
      );
    }
    if (index == AnimationObjects.delayedAnimation.index) {
      animation = DelayedAnimationAnimationMessage(
        DelayedAnimationMessageBody(
          delay: 0,
          animation: AnimationMessage(),
        ),
      );
    }
  }

  @override
  List<int> buildBuffer() {
    return animation?.buildBuffer() ?? [];
  }

  @override
  int size() {
    return animation?.size() ?? 0;
  }
}
