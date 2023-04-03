import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<String> register(
      String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body:
          jsonEncode({'login': username, 'password': password, 'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['access_token'];
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'login': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['access_token'];
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<Map<String, dynamic>> getCourses(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_courses'),
      body: jsonEncode({"access_token": token, "token_type": "string"}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  Future<Map<String, dynamic>> getExercise(
      String token, String categoryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_exercise?category_id=$categoryId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'access_token': token,
        'token_type': 'string',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load exercise');
    }
  }

  Future<Map<String, dynamic>> sendAnswer(
      String token, String exerciseId, String userInput) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/send_answer?excercise_id=$exerciseId&user_input=$userInput'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'access_token': token,
        'token_type': 'string',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to send answer');
    }
  }

  Future<List<dynamic>> getCategories(String token, String courseId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/choose_course?course_id=$courseId'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode({'access_token': token, 'token_type': 'string'}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch categories');
    }
  }
}
