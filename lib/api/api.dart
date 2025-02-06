import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiApi {
  GeminiApi(_);

  static const apiKey =
      "AIzaSyCLABIw7tbYdWAgPXfymYMKX00Xbuvg1Rg"; //google gemini

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
