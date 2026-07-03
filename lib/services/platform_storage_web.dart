// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> write(String key, String value) async {
  html.window.localStorage[key] = value;
}

Future<String?> read(String key) async {
  return html.window.localStorage[key];
}

Future<void> delete(String key) async {
  html.window.localStorage.remove(key);
}
