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
    } else if (exception is InteractionTimeoutException) {
      exception.context
          .respond(MessageBuilder(content: "You took too long to respond!"));
    } else if (exception is NotEnoughArgumentsException) {
      exception.context
          .respond(MessageBuilder(content: "Not enough arguments! "));
    } else if (exception is ConverterFailedException) {
      // Most likely because argument is not what is expected.
      // We assume that it's a normal message wrongly assumed to be a command.
    } else {
      print("Exception ${exception.runtimeType} not handled: $exception");
    }
  });

  initCommands(commands);
}
