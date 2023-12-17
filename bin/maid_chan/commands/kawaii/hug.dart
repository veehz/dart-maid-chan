import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../command.dart';

final hug = ExtendedChatCommand(
  'hug',
  'Hug someone.',
  (ChatContext context) async {
    final url = Uri.parse("https://nekos.life/api/v2/img/hug");
    final response = await http.get(url, headers: {
      'User-Agent': 'maid-chan/0.0.1',
    });

    if (response.statusCode != 200) {
      await context.respond(MessageBuilder(content: 'Failed to fetch image.'));
      return;
    }

    final imageUrl = Uri.parse(jsonDecode(response.body)["url"] as String);

    if (context.message.author is WebhookAuthor) return;

    Snowflake author = context.message.author.id;
    List<Snowflake> mentions =
        List.from(context.message.mentions.map((e) => (e.id as Snowflake)));

    String desc = "Placeholder. Should not be seen.";
    if (mentions.isEmpty) {
      // No one.
      desc = "Aww... no one to hug? Here, have a hug from me, <@$author>!";
    } else if (mentions.length == 1 && mentions[0] == context.client.user.id) {
      // Only the bot.
      desc = "Aww... you want to hug me? Here, have a hug from me, <@$author>!";
    } else if (mentions.length == 1) {
      // Someone else.
      desc = "<@$author> hugs <@${mentions[0]}>!";
    } else if (mentions.contains(context.client.user.id)) {
      // The bot and someone else.
      mentions.remove(context.client.user.id);
      desc = "<@$author> hugs <@${mentions.join(">, <@")}> and me!";
    } else {
      // Multiple people.
      desc = "<@$author> hugs <@${mentions.join(">, <@")}>!";
    }

    final embed = EmbedBuilder()
      ..description = desc
      ..color = DiscordColor.parseHexString(Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
      ..image = EmbedImageBuilder(url: imageUrl);

    await context.respond(MessageBuilder(embeds: [embed]));
  },
  usage: 'hug',
  category: Category.kawaii,
);
