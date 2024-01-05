import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'config.dart' show userAgent;

final languages = {
  "BG": "Bulgarian",
  "CS": "Czech",
  "DA": "Danish",
  "DE": "German",
  "EL": "Greek",
  "EN": "English", // Unspecified English variant (Prefer EN-GB or EN-US)
  "EN-GB": "English (British)",
  "EN-US": "English (American)",
  "ES": "Spanish",
  "ET": "Estonian",
  "FI": "Finnish",
  "FR": "French",
  "HU": "Hungarian",
  "ID": "Indonesian",
  "IT": "Italian",
  "JA": "Japanese",
  "KO": "Korean",
  "LT": "Lithuanian",
  "LV": "Latvian",
  "NB": "Norwegian (Bokmål)",
  "NL": "Dutch",
  "PL": "Polish",
  // unspecified variant for backward compatibility; please select PT-BR or PT-PT instead
  "PT": "Portuguese",
  "PT-BR": "Portuguese (Brazilian)",
  "PT-PT":
      "Portuguese (all Portuguese varieties excluding Brazilian Portuguese)",
  "RO": "Romanian",
  "RU": "Russian",
  "SK": "Slovak",
  "SL": "Slovenian",
  "SV": "Swedish",
  "TR": "Turkish",
  "UK": "Ukrainian",
  "ZH": "Chinese (simplified)",
};

final _apiUrl =
    Platform.environment['DEEPL_API_DOMAIN'] ?? 'https://api-free.deepl.com/';

/// Translate a text to a target language. Returns (result/message, json response, success indicator)
Future<(String, dynamic, bool)> translateText(
    String text, String targetLanguage) async {
  if (Platform.environment['DEEPL_API_KEY'] == null) {
    return ("No DeepL API Key", null, false);
  }

  final url = Uri.parse('${_apiUrl}v2/translate');
  final response = await http.post(url,
      headers: {
        'User-Agent': userAgent,
        'Content-Type': 'application/json',
        'Authorization':
            'DeepL-Auth-Key ${Platform.environment['DEEPL_API_KEY']}',
      },
      body: jsonEncode({
        'text': [text],
        'target_lang': targetLanguage,
      }));

  switch (response.statusCode) {
    case 200:
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return (json['translations'][0]['text'] as String, json, true);
    case 400:
      return ("Bad request", null, false);
    case 403:
      return ("DeepL API Key is invalid", null, false);
    case 404:
      return ("DeepL API URL is invalid", null, false);
    case 413:
      return ("Text is too long", null, false);
    case 429:
      return ("Too many requests", null, false);
    case 456:
      return ("Quota exceeded", null, false);
    case 500:
      return ("DeepL Internal error", null, false);
    case 504:
      return ("Resource currently unavailable", null, false);
    case 529:
      return ("Too many requests", null, false);
    default:
      return ("Unknown error", null, false);
  }
}
