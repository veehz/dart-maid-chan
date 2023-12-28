/// AniList API Wrapper.
/// Docs at https://anilist.gitbook.io/anilist-apiv2-docs/
library;

import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore constant identifier names because we follow Anilist API
enum AnilistType {
  // ignore: constant_identifier_names
  ANIME,
  // ignore: constant_identifier_names
  MANGA,
}

search(String search, {bool? isNsfw, AnilistType? type}) async {
  var query = '''query (\$search: String) {
  Media(
    search: \$search
    ${type == null ? '' : 'type: ${type.name}'}
    ${isNsfw == null ? '' : 'isAdult: $isNsfw'}
    sort: [POPULARITY_DESC]
  ) {
    id
    idMal
    title {
      romaji
      english
      native
    }
    description
    episodes
    duration
    format
    status
    startDate { year month day }
    endDate { year month day }
    season
    seasonYear
    coverImage {
      extraLarge
      color
    }
    averageScore
    siteUrl
  }
}''';

  http.Response response = await http.post(
    Uri.parse('https://graphql.anilist.co'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'query': query,
      'variables': {
        'search': search,
      }
    }),
  );

  if (response.statusCode != 200 || response.body.contains('errors')) {
    if(response.statusCode != 200) {
      print(response);
      print(response.body);
    }
    return (null, response);
  }

  final data = jsonDecode(response.body)['data']['Media'];
  return (data, response);
}

anilistUnescapeHtml(String html) {
  return html
      .replaceAll('<i>', '_')
      .replaceAll('</i>', '_')
      .replaceAll('<b>', '**')
      .replaceAll('</b>', '**')
      .replaceAll('<br>', ''); // they already have \n
}
