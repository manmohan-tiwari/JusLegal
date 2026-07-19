class TextUtils {
  static List<String> tokenize(String text) {
    final cleaned = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\\s]'), ' ');
    return cleaned.split(RegExp(r'\\s+')).where((e) => e.isNotEmpty).toList();
  }
}
