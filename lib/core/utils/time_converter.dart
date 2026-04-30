class TimeConverter {
  static String toWIB(DateTime utc) {
    final wib = utc.add(const Duration(hours: 7));
    return _format(wib, 'WIB');
  }

  static String toWITA(DateTime utc) {
    final wita = utc.add(const Duration(hours: 8));
    return _format(wita, 'WITA');
  }

  static String toLondon(DateTime utc) {
    // London BST = UTC+1, GMT = UTC+0
    final now = DateTime.now();
    final isDst = now.timeZoneOffset.inHours == 1;
    final london = isDst ? utc.add(const Duration(hours: 1)) : utc;
    return _format(london, isDst ? 'BST' : 'GMT');
  }

  static String _format(DateTime dt, String tz) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')} $tz';
  }
}
