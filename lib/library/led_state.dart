class PlayingAnimation {
  final String name;
  final List<int> buffer;
  const PlayingAnimation(this.name, this.buffer);
}

class LedState {
  bool powerState;
  int brightness;
  PlayingAnimation currentlyPlayingAnimation;

  LedState(this.powerState, this.brightness, this.currentlyPlayingAnimation);
}