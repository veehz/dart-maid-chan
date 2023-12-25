import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

import 'commands.dart';
import 'checks.dart' as predefined_checks;

void main() async {
  final commands = CommandsPlugin(
    prefix: mentionOr((_) => Platform.environment["MAID_CHAN_PREFIX"]!),
    // Testing Guild: Maid-chan Server (invite: P23fQ6A)
    guild: Snowflake(720079670325936149),
    options: CommandsOptions(
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

  client.onReady.listen((ReadyEvent event) {
    print('Ready!');
  });

  commands.onCommandError.listen((CommandsException exception) {
    print(exception);
    if (exception is CheckFailedException) {
      AbstractCheck failed = exception.failed;
      if (failed == predefined_checks.guildOnly) {
        exception.context.respond(MessageBuilder(
            content: "This command can only be used in a guild."));
        print("Exception handled.");
      } else if (failed == predefined_checks.dmOnly) {
        exception.context.respond(
            MessageBuilder(content: "This command can only be used in a DM."));
        print("Exception handled.");
      } else if (failed == predefined_checks.disabled) {
        exception.context
            .respond(MessageBuilder(content: "This command is disabled."));
        print("Exception handled.");
      } else {
        print("Exception not handled: $exception");
      }
    } else if (exception is InteractionTimeoutException) {
      exception.context
          .respond(MessageBuilder(content: "You took too long to respond!"));
      print("Exception handled.");
    } else if (exception is NotEnoughArgumentsException) {
      exception.context
          .respond(MessageBuilder(content: "Not enough arguments! "));
      print("Exception handled.");
    } else {
      print("Exception not handled: $exception");
    }
  });

  initCommands(commands);
}
