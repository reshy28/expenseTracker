import 'package:intl/intl.dart';

class CurrencyUtil {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  // Version with no decimals if user wants, but defaults to 2
  static String formatWithPrecision(double amount, {int decimals = 2}) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimals,
    );
    return format.format(amount);
  }
}
