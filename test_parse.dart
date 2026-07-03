import 'dart:convert';
import 'lib/models/lead_model.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = "http://127.0.0.1:8000/api/leads?bank_user_id=1";
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  print("Data decoded. Parsing leads...");
  for (var item in data) {
    print("Parsing: ${item['id']}");
    final lead = LeadModel.fromJson(item);
    print("Success: ${lead.name}, Extra: ${lead.extraData.keys}");
  }
}
