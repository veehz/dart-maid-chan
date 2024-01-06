import 'dart:io';

import '../command.dart';

int commandsUsed = 0;
Map<String, int> commandUsage = {};

late final List<PartialGuild> guilds;
late final DateTime startTime;
Future<void> fetchStats(NyxxGateway client) async {
  guilds = await client.listGuilds();
  startTime = DateTime.now();
}

final stats = ExtendedChatCommand(
  'stats',
  'Get the stats of the bot',
  category: Category.bot,
  usage: 'stats',
  id('stats', (ChatContext context) {
    context.respond(MessageBuilder(embeds: [
      EmbedBuilder(
        title: "Maid-chan stats",
        fields: [
          EmbedFieldBuilder(
            name: "Guilds (cached)",
            value: guilds.length.toString(),
            isInline: true,
          ),
          EmbedFieldBuilder(
            name: "Commands used since last restart",
            value: commandsUsed.toString(),
            isInline: true,
          ),
          EmbedFieldBuilder(
            name: "Latency",
            value: "${context.client.httpHandler.realLatency.inMilliseconds}ms",
            isInline: true,
          ),
          EmbedFieldBuilder(
            name: "Uptime",
            value: DateTime.now().difference(startTime).toString(),
            isInline: true,
          ),
          EmbedFieldBuilder(
            name: "Running on Dart",
            value: "version ${Platform.version}",
            isInline: true,
          )
        ],
      ),
    ]));
  }),
);
