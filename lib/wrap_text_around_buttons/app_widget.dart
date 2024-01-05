import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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

const completeText =
    'Long Text Long TextLong Text Long TextLong Text Long TextLongText Long TextLong TextLong tLong Text Long TextLong TextLongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text Long TextLong Text Long TextLong Text Long TextLong Text Long tLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongTextLong Text Long TextLong Text Long TextLong Text Long tLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongTextLong Text Long TextLong Text Long TextLong Text Long tLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongTextLong Text Long TextLong Text Long TextLong Text Long tLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text LongtLong Text Long TextLong Text Long';

class HomeWidget extends StatelessWidget {
  HomeWidget({super.key});

  final List<({int line, String text, VoidCallback onTap})> buttons = [
    (
      line: 2,
      text: 'button1',
      onTap: () {
        print('button1');
      }
    ),
    (
      line: 8,
      text: 'button2',
      onTap: () {
        print('button2');
      }
    ),
  ];
  List<InlineSpan> breakTextWithButtons(
    List<({int line, String text, VoidCallback onTap})> buttons,
    String text,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    final resultSpans = <InlineSpan>[];
    var resultLineSize = 0.0;
    var currentLine = 0;
    final splittedText = completeText.split(' ');
    for (int wordIndex = 0; wordIndex < splittedText.length; wordIndex++) {
      final word = splittedText[wordIndex];
      final wordSpan = TextSpan(text: '$word ', style: const TextStyle(color: Colors.black));
      final wordSize = (TextPainter(
              text: wordSpan,
              maxLines: 1,
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              textDirection: TextDirection.ltr)
            ..layout())
          .size;

      final buttonOnLine = buttons.singleWhereOrNull((element) => element.line == currentLine);
      final lineSizeWithDesiredWord = wordSize.width + resultLineSize;
      if (buttonOnLine == null) {
        if (lineSizeWithDesiredWord < screenWidth) {
          resultSpans.add(wordSpan);
          resultLineSize += wordSize.width;
        } else {
          final leftSpace = (screenWidth - lineSizeWithDesiredWord).floorToDouble();
          // for (int i = 0; i < leftSpace; i++) {
          if (!leftSpace.isNegative) {
            resultSpans.add(WidgetSpan(
                child: SizedBox(
              width: leftSpace,
            )));
            // resultLineSize += spaceWidth.width;
            // }®
          }
          currentLine++;

          resultSpans.add(wordSpan);
          resultLineSize = wordSize.width;
        }
      } else {
        final buttonSpan = TextSpan(
            text: ' ${buttonOnLine.text} ',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 15,
            ));

        final buttonSize = (TextPainter(
                text: buttonSpan,
                maxLines: 1,
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
                textDirection: TextDirection.ltr)
              ..layout())
            .size;

        final nextWordSize = (TextPainter(
                text: TextSpan(
                    text: splittedText[wordIndex + 1],
                    style: const TextStyle(
                      color: Colors.black,
                    )),
                maxLines: 1,
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
                textDirection: TextDirection.ltr)
              ..layout())
            .size;

        final spaceWithButtonLeft =
            screenWidth - lineSizeWithDesiredWord - buttonSize.width - nextWordSize.width;
        if (spaceWithButtonLeft <= 0) {
          final leftSpace = (screenWidth - resultLineSize - (buttonSize.width)).floorToDouble();
          // for (int i = 0; i < leftSpace; i++) {
          if (!leftSpace.isNegative) {
            resultSpans.add(WidgetSpan(
                child: SizedBox(
              width: leftSpace,
            )));
          }

          // resultLineSize += spaceWidth.width;
          // }
          resultSpans.add(buttonSpan);

          currentLine++;
          resultLineSize = wordSize.width;
          resultSpans.add(wordSpan);
        } else {
          resultSpans.add(wordSpan);
          resultLineSize += wordSize.width;
        }
      }
    }

    return resultSpans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Wrap(
          children: [
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                children: [
                  ...breakTextWithButtons(
                      buttons,
                      'Very Long Text Very Long Text Very Long Text Very Very Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text VeryVery Long Text Very Long Text Very Long Text Very',
                      context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
