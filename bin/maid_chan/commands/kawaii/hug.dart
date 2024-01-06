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
      context.respond(MessageBuilder(content: 'Failed to fetch image.'));
      return;
    }

    Snowflake author = context.authorId!;
    Snowflake? mention = target?.id;

    // description, default no mention.
    String desc = "Aww... no one to hug? Here, have one from me, <@$author>!";
    if (mention == context.client.user.id) {
      // Mention the bot.
      desc = "Aww... you want to hug me? Here, have one from me, <@$author>!";
    } else if (mention != null) {
      // Someone else.
      desc = "<@$author> hugs <@$mention>!";
    }

    context.respond(MessageBuilder(embeds: [
      EmbedBuilder(
        description: desc,
        color: DiscordColor.parseHexString(
            Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!),
        image: EmbedImageBuilder(url: imageUrl),
      )
    ]));
  }),
);
