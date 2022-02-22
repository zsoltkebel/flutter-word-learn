extension StringMethods on String {
  String truncateWithEllipsis(int cutoff) {
    return (length <= cutoff) ? this : '${substring(0, cutoff)}...';
  }
}