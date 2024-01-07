import 'dart:async';
import 'dart:math';

import '../command.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';

import '../components/levels.dart';

const _maxPostsInEmbed = 5;

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

Future<(MessageBuilder, String?, String?, RssFeed?)> _makeRssEmbed(
    String url, int start,
    {bool interaction = true, RssFeed? cache}) async {
  late final RssFeed rss;

  if (cache != null) {
    rss = cache;
  } else {
    // fetch rss
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      return (
        MessageBuilder(content: "Error ${response.statusCode}"),
        null,
        null,
        null
      );
    }

    // parse rss
    rss = RssFeed.parse(response.body);
  }

  if (rss.items.length < start) {
    return (MessageBuilder(content: "No more posts."), null, null, null);
  }

  String? prevId;
  String? nextId;

  if (interaction) {
    prevId = ComponentId.generate(expirationTime: defaultTimeout).toString();
    nextId = ComponentId.generate(expirationTime: defaultTimeout).toString();
  }

  return (
    MessageBuilder(content: "", embeds: [
      EmbedBuilder(
        title: rss.title,
        description:
            "${rss.description} (Page ${start ~/ _maxPostsInEmbed + 1})",
        url: rss.link != null ? Uri.tryParse(rss.link!) : null,
        timestamp: DateTime.now().toUtc(),
        footer: rss.copyright != null
            ? EmbedFooterBuilder(text: rss.copyright!)
            : null,
        thumbnail: rss.image?.url != null
            ? EmbedThumbnailBuilder(url: Uri.parse(rss.image!.url!))
            : null,
        fields: rss.items
            .sublist(start, min(rss.items.length, start + _maxPostsInEmbed))
            .map((item) => EmbedFieldBuilder(
                  name: item.unlinkedTitle,
                  value: item.linkedDescription,
                  isInline: false,
                ))
            .toList(),
      )
    ], components: [
      if (interaction)
        ActionRowBuilder(
          components: [
            ButtonBuilder(
              style: ButtonStyle.primary,
              label: "Previous",
              customId: prevId,
              isDisabled: start == 0,
            ),
            ButtonBuilder(
              style: ButtonStyle.primary,
              label: "Next",
              customId: nextId,
              isDisabled: start + _maxPostsInEmbed >= rss.items.length,
            ),
          ],
        ),
    ]),
    prevId,
    nextId,
    rss
  );
}

void executer(String url, ChatContext context) async {
  int start = 0;
  var (builder, prevId, nextId, cache) = await _makeRssEmbed(url, 0);
  var message = await context.respond(builder);
  try {
    while (true) {
      var event = await context.getButtonPress(message);
      if (event.interaction.data.customId == prevId) {
        start -= _maxPostsInEmbed;
      } else if (event.interaction.data.customId == nextId) {
        start += _maxPostsInEmbed;
      }
      (builder, prevId, nextId, cache) =
          await _makeRssEmbed(url, start, cache: cache);
      message = await context.respond(builder, level: replaceMessage);
    }
  } on InteractionTimeoutException {
    (builder, _, _, _) =
        await _makeRssEmbed(url, start, interaction: false, cache: cache);
    context.respond(builder, level: replaceMessage);
  }
}

typedef Group = ExtendedChatGroup;
typedef Cmd = ExtendedChatCommand;

List<MaidChanCommand> _rssFeeds = [
  Group("bbc", "BBC News", children: [
    Cmd(
      "top",
      "Top Stories",
      id("bbc-top", (ChatContext context) {
        executer("http://feeds.bbci.co.uk/news/rss.xml", context);
      }),
    ),
    Cmd(
      "world",
      "World",
      id("bbc-world", (ChatContext context) {
        executer("http://feeds.bbci.co.uk/news/world/rss.xml", context);
      }),
    ),
  ]),
  Group("nytimes", "New York Times", children: [
    Cmd(
        "world",
        "World",
        id("nytimes-world", (ChatContext context) {
          executer("https://rss.nytimes.com/services/xml/rss/nyt/World.xml",
              context);
        })),
    Cmd(
        "apac",
        "Asia Pacific",
        id("nytimes-apac", (ChatContext context) {
          executer(
              "https://rss.nytimes.com/services/xml/rss/nyt/AsiaPacific.xml",
              context);
        })),
  ]),
  Cmd(
      "custom",
      "Custom RSS Feed",
      id("custom", (ChatContext context, String url) {
        executer(url, context);
      })),
];

final rss = ExtendedChatGroup('rss', 'RSS Feeds',
    category: Category.utility, children: _rssFeeds);
