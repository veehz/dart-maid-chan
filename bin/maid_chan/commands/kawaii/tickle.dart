import '../command.dart';
import 'kawaii_common.dart';

final tickle = ExtendedChatCommand(
  'tickle',
  'Tickle someone.',
  usage: 'tickle',
  category: Category.kawaii,
  id('tickle', (ChatContext context, [Member? target]) async {
    kawaiiCommand(
      'tickle',
      context,
      'tickle',
      target,
      defaultNoMention: (Snowflake author, Snowflake? mention) =>
          "Aww... no one to tickle? Here, let me tickle you, <@$author>! (heh)",
      mentionBot: (Snowflake author, Snowflake? mention) =>
          "You want to tickle me? no no No No NO NOOOOOOOOOOOOOOOOOOOOO!!!!!",
      mentionOne: (Snowflake author, Snowflake? mention) =>
          "<@$author> tickles <@${mention!}>!",
    );
  }),
);
