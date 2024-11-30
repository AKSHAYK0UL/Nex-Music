import 'package:intl/intl.dart';

String convertUkToIst(DateTime ukTime) {
  Duration istOffset = const Duration(hours: 5, minutes: 30);

  Duration ukOffset = ukTime.timeZoneOffset;

  Duration difference = istOffset - ukOffset;

  DateTime istTime = ukTime.add(difference);

  return DateFormat("dd-MMM-yyyy hh:mm a").format(istTime);
}
