import '../command.dart';
import 'kawaii_common.dart';

final cuddle = ExtendedChatCommand(
  'cuddle',
  'Cuddle someone.',
  usage: 'cuddle',
  category: Category.kawaii,
  id('cuddle', (ChatContext context, [Member? target]) async {
    kawaiiCommand(
      'cuddle',
      context,
      'cuddle',
      target,
      defaultNoMention: (Snowflake author, Snowflake? mention) =>
          "Aww... no one to cuddle? Here, let me cuddle you, <@$author>!",
      mentionBot: (Snowflake author, Snowflake? mention) =>
          "Aww... you want to cuddle me? Here, <@$author>!",
      mentionOne: (Snowflake author, Snowflake? mention) =>
          "<@$author> cuddles <@${mention!}>!",
    );
  }),
);
