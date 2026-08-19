class CurrencyUtils {
  static String format(num amount, {String symbol = '৳'}) {
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}
