import 'package:flutter/material.dart';
import 'api.dart';
import 'storage.dart';
import 'categories_page.dart';

@immutable
class CoursesPage extends StatefulWidget {
  const CoursesPage({Key? key}) : super(key: key);

  @override
  CoursesPageState createState() => CoursesPageState();
}

class CoursesPageState extends State<CoursesPage> {
  final ApiService _apiService = ApiService();
  bool _loading = true;
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourses();
    });
  }

  BuildContext? get safeContext {
    if (mounted) {
      return context;
    }
    return null;
  }

  Future<void> _fetchCourses() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        await StorageService.deleteToken();
        if (!mounted) return;
        Navigator.pushReplacementNamed(safeContext!, '/login');
      } else {
        final response = await _apiService.getCourses(token);
        if (response['status']) {
          if (!mounted) return;
          setState(() {
            _courses = response['message'];
            _loading = false;
          });
          await StorageService.saveCourses(_courses);
        } else {
          await StorageService.deleteToken();
          if (!mounted) return;
          Navigator.pushReplacementNamed(safeContext!, '/login');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(safeContext!)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _onCourseTapped(String courseId, String courseName) async {
    final token = await StorageService.getToken();
    if (token == null) {
      await StorageService.deleteToken();
      Navigator.pushReplacementNamed(safeContext!, '/login');
      return;
    }
    Navigator.push(
      safeContext!,
      MaterialPageRoute(
        builder: (context) => CategoriesPage(
          courseId: courseId,
          courseName: courseName,
          token: token,
        ),
      ),
    );
  }

  Future<void> _logoutAndNavigate() async {
    await StorageService.deleteToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(safeContext!, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logoutAndNavigate,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_courses[index]['course_name']),
                  subtitle: Text(
                      '${_courses[index]['from_language']} - ${_courses[index]['learning_language']}'),
                  onTap: () => _onCourseTapped(
                    _courses[index]['course_id'],
                    _courses[index]['course_name'],
                  ),
                );
              },
            ),
    );
  }
}
