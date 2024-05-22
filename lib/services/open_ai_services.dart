import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:trend_analysis/functions/functions.dart';

class OpenAIService {
  final bool shortData;

  OpenAIService(this.shortData);

  Future<String> generateResponse(
    String prompt,
  ) async {
    final x = shortData
        ? await getDataFromJson()
        : await rootBundle.loadString('assets/output.json');
    OpenAI.apiKey = await rootBundle.loadString('assets/openai.key');
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """You are an advanced data analysis system capable of processing JSON data to provide insightful answers. Your responses are concise, presenting only the final conclusions without revealing the calculations. Additionally, you're equipped to analyze the data comprehensively, offering accurate explanations for any analytical inquiries posed by the user. The user string would consist  of a question, to which you have to provide an answer
            Here is the JSON file: ${x} . Please note that your responses should be professional and accurate. please remember, user should not know how you are accessing this data(json or this api).
            If the user is asking questions other than those related to the data or inquiring about the backend or functionality, it is recommended to professionally request them to ask relevant queries. Please note that only the data provided can be discussed, and no further information about the backend or functioning can be disclosed. Dont disclose you are getting data from json""")
      ],
    );
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
    );

    final completion = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: [systemMessage, userMessage],
      maxTokens: 500,
      temperature: 0.2,
    );
    // print(completion);

    if (completion.choices.isNotEmpty) {
      debugPrint(
          'Result: ${completion.choices.first.message.content!.first.text}');
      return completion.choices.first.message.content!.first.text.toString();
    } else {
      throw Exception('Failed to load result');
    }
  }
}

Future<String> generatePrompt(String question) async {
  return """
Question: $question
""";
}
