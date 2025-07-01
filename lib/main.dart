import 'package:flutter/material.dart';
import 'package:flutter_survey_webview_app/repo/survey_repository.dart';
import 'package:flutter_survey_webview_app/screens/survey_screen.dart';
import 'package:flutter_survey_webview_app/view_model/survey_view_model.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late final PlatformWebViewControllerCreationParams params;
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
  } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
    params = AndroidWebViewControllerCreationParams();
  } else {
    params = const PlatformWebViewControllerCreationParams();
  }
  WebViewController.fromPlatformCreationParams(params); // Глобальная инициализация

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // Теперь SurveyViewModel ожидает SurveyRepository
          create: (_) => SurveyViewModel(SurveyRepository()), // <--- ПЕРЕДАЕМ ЭКЗЕМПЛЯР РЕПОЗИТОРИЯ
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Survey WebView App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SurveyScreen(),
      ),
    );
  }
}
