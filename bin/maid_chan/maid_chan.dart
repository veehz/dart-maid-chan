import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

import 'commands.dart';

void main() async {
  final commands = CommandsPlugin(
    prefix: mentionOr((_) => Platform.environment["MAID_CHAN_PREFIX"]!),
    guild: null,
    options: CommandsOptions(
      logErrors: true,
    ),
  );
  final client = await Nyxx.connectGateway(
    Platform.environment['MAID_CHAN_TOKEN']!,
    GatewayIntents.allUnprivileged |
        GatewayIntents.messageContent |
        GatewayIntents.guildMembers,
    options: GatewayClientOptions(plugins: [logging, cliIntegration, commands]),
  );

  client.onReady.listen((ReadyEvent event) {
    print('Ready!');
  });

  initCommands(commands);
}
