
import 'package:flutter_survey_webview_app/model/survey_page.dart';

class Survey {
  final String title;
  final List<SurveyPage> pages;
  final String? headerView;

  Survey({
    required this.title,
    required this.pages,
    this.headerView,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    var pagesList = json['pages'] as List;
    List<SurveyPage> pages = pagesList
        .map((p) => SurveyPage.fromJson(p))
        .toList();
    return Survey(
      title: json['title'],
      pages: pages,
      headerView: json['headerView'],
    );
  }
}
