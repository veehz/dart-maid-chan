import '../command.dart';
import 'kawaii_common.dart';

final kiss = ExtendedChatCommand(
  'kiss',
  'Kiss someone.',
  usage: 'kiss',
  category: Category.kawaii,
  id('kiss', (ChatContext context, [Member? target]) async {
    kawaiiCommand(
      'kiss',
      context,
      'kiss',
      target,
      defaultNoMention: (Snowflake author, Snowflake? mention) =>
          "Aww... no one to kiss? Here, have one from me, <@$author>!",
      mentionBot: (Snowflake author, Snowflake? mention) =>
          "Aww... you want to kiss me? Here, have one from me, <@$author>!",
      mentionOne: (Snowflake author, Snowflake? mention) =>
          "<@$author> kisses <@${mention!}>!",
    );
  }),
);
