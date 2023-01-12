import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';

/// {@template streamDateDivider}
/// Shows a date divider depending on the date difference
/// {@endtemplate}
class StreamDateDivider extends StatelessWidget {
  /// {@macro streamDateDivider}
  const StreamDateDivider({
    super.key,
    required this.dateTime,
    this.uppercase = false,
  });

  /// [DateTime] to display
  final DateTime dateTime;

  /// If text is uppercase
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final createdAt = Jiffy(dateTime);
    final now = Jiffy(DateTime.now());

    var dayInfo = createdAt.MMMd;
    if (createdAt.isSame(now, Units.DAY)) {
      dayInfo = context.translations.todayLabel;
    } else if (createdAt.isSame(now.subtract(days: 1), Units.DAY)) {
      dayInfo = context.translations.yesterdayLabel;
    } else if (createdAt.isAfter(now.subtract(days: 7), Units.DAY)) {
      dayInfo = createdAt.EEEE;
    } else if (createdAt.isAfter(now.subtract(years: 1), Units.DAY)) {
      dayInfo = createdAt.MMMd;
    }

    if (uppercase) dayInfo = dayInfo.toUpperCase();

    final chatThemeData = StreamChatTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              child: Container(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Color(0xFF9BA0A5) : Color(0XFF828282),
                height:  0.25,
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              dayInfo.toUpperCase(),
              style:  TextStyle(
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Color(0xFF9BA0A5) : Color(0XFF828282),
                  fontSize: 14,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
              child: Container(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Color(0xFF9BA0A5) : Color(0XFF828282),
                height: 0.25,
              )),
        ],
      ),
    );
  }
}
