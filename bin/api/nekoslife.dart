/// Nekos Life API wrapper.
/// Retrieved from https://nekos.life/api/v2/endpoints
library;

import 'package:http/http.dart' as http;
import 'dart:convert';

const _api = 'https://nekos.life/api/v2/';
Future _getResponse(String endpoint) async {
  final url = Uri.parse(_api + endpoint);
  final response = await http.get(url, headers: {
    'User-Agent': 'maid-chan/0.1.0',
  });
  if (response.statusCode != 200) {
    return null;
  }
  return jsonDecode(response.body);
}

/// 8ball
Future<(String, Uri)?> eightball() async {
  final response = await _getResponse('8ball');
  if (response == null) return null;
  return (response['response'] as String, Uri.parse(response['url']));
}

/// Cat
Future<String?> cat() async {
  final response = await _getResponse('cat');
  if (response == null) return null;
  return response['cat'];
}

/// Fact: Get a random fact
Future<String?> fact() async {
  final response = await _getResponse('fact');
  if (response == null) return null;
  return response['fact'];
}

/// Get an image from a category.
/// 'smug', 'woof', 'gasm', '8ball', 'goose', 'cuddle', 'avatar', 'slap', 'v3', 'pat', 'gecg', 'feed', 'fox_girl', 'lizard', 'neko', 'hug', 'meow', 'kiss', 'wallpaper', 'tickle', 'spank', 'waifu', 'lewd', 'ngif'
Future<Uri?> image(String category) async {
  final response = await _getResponse('img/$category');
  if (response == null) return null;
  return Uri.parse(response['url']);
}

/// A random why?
Future<String?> why() async {
  final response = await _getResponse('why');
  if (response == null) return null;
  return response['why'];
}
