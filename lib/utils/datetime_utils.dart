import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  static String formatDateShort(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  static String formatDayName(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('EEEE').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  static String formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
