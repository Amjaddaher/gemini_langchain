import 'package:langchain/langchain.dart';

class PromptTemplateWrapper {
  final PromptTemplate _template;

  PromptTemplateWrapper(String template)
      : _template = PromptTemplate.fromTemplate(template);

  /// Fill the template with variables
  String format(Map<String, String> variables) {
    return _template.format(variables);
  }
}
