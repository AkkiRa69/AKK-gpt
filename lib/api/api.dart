import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiApi {
  GeminiApi(_);

  static const apiKey =
      "AIzaSyDqDAqpJ4SCC7mWR5w7ZfdlWwgBWeumzA8"; //google gemini

  static Future<String?> generativeText(String userPrompt) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final prompt = userPrompt;
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response.text;
  }
}
