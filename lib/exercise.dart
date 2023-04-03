import 'package:flutter/material.dart';
import 'api.dart';
import 'storage.dart';

class ExercisePage extends StatefulWidget {
  final String categoryId;

  const ExercisePage({Key? key, required this.categoryId}) : super(key: key);

  @override
  ExercisePageState createState() => ExercisePageState();
}

class ExercisePageState extends State<ExercisePage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _userInputController = TextEditingController();

  bool _loading = true;
  bool _answerSent = false;
  Map<String, dynamic> _exerciseData = {};
  Map<String, dynamic> _response = {};

  @override
  void initState() {
    super.initState();
    _getExercise();
  }

  Future<void> _getExercise() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        await StorageService.deleteToken();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final response =
            await _apiService.getExercise(token, widget.categoryId);
        if (!mounted) return;
        setState(() {
          _exerciseData = response;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _sendAnswer() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        await StorageService.deleteToken();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final userInput = _userInputController.text;
        final response = await _apiService.sendAnswer(
            token, _exerciseData["excercise_id"], userInput);
        // Handle the response here
        setState(() {
          _response = response;
          _answerSent = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool userInputEmpty = _userInputController.text.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Exercise title
                  Text(
                    'Переведите предложение',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),

                  // Exercise prompt
                  SelectableText(
                    _exerciseData['argument']['sentence'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),

                  // User input text field
                  TextField(
                    controller: _userInputController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: 'Type your answer here',
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_answerSent)
              Text(
                _response["expected"],
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (!_answerSent)
              ElevatedButton(
                onPressed: userInputEmpty ? null : _sendAnswer,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Theme.of(context).disabledColor;
                      } else if (states.contains(MaterialState.pressed)) {
                        return Theme.of(context).primaryColor.withOpacity(0.5);
                      }
                      return Theme.of(context).primaryColor;
                    },
                  ),
                ),
                child: const Text('Send Answer'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  if (!mounted) return;
                  setState(() {
                    _userInputController.clear();
                    _answerSent = false;
                    _getExercise();
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return _response["answer_result"]
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5);
                      }
                      return _response["answer_result"]
                          ? Colors.green
                          : Colors.red;
                    },
                  ),
                ),
                child: const Text('Continue'),
              ),
          ],
        ),
      ),
    );
  }
}
