# gemini_langchain

A Dart/Flutter package that integrates **Google Gemini** with LangChain-style prompt templates and chain execution.  
It enables AI-driven workflows in your Flutter or Dart applications with both streaming and non-streaming responses.

> GitHub Repository: [Amjaddaher/gemini_langchain](https://github.com/Amjaddaher/gemini_langchain)

---

## Example

For a full working example, see [example/example.dart on GitHub](https://github.com/Amjaddaher/gemini_langchain/blob/main/example/example.dart)

---

## Usage

```dart
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
