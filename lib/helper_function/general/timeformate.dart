import 'package:intl/intl.dart';

String timeFormate(int totalDurationInSeconds) {
  Duration duration = Duration(seconds: totalDurationInSeconds);

  String formattedDuration;
  if (totalDurationInSeconds == 0) {
    return '';
  }
  if (duration.inHours > 0) {
    // Format as HH:mm:ss if there are hours
    formattedDuration =
        DateFormat('HH:mm:ss').format(DateTime(0).add(duration));
  } else {
    // Format as mm:ss if there are no hours
    formattedDuration = DateFormat('m:ss').format(DateTime(0).add(duration));
  }

  return formattedDuration;
}
