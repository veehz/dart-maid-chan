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
    Snowflake? mention = target?.id;

    // description, default no mention.
    String desc = "Aww... no one to kiss? Here, have one from me, <@$author>!";
    if (mention == context.client.user.id) {
      // Mention the bot.
      desc = "Aww... you want to kiss me? Here, have one from me, <@$author>!";
    } else if (mention != null) {
      // Someone else.
      desc = "<@$author> kisses <@$mention>!";
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
