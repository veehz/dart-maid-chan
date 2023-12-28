import '../command.dart';
import './stats.dart' show commandUsage;

var commandsListed = 3;

final top = ExtendedChatCommand(
  'top',
  'Get the top commands used (since last restart)',
  category: Category.bot,
  usage: 'top [optional: number of commands]',
  id('top', (ChatContext context, [int? number]) async {
    number = number ?? commandsListed;
    final sorted = commandUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(commandsListed);
    await context.respond(MessageBuilder(embeds: [
      EmbedBuilder(
        title: "Top $commandsListed commands",
        fields: [
          for (var entry in top)
            EmbedFieldBuilder(
              name: entry.key,
              value: entry.value.toString(),
              isInline: true,
            )
        ],
      ),
    ]));
  }),
);
