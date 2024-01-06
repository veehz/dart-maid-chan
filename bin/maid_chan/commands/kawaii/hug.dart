import '../command.dart';
import 'kawaii_common.dart';

final hug = ExtendedChatCommand(
  'hug',
  'Hug someone.',
  usage: 'hug',
  category: Category.kawaii,
  id('hug', (ChatContext context, [Member? target]) async {
    kawaiiCommand(
      'hug',
      context,
      'hug',
      target,
      defaultNoMention: (Snowflake author, Snowflake? mention) =>
          "Aww... no one to hug? Here, have one from me, <@$author>!",
      mentionBot: (Snowflake author, Snowflake? mention) =>
          "Aww... you want to hug me? Here, have one from me, <@$author>!",
      mentionOne: (Snowflake author, Snowflake? mention) =>
          "<@$author> hugs <@${mention!}>!",
    );
  }),
);
