import 'package:flutter/material.dart';
import 'package:flutter_survey_webview_app/view_model/survey_view_model.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late final WebViewController _webViewController;
  late final SurveyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<SurveyViewModel>(context, listen: false);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterMethodChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _viewModel.saveSurveyResult(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView загружается (прогресс: $progress%)');
          },
          onPageFinished: (String url) {
            debugPrint('Загрузка страницы завершена: $url');
            if (_viewModel.surveyJson.isNotEmpty) {
              _viewModel.injectSurveyJson(_webViewController);
            }
          },
          onWebResourceError: (WebResourceError error) {
            _viewModel.setErrorMessage('Ошибка WebView: ${error.description}');
            debugPrint('Ошибка WebView: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    // ВАЖНОЕ ИСПРАВЛЕНИЕ ЗДЕСЬ:
    // Отложите вызов fetchAndLoadSurvey до завершения текущего кадра.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchAndLoadSurvey(_webViewController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SurveyJS в MVVM'),
      ),
      body: Consumer<SurveyViewModel>(
        builder: (context, viewModel, child) {
          // Если контроллер еще не инициализирован (что маловероятно после initState)
          // или данные еще не загружены, показываем индикатор загрузки.
          // Убрал проверку viewModel.webViewController == null, т.к. он всегда будет не null в _SurveyScreenState
          if (viewModel.isLoading || viewModel.surveyJson.isEmpty) {
             return const Center(child: CircularProgressIndicator());
          }

          // Показываем сообщения об ошибках
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.clearMessages();
                        viewModel.fetchAndLoadSurvey(_webViewController);
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Показываем сообщения об успехе
          if (viewModel.successMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.successMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.green, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('ОК'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Если все данные загружены и ошибок нет, отображаем WebView
          return WebViewWidget(controller: _webViewController);
        },
      ),
    );
  }
}