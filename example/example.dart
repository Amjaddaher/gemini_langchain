import 'package:gemini_langchain/gemini_langchain.dart';

final chain = LangChain(
  template: '''
You are a helpful assistant.

Here is data:
{data}

Question:
{question}
''',
);

void askAI() async {
  final variables = {
    'data': 'List of products...',
    'question': 'What product is best for me?'
  };

  await for (final chunk in chain.run(variables)) {
    print('AI response so far: $chunk');
    // Update your UI progressively here
  }
}
