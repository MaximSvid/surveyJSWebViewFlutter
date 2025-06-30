import 'survey_element.dart';
class SurveyPage {
  final String name;
  final String title;
  final List<SurveyElement> elements;

  SurveyPage({
    required this.name,
    required this.title,
    required this.elements,
  });

  factory SurveyPage.fromJson(Map<String, dynamic> json) {
    var elementsList = json['elements'] as List;
    List<SurveyElement> elements = elementsList
        .map((e) => SurveyElement.fromJson(e))
        .toList();
    return SurveyPage(
      name: json['name'],
      title: json['title'],
      elements: elements,
    );
  }
}