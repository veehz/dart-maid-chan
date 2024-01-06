import '../command.dart';
import 'kawaii_common.dart';

final pat = ExtendedChatCommand(
  'pat',
  'Pat someone.',
  usage: 'pat',
  category: Category.kawaii,
  id('pat', (ChatContext context, [Member? target]) async {
    kawaiiCommand(
      'pat',
      context,
      'pat',
      target,
      defaultNoMention: (Snowflake author, Snowflake? mention) =>
          "Aww... no one to pat? Here, let me pat you, <@$author>! *pat pat*",
      mentionBot: (Snowflake author, Snowflake? mention) =>
          "Pat me? Hehe, thanks!",
      mentionOne: (Snowflake author, Snowflake? mention) =>
          "<@$author> pats <@${mention!}>!",
    );
  }),
);
