// Web-specific export functionality
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String downloadFileWeb(String content, String fileName, String extension) {
  // Create a blob from the content
  final bytes = utf8.encode(content);
  final blob = html.Blob(
    [bytes],
    extension == 'csv' ? 'text/csv;charset=utf-8' : 'text/xml;charset=utf-8',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Create a download link and click it
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();

  // Clean up
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return 'Downloaded: $fileName';
}
