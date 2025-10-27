import 'dart:convert';
import 'package:attendance_system/api_services/person.dart';
import 'package:http/http.dart' as http;

class PersonService {
  String baseUrl = "https://api.api-ninjas.com/v1/randomuser";

  Future<Person?> getPerson() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'X-Api-Key': '0Y08Df7ZmLbsK9MFLgQpWA==sSaiwxtaqGADHlY2'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        return Person.fromJson(data);
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
