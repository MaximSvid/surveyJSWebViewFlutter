import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_survey_webview_app/repo/survey_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyViewModel extends ChangeNotifier {
  final SurveyRepository
  _surveyRepository; // Экземпляр репозитория для взаимодействия с данными
  String _surveyJson = ''; // Хранит JSON-схему опроса
  bool _isLoading = false; // Флаг состояния загрузки
  String? _errorMessage; // Сообщение об ошибке, если есть
  String? _successMessage; // Сообщение об успешной операции

  // Конструктор: принимает SurveyRepository для доступа к данным
  SurveyViewModel(this._surveyRepository);

  // Геттеры для доступа к данным ViewModel из UI
  String get surveyJson => _surveyJson;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Методы для изменения состояния и уведомления слушателей (UI)
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    _successMessage = null; // При ошибке сбрасываем сообщение об успехе
    notifyListeners();
  }

  void setSuccessMessage(String? message) {
    _successMessage = message;
    _errorMessage = null; // При успехе сбрасываем сообщение об ошибке
    notifyListeners();
  }

  /// Асинхронно загружает HTML-шаблон и JSON-схему опроса.
  /// Принимает [WebViewController] для загрузки HTML-строки в WebView.
  Future<void> fetchAndLoadSurvey(WebViewController controller) async {
  setLoading(true);
  setErrorMessage(null);
  setSuccessMessage(null);
  try {
    final String htmlContent = await rootBundle.loadString('assets/survey.html');

    debugPrint('Loaded HTML content length: ${htmlContent.length}');
    if (htmlContent.isEmpty) {
      debugPrint('HTML content is EMPTY!');
      throw Exception('HTML-контент пуст или не найден по пути assets/survey.html.');
    }

    // Ключевое изменение: Укажите baseUrl, чтобы относительные пути работали
    // baseUri должен указывать на корневой каталог ваших ассетов
    final String baseUrl = Uri.file('assets/').toString();
    await controller.loadHtmlString(
      htmlContent,
      baseUrl: baseUrl, // <--- УКАЗЫВАЕМ БАЗОВЫЙ URL
    );

    _surveyJson = await _surveyRepository.getSurveySchemaJson();
  } catch (e) {
    setErrorMessage('Ошибка при загрузке опроса: ${e.toString()}');
    debugPrint('Ошибка при загрузке опроса: $e');
  } finally {
    setLoading(false);
  }
}


  /// Внедряет JSON-схему опроса в WebView.
  /// Эта функция должна быть вызвана после того, как HTML-страница полностью загружена в WebView
  /// и все внешние JS-скрипты готовы.
  /// Принимает [WebViewController] для выполнения JavaScript.
  void injectSurveyJson(WebViewController controller) {
    if (_surveyJson.isNotEmpty) {
      String escapedSurveyJson = _surveyJson.replaceAll("'", "\\'");
      // Это вызывает JS-функцию в HTML
      controller
          .runJavaScript("setSurveyJson('$escapedSurveyJson');")
          .catchError((e) {
            setErrorMessage(
              'Ошибка при передаче JSON в JavaScript: ${e.toString()}',
            );
            debugPrint('Error evaluating JavaScript (setSurveyJson): $e');
          });
    }
  }

  /// Отправляет результат опроса на бэкенд.
  /// Принимает [resultJson] - строку JSON с ответами пользователя.
  Future<void> saveSurveyResult(String resultJson) async {
    setLoading(true);
    setErrorMessage(null);
    setSuccessMessage(null);
    try {
      final Map<String, dynamic> answers = Map<String, dynamic>.from(
        jsonDecode(resultJson),
      );
      final String response = await _surveyRepository.submitSurveyResult(
        answers,
      );
      setSuccessMessage('Опрос успешно отправлен: $response');
      debugPrint('Опрос успешно отправлен: $response');
    } catch (e) {
      setErrorMessage('Ошибка при отправке опроса: ${e.toString()}');
      debugPrint('Ошибка при отправке опроса: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Очищает сообщения об ошибках и успехе.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // В данном случае WebViewController управляется в SurveyScreen,
    // поэтому здесь нет необходимости его disposing.
    super.dispose();
  }
}
