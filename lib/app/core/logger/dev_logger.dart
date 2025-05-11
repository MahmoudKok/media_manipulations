import 'package:colorize/colorize.dart';
import 'package:flutter/cupertino.dart';

class Dev {
  Dev._();
  static void logValue(dynamic value) {
    debugPrint(
      Colorize("The value is : ******  $value  ******")
          .magenta()
          .red()
          .bold()
          .italic()
          .initial,
    );
  }

  static void logError(dynamic value) {
    debugPrint(
      Colorize("The Error is : ******  $value  ******")
          .bgRed()
          .black()
          .bold()
          .italic()
          .initial,
    );
  }

  static void logLine(dynamic value) {
    debugPrint(
      Colorize("******  $value  ******")
          .bgGreen()
          .black()
          .bold()
          .italic()
          .initial,
    );
  }

  static void logSuccess(dynamic value) {
    debugPrint(
      Colorize("--------   Success with : $value   --------")
          .bgGreen()
          .black()
          .bold()
          .italic()
          .initial,
    );
  }

  static void logFaild(dynamic value, dynamic reason) {
    debugPrint(
      Colorize("++++++++   Faild with : $value  ||| Reason: $reason ++++++++")
          .bgRed()
          .black()
          .bold()
          .italic()
          .initial,
    );
  }

  static void logList(List items) {
    logLine('List size is ${items.length}');
    for (int i = 0; i < items.length; i++) {
      debugPrint(
        Colorize("******  Item with index $i ===> ${items[i]}  ******")
            .bgLightGray()
            .black()
            .bold()
            .italic()
            .initial,
      );
    }
  }

  static void logLineWithTag({dynamic tag, dynamic message}) {
    debugPrint(
      Colorize("******  $tag: $message  ******")
          .bgWhite()
          .black()
          .bold()
          .initial,
    );
  }

  static void logLineWithTagError(
      {dynamic tag, dynamic message, dynamic error}) {
    debugPrint(
      Colorize("******  $tag: $message >>>>> Error => $error  ******")
          .bgLightRed()
          .black()
          .bold()
          .initial,
    );
  }

  static void logDivider({dynamic symbole = '*', dynamic lenght = 20}) {
    debugPrint(
      Colorize("$symbole" * lenght).bgDarkGray().yellow().bold().initial,
    );
  }

  static void logWithLine({dynamic title}) {
    debugPrint(
      Colorize("*" * 25).bgYellow().black().bold().initial +
          Colorize("$title").bgBlack().white().bold().initial +
          Colorize("*" * 25).bgYellow().black().bold().initial,
    );
  }

  static void console(List<dynamic> list) {
    // Colorize string = Colorize(
    //   "This is my string!",
    // );//   "Bold Italic Underline",
    //     //   front: Styles.RED,
    //     //   isBold: true,
    //     //   isItalic: true,
    //     //   isUnderline: true,
    //     //
    //     // );

    debugPrint(
      Colorize("First").bgLightRed().white().bold().italic().initial +
          Colorize(" ==> ").bgLightRed().white().bold().italic().initial +
          Colorize("********************************")
              .apply(Styles.BLACK)
              .bgWhite()
              .bold()
              .italic()
              .initial,
    );

    for (var element in list) {
      if (element is List) {
        for (int index = 0; index < element.length; index++) {
          debugPrint(
            Colorize("ITEM $index").apply(Styles.RED).bold().italic().initial +
                Colorize(" ==> ").apply(Styles.WHITE).bold().italic().initial +
                Colorize("${element[index]}")
                    .apply(Styles.GREEN)
                    .bold()
                    .italic()
                    .initial,
          );
        }
      } else {
        debugPrint(
          Colorize("ELEMENT").apply(Styles.RED).bold().italic().initial +
              Colorize(" ==> ").apply(Styles.WHITE).bold().italic().initial +
              Colorize("$element").apply(Styles.GREEN).bold().italic().initial,
        );
      }
    }
    // for (int i = 0; i >= list.length; i++) {}
    debugPrint(
      Colorize("END").bgLightRed().white().bold().italic().initial +
          Colorize(" ==> ").bgLightRed().white().bold().italic().initial +
          Colorize("**********************************")
              .apply(Styles.BLACK)
              .bgWhite()
              .bold()
              .italic()
              .initial,
    );
  }
}
