import 'package:intl/intl.dart';

extension StringX on String {
  String formatDate() {
    DateTime parsedDate = DateTime.parse(this);
    String formattedDate = DateFormat('yyyy.MM.dd').format(parsedDate);
    return formattedDate;
  }

  String formatPhoneNumber() {
    final regExp = RegExp(r'^(\d{3})(\d{4})(\d{4})$');
    return replaceAllMapped(
        regExp, (match) => '${match[1]}-${match[2]}-${match[3]}');
  }
}
