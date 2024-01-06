import '../command.dart';
import 'kawaii_common.dart';

final slap = ExtendedChatCommand(
  'slap',
  'Slap someone.',
  usage: 'slap',
  category: Category.kawaii,
  id('slap', (ChatContext context, [Member? target]) async {
    kawaiiCommand(
      'slap',
      context,
      'slap',
      target,
      defaultNoMention: (Snowflake author, Snowflake? mention) =>
          "Aww... no one to slap? Here, let me slap you, <@$author>! (heh)",
      mentionBot: (Snowflake author, Snowflake? mention) =>
          "Slap me? HOW DARE YOU!",
      mentionOne: (Snowflake author, Snowflake? mention) =>
          "<@$author> slaps <@${mention!}>!",
    );
  }),
);
