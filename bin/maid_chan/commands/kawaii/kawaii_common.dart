/// Code for all kawaii commands.
library;

import 'dart:io';

import '../command.dart';
import '../../../api/nekoslife.dart';

void kawaiiCommand(
  String cmd,
  ChatContext context,
  String api,
  Member? target, {
  required String Function(Snowflake, Snowflake?) defaultNoMention,
  required String Function(Snowflake, Snowflake?) mentionBot,
  required Function(Snowflake, Snowflake?) mentionOne,
}) async {
  final imageUrl = await image(api);

  if (imageUrl == null) {
    context.respond(MessageBuilder(content: 'Failed to fetch image.'));
    return;
  }

  Snowflake author = context.authorId!;
  Snowflake? mention = target?.id;

  // description, default no mention.
  String desc = defaultNoMention(author, mention);
  if (mention == context.client.user.id) {
    // Mention the bot.
    desc = mentionBot(author, mention);
  } else if (mention != null) {
    // Someone else.
    desc = mentionOne(author, mention);
  }

  // TODO: Do it to self?

  context.respond(MessageBuilder(embeds: [
    EmbedBuilder(
      description: desc,
      color: DiscordColor.parseHexString(
          Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!),
      image: EmbedImageBuilder(url: imageUrl),
    )
  ]));
}
