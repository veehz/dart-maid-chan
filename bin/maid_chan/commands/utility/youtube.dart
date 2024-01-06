import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../command.dart';

final youtube = ExtendedChatCommand(
  'youtube',
  'Search for a video on YouTube',
  usage: 'youtube <query>',
  category: Category.utility,
  id('youtube', (ChatContext context, String query) async {
    if (context is MessageChatContext) {
      // get full message
      query = context.message.content.split(' ').sublist(1).join(' ');
    }

    Uri uri = Uri.parse("https://www.googleapis.com/youtube/v3/search");
    uri = uri.replace(queryParameters: {
      "part": "snippet",
      "q": query,
      "key": Platform.environment["GOOGLE_API_KEY"],
      "type": "video",
    });

    var response = await http.get(uri);
    if (response.statusCode != 200) {
      context.respond(MessageBuilder(content: "Error: ${response.statusCode}"));
      return;
    }

    var json = jsonDecode(response.body);
    var items = json["items"];

    if (items.isEmpty) {
      context.respond(MessageBuilder(content: "No results found."));
      return;
    }

    context.respond(MessageBuilder(embeds: [
      EmbedBuilder(
        title: "Youtube Search Results for \"$query\"",
        url: Uri.parse("https://www.youtube.com/results?search_query=$query"),
        color: DiscordColor.parseHexString("FF0000"),
        timestamp: DateTime.now().toUtc(),
        thumbnail: EmbedThumbnailBuilder(
          url: Uri.parse(items.first["snippet"]["thumbnails"]["high"]["url"]),
        ),
        fields: (items as Iterable<dynamic>)
            .map((e) => EmbedFieldBuilder(
                  name: e["snippet"]["title"],
                  value:
                      "[${e["snippet"]["description"] ?? "link"}](https://www.youtube.com/watch?v=${e["id"]["videoId"]})",
                  isInline: false,
                ))
            .toList(growable: false),
      )
    ]));
  }),
);
