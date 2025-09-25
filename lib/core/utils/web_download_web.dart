// Web implementation for CSV download
// ignore: avoid_web_libraries_in_flutter
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, duplicate_ignore







import 'dart:html' as html;

void downloadCsvWeb(String csvContent, String filename) {
  final bytes = html.Blob([csvContent], 'text/csv;charset=utf-8;');
  final url = html.Url.createObjectUrlFromBlob(bytes);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}


