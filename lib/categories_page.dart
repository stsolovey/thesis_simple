import 'package:flutter/material.dart';

import 'exercise.dart';
import 'storage.dart';
import 'api.dart';

class CategoriesPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String token;

  const CategoriesPage(
      {Key? key,
      required this.courseId,
      required this.courseName,
      required this.token})
      : super(key: key);

  @override
  CategoriesPageState createState() => CategoriesPageState();
}

class CategoriesPageState extends State<CategoriesPage> {
  bool _loading = true;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    ApiService apiService = ApiService();

    try {
      List<dynamic> categories =
          await apiService.getCategories(widget.token, widget.courseId);
      setState(() {
        _categories = categories;
        _categories.sort(
            (a, b) => a['category_weight'].compareTo(b['category_weight']));
        _loading = false;
      });
    } catch (e) {
      throw Exception('Failed to fetch categories');
    }
  }

  Future<String?> _getToken() async {
    return await StorageService.getToken();
  }

  void _onCategoryTapped(BuildContext context, String categoryId) {
    _getToken().then((token) {
      if (token == null) {
        StorageService.deleteToken().then((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExercisePage(
              categoryId: categoryId,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_categories[index]['category_name']),
                  onTap: () => _onCategoryTapped(
                      context, _categories[index]['category_id']),
                );
              },
            ),
    );
  }
}
