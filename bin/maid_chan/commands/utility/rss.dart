import 'dart:math';

import '../command.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';

extension RssDiscordTitleMaker on RssItem {
  String get unlinkedTitle {
    final title = this.title ?? "Untitled";
    final author = this.author != null ? " by ${this.author}" : "";
    return "$title$author";
  }

  String get linkedTitle {
    if (link == null) return unlinkedTitle;
    return "[$unlinkedTitle]($link)";
  }

  String get linkedDescription {
    if (link == null) return description ?? "No description";
    return "[${description ?? "No description"}]($link)";
  }
}

Future<MessageBuilder> _makeRssEmbed(String url) async {
  // fetch rss
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) {
    return MessageBuilder(content: "Error ${response.statusCode}");
  }

  // parse rss
  final rss = RssFeed.parse(response.body);

  return MessageBuilder(embeds: [
    EmbedBuilder(
      title: rss.title,
      description: rss.description,
      url: rss.link != null ? Uri.tryParse(rss.link!) : null,
      timestamp: DateTime.now().toUtc(),
      footer: rss.copyright != null
          ? EmbedFooterBuilder(text: rss.copyright!)
          : null,
      thumbnail: rss.image?.url != null
          ? EmbedThumbnailBuilder(url: Uri.parse(rss.image!.url!))
          : null,
      fields: rss.items
          .sublist(0, min(rss.items.length, 5))
          .map((item) => EmbedFieldBuilder(
                name: item.unlinkedTitle,
                value: item.linkedDescription,
                isInline: false,
              ))
          .toList(),
    )
  ]);
}

executer(String url, ChatContext context) async {
  await context.respond(await _makeRssEmbed(url));
}

typedef Group = ExtendedChatGroup;
typedef Cmd = ExtendedChatCommand;

List<MaidChanCommand> _rssFeeds = [
  Group("bbc", "BBC News", children: [
    Cmd(
      "top",
      "Top Stories",
      id("bbc-top", (ChatContext context) async {
        executer("http://feeds.bbci.co.uk/news/rss.xml", context);
      }),
    ),
    Cmd(
      "world",
      "World",
      id("bbc-world", (ChatContext context) async {
        executer("http://feeds.bbci.co.uk/news/world/rss.xml", context);
      }),
    ),
  ]),
  Group("nytimes", "New York Times", children: [
    Cmd(
        "world",
        "World",
        id("nytimes-world", (ChatContext context) async {
          executer("https://rss.nytimes.com/services/xml/rss/nyt/World.xml",
              context);
        })),
    Cmd(
        "apac",
        "Asia Pacific",
        id("nytimes-apac", (ChatContext context) async {
          executer(
              "https://rss.nytimes.com/services/xml/rss/nyt/AsiaPacific.xml",
              context);
        })),
  ]),
  Cmd(
      "custom",
      "Custom RSS Feed",
      id("custom", (ChatContext context, String url) async {
        executer(url, context);
      })),
];

final rss = ExtendedChatGroup('rss', 'RSS Feeds',
    category: Category.utility, children: _rssFeeds);
