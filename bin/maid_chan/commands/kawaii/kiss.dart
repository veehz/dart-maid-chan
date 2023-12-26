import 'dart:io';

import '../command.dart';
import '../../../api/nekoslife.dart';

final kiss = ExtendedChatCommand(
  'kiss',
  'Kiss someone.',
  usage: 'kiss',
  category: Category.kawaii,
  id('kiss', (ChatContext context, [Member? target]) async {
    final imageUrl = await image('kiss');

    if (imageUrl == null) {
      await context.respond(MessageBuilder(content: 'Failed to fetch image.'));
      return;
    }

    Snowflake author = context.authorId!;
    List<Snowflake> mentions = [];

    // Support for text commands.
    if (context.message != null) {
      mentions.addAll(context.message.mentions.map((e) => (e.id as Snowflake)));
    }

    // Support for slash commands.
    if (target != null && !mentions.contains(target.id)) {
      mentions.add(target.id);
    }

    String desc = "Placeholder. Should not be seen.";
    if (mentions.isEmpty) {
      // No one.
      desc = "Aww... no one to kiss? Here, have a kiss from me, <@$author>!";
    } else if (mentions.length == 1 && mentions[0] == context.client.user.id) {
      // Only the bot.
      desc = "Aww... you want to kiss me? Here, have a kiss from me, <@$author>!";
    } else if (mentions.length == 1) {
      // Someone else.
      desc = "<@$author> kisses <@${mentions[0]}>!";
    } else if (mentions.contains(context.client.user.id)) {
      // The bot and someone else.
      mentions.remove(context.client.user.id);
      desc = "<@$author> kisses <@${mentions.join(">, <@")}> and me!";
    } else {
      // Multiple people.
      desc = "<@$author> kisses <@${mentions.join(">, <@")}>!";
    }

    await context.respond(MessageBuilder(embeds: [
      EmbedBuilder(
        description: desc,
        color: DiscordColor.parseHexString(
            Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!),
        image: EmbedImageBuilder(url: imageUrl),
      )
    ]));
  }),
);
