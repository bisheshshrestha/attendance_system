import 'dart:convert';
import 'package:attendance_system/models/person.dart';
import 'package:http/http.dart' as http;

class PersonService {
  static Person? _cachedUser;

  Future<Person> getPerson() async {
    if (_cachedUser != null) return _cachedUser!;

    String baseUrl = "https://api.api-ninjas.com/v1/randomuser";
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'X-Api-Key': 'wvfzoGlwsXuTbfULJGNkWA==VrGoHfnK8xR7OLbN'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedUser = Person.fromJson(data);
        return _cachedUser!;
      } else {
        throw Exception("Failed to load user");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}

//'