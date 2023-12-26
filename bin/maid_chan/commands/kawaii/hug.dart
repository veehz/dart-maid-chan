import 'dart:io';

import '../command.dart';
import '../../../api/nekoslife.dart';

final hug = ExtendedChatCommand(
  'hug',
  'Hug someone.',
  usage: 'hug',
  category: Category.kawaii,
  id('hug', (ChatContext context, [Member? target]) async {
    final imageUrl = await image('hug');

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
