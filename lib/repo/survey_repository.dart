import 'dart:convert';

import 'package:http/http.dart' as http;

class SurveyRepository {
  static const String _backendBaseUrl =
      'http://localhost:8080'; // Обновите при необходимости

  /// Получает JSON-схему опроса с бэкенда.
  Future<String> getSurveySchemaJson() async {
    final response = await http.get(Uri.parse('$_backendBaseUrl/survey'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Не удалось загрузить схему опроса: ${response.statusCode}',
      );
    }
  }

  /// Отправляет результаты опроса на бэкенд.
  Future<String> submitSurveyResult(Map<String, dynamic> answers) async {
    final response = await http.post(
      Uri.parse('$_backendBaseUrl/survey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(answers),
    );

    if (response.statusCode == 200) {
      return response.body; // Ожидаем "Done" или сообщение об успехе
    } else {
      throw Exception('Не удалось отправить опрос: ${response.statusCode}');
    }
  }
}
