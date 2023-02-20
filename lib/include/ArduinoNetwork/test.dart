import 'animation_message.dart';

void main(List<String> arguments) {
  DynamicAnimationMessageBuilder msg = DynamicAnimationMessageBuilder(
    DynamicAnimationMessage(
      DynamicAnimationMessageBody(
        1.0,
        1.0,
        1.0,
        1
      ),
      BreatheEffectMessageBuilder(
        BreatheEffectMessage(
          100, 
          const RGB(98, 43, 56), 
          85
        )
      )
    )
  );
  print(BreatheEffectMessageBuilder(
        BreatheEffectMessage(
          100, 
          const RGB(98, 43, 56), 
          85
        )
      ).buildBuffer());
}
