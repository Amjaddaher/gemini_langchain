import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiClient {

  GeminiClient._privateConstructor();

  static final GeminiClient instance = GeminiClient._privateConstructor();

  /// Initialize Gemini SDK with API key
  static void initialize({required String apiKey}) {
    Gemini.init(apiKey: apiKey, enableDebugging: false);
  }

  /// Sends prompt to Gemini and returns a Stream of text chunks (streaming response)
  Stream<String> generateContentStream(String prompt) async* {
    final gemini = Gemini.instance;

    final buffer = StringBuffer();

    await for (final event in gemini.streamGenerateContent(prompt)) {
      if (event.output != null) {
        buffer.write(event.output);
        yield buffer.toString();
      }
    }
  }
}
