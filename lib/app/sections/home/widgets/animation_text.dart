import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/providers/public_data_provider.dart';

// Dynamic animation text lists that use Firebase content
List<TyperAnimatedText> getDesktopList(BuildContext context) {
  final dataProvider = Provider.of<PublicDataProvider>(context, listen: false);
  return [
    TyperAnimatedText(
      dataProvider.getContent('animation_txt1', defaultValue: ' Mobile Application Developer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 32)
    ),
    TyperAnimatedText(
      dataProvider.getContent('animation_txt2', defaultValue: ' UI/UX Designer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 32)
    ),
    TyperAnimatedText(
      dataProvider.getContent('animation_txt3', defaultValue: ' Web Developer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 32)
    )
  ];
}

List<TyperAnimatedText> getTabList(BuildContext context) {
  final dataProvider = Provider.of<PublicDataProvider>(context, listen: false);
  return [
    TyperAnimatedText(
      dataProvider.getContent('animation_txt1', defaultValue: ' Mobile Application Developer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 20)
    ),
    TyperAnimatedText(
      dataProvider.getContent('animation_txt2', defaultValue: ' UI/UX Designer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 20)
    ),
    TyperAnimatedText(
      dataProvider.getContent('animation_txt3', defaultValue: ' Web Developer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 20)
    )
  ];
}

List<TyperAnimatedText> getMobileList(BuildContext context) {
  final dataProvider = Provider.of<PublicDataProvider>(context, listen: false);
  return [
    TyperAnimatedText(
      dataProvider.getContent('animation_txt1', defaultValue: ' Mobile Application Developer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 16)
    ),
    TyperAnimatedText(
      dataProvider.getContent('animation_txt2', defaultValue: ' UI/UX Designer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 16)
    ),
    TyperAnimatedText(
      dataProvider.getContent('animation_txt3', defaultValue: ' Web Developer'),
      speed: const Duration(milliseconds: 50),
      textStyle: AppText.h2!.copyWith(fontSize: 16)
    )
  ];
}
