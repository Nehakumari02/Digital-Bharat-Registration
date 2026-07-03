import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = "http://127.0.0.1:8000/api/leads?bank_user_id=1";
  try {
    final response = await http.get(Uri.parse(url));
    print("Status: ${response.statusCode}");
    print("Body length: ${response.body.length}");
    final data = jsonDecode(response.body);
    print("Is List: ${data is List}");
    if (data is List) {
      print("Items: ${data.length}");
      for (var item in data) {
        print("Item: ${item['id']} - ${item['name']}");
      }
    }
  } catch (e) {
    print("Error: $e");
  }
}
