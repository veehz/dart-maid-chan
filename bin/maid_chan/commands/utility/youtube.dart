import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../command.dart';
import '../components/levels.dart';

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

    int pageNumber = 1;
    String? pageId;
    while (true) {
      Uri uri = Uri.parse("https://www.googleapis.com/youtube/v3/search");
      uri = uri.replace(queryParameters: {
        "part": "snippet",
        "q": query,
        "key": Platform.environment["GOOGLE_API_KEY"],
        "type": "video",
      });

      if (pageId != null) {
        uri = uri.replace(queryParameters: {
          "part": "snippet",
          "q": query,
          "key": Platform.environment["GOOGLE_API_KEY"],
          "type": "video",
          "pageToken": pageId,
        });
      }

      var response = await http.get(uri);
      if (response.statusCode != 200) {
        context
            .respond(MessageBuilder(content: "Error: ${response.statusCode}"));
        return;
      }

      Map<String, dynamic> json = jsonDecode(response.body);
      Iterable<Map> items = json["items"];
      String? prevPageToken = json["prevPageToken"];
      String? nextPageToken = json["nextPageToken"];

      ComponentId prevId = ComponentId.generate(expirationTime: defaultTimeout);
      ComponentId nextId = ComponentId.generate(expirationTime: defaultTimeout);

      if (items.isEmpty) {
        context.respond(MessageBuilder(content: "No results found."));
        return;
      }

      final message = context.respond(
        MessageBuilder(embeds: [
          EmbedBuilder(
            title: "Youtube Search Results for \"$query\" (Page $pageNumber)",
            url: Uri.parse(
                "https://www.youtube.com/results?search_query=$query"),
            color: DiscordColor.parseHexString("FF0000"),
            timestamp: DateTime.now().toUtc(),
            thumbnail: EmbedThumbnailBuilder(
              url: Uri.parse(
                  items.first["snippet"]["thumbnails"]["high"]["url"]),
            ),
            fields: items
                .map((e) => EmbedFieldBuilder(
                      name: e["snippet"]["title"],
                      value:
                          "[link](https://www.youtube.com/watch?v=${e["id"]["videoId"]}) - ${e["snippet"]["description"] ?? "No description"}}",
                      isInline: false,
                    ))
                .toList(growable: false),
          )
        ], components: [
          ActionRowBuilder(
            components: [
              if (prevPageToken != null)
                ButtonBuilder(
                  label: "Previous Page",
                  style: ButtonStyle.primary,
                  customId: prevId.toString(),
                ),
              if (nextPageToken != null)
                ButtonBuilder(
                  label: "Next Page",
                  style: ButtonStyle.primary,
                  customId: nextId.toString(),
                ),
            ],
          )
        ]),
        level: replaceMessage,
      );

      try {
        final event = await context.getButtonPress(await message);
        if (event.componentId == prevId.toString()) {
          pageNumber--;
          pageId = prevPageToken;
        } else if (event.componentId == nextId.toString()) {
          pageNumber++;
          pageId = nextPageToken;
        }
      } on InteractionTimeoutException {
        return;
      }
    }
  }),
);
