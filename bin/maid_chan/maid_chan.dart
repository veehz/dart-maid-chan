import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

import 'commands.dart';
import 'commands/components/checks.dart' as predefined_checks;
import 'commands/bot/stats.dart' as stats; // Fetch stats

void main() async {
  final commands = CommandsPlugin(
    prefix: mentionOr((_) => Platform.environment["MAID_CHAN_PREFIX"]!),
    // Testing Guild: Maid-chan Server (invite: P23fQ6A)
    guild: const Snowflake(720079670325936149),
    options: const CommandsOptions(
      logErrors: true,
    ),
  );
  final client = await Nyxx.connectGateway(
    Platform.environment['MAID_CHAN_TOKEN']!,
    GatewayIntents.allUnprivileged |
        GatewayIntents.messageContent |
        GatewayIntents.guildMembers |
        GatewayIntents.guildModeration,
    options: GatewayClientOptions(plugins: [logging, cliIntegration, commands]),
  );

  client.onReady.listen((ReadyEvent event) async {
    print('Ready!');
    await stats.fetchStats(client);
    print("I am in ${stats.guilds.length} guilds.");
  });

  commands.onPreCall.listen((CommandContext context) {
    stats.commandsUsed++;
    stats.commandUsage
        .update(context.command.name, (value) => value + 1, ifAbsent: () => 1);
  });

  commands.onCommandError.listen((CommandsException exception) {
    if (exception is CheckFailedException) {
      AbstractCheck failed = exception.failed;
      if (failed == predefined_checks.guildOnly) {
        exception.context.respond(MessageBuilder(
            content: "This command can only be used in a guild."));
      } else if (failed == predefined_checks.dmOnly) {
        exception.context.respond(
            MessageBuilder(content: "This command can only be used in a DM."));
      } else if (failed == predefined_checks.disabled) {
        exception.context
            .respond(MessageBuilder(content: "This command is disabled."));
      } else {
        print("Exception ${exception.runtimeType} not handled: $exception");
      }
    } else if (exception is NotEnoughArgumentsException) {
      exception.context
          .respond(MessageBuilder(content: "Not enough arguments! "));
    } else {
      print("Exception ${exception.runtimeType} not handled: $exception");
    }
  });

  initCommands(commands);
}
