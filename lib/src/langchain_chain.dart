import 'gemini_client.dart';
import 'prompt_template.dart';

class LangChain {
  final PromptTemplateWrapper promptTemplate;

  LangChain({required String template})
      : promptTemplate = PromptTemplateWrapper(template);

  /// Run the chain: fill prompt + send to Gemini + stream response
  Stream<String> run(Map<String, String> variables) {
    final prompt = promptTemplate.format(variables);
    return GeminiClient.instance.generateContentStream(prompt);
  }
}
