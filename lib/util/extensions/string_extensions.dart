extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeAll() {
    return split(' ').map((e) => e.capitalize()).join(" ");
  }

  String formatNumber() {
    var sections = split('.');
    sections[0] = sections[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return sections.join('.');
  }
}
