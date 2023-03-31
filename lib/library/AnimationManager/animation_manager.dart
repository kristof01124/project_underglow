import 'package:learning_dart/library/AnimationCreator/single_animation_creator.dart';

enum AnimationType {
  genericAnimation,
  indexAnimation,
  visualizerAnimation,
  // etc..
}

class AnimationManager {
  Map<AnimationType, List<SimpleAnimationCreator>> animations = {};

  List<SimpleAnimationCreator> getAnimations(List<AnimationType> types) {
    Set<SimpleAnimationCreator> out = {};
    for (var type in types) {
      out.addAll(animations[type] ?? []);
    }
    return out.toList();
  }
}
