
class SurveyElement {
  final String type;
  final String name;
  final String title;
  final String? inputType;

  SurveyElement({
    required this.type,
    required this.name,
    required this.title,
    this.inputType,
  });

  factory SurveyElement.fromJson(Map<String, dynamic> json) {
    return SurveyElement(
      type: json['type'],
      name: json['name'],
      title: json['title'],
      inputType: json['inputType'],
    );
  }
}
