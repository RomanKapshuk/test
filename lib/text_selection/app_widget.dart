import 'dart:ui';

import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatelessWidget {
  HomeWidget({super.key});
  final controller = RichTextFieldController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextField(
          controller: controller,
          maxLines: 5,
          onChanged: (value) {
            // final val = TextSelection.collapsed(offset: controller.text.length);
            // controller.selection = val;
          },
        ),
      ),
    );
  }
}

class RichTextFieldController extends TextEditingController {
  late final Pattern pattern;
  final enterSymbol = String.fromCharCode(0x23CE);

  String pureText = '';
  final Map<String, TextStyle> map = {
    r'\d': const TextStyle(backgroundColor: Colors.blue),
    r'\u23ce\n\u23ce': const TextStyle(backgroundColor: Colors.yellow),
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])':
        const TextStyle(backgroundColor: Colors.red),
  };

  RichTextFieldController() {
    pattern = RegExp(map.keys.map((key) => key).join('|'), multiLine: true);
  }

  @override
  set value(TextEditingValue newValue) {
    String replaceLastNewLine(String input) {
      if (input.length < value.text.length) {
        final lastIndexOfNewLine = value.text.lastIndexOf(RegExp('$enterSymbol\n$enterSymbol'));
        if (lastIndexOfNewLine == -1) {
          return input;
        }
        if (lastIndexOfNewLine == value.text.length - 3) {
          return value.text.replaceRange(value.text.length - 3, value.text.length, '');
        }
        return input;
      }
      final lastNewLineIndex = input.lastIndexOf(RegExp('\n'));
      if (lastNewLineIndex == -1 || input.isEmpty) {
        return input;
      }
      final leng = input.length;
      final isNewSymbol = lastNewLineIndex == input.length - 1;
      if (isNewSymbol) {
        return input.replaceFirst(RegExp('\n'), '$enterSymbol\n$enterSymbol', input.length - 1);
      }

      return input;
    }

    final newText = replaceLastNewLine(newValue.text);
    super.value = newValue.copyWith(
      text: newText,
      // selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan({
    required context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String? formattedText;
        String? textPattern;
        final patterns = map.keys.toList();

        for (final element in patterns.indexed) {
          if (RegExp(patterns[element.$1]).hasMatch(match[0]!)) {
            formattedText = match[0];
            textPattern = patterns[element.$1];
            break;
          }
    
        }

        children.add(TextSpan(
          text: formattedText,
          style: style!.merge(map[textPattern!]),
        ));
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(
        style: style,
        children: children
          ..forEach(
            (element) => element.toPlainText(),
          ));
  }
}
