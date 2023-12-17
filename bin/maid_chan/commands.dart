import 'dart:io';

import 'commands/command.dart';

// Import commands
import 'commands/bot/ping.dart';
import 'commands/fun/catgirl.dart';
import 'commands/kawaii/hug.dart';

Set<ExtendedChatCommand> commandSet = {
  ping,
  catgirl,
  hug,
};

// Do not need to adjust below when adding commands

Map<String, ExtendedChatCommand> commands = {};

Map<String, ExtendedChatCommand> aliases = {};

void initCommands(CommandsPlugin commandsPlugin) {
  for (var command in commandSet) {
    commands[command.name] = command;
    commandsPlugin.addCommand(command);
  }

  final help = ExtendedChatCommand(
      "help",
      "Show the help menu",
      id('help', (ChatContext context) async {
        var args = context.message.content.split(' ');
        args.removeAt(0);
        if (args.isNotEmpty) {
          var embeds = <EmbedBuilder>[];
          for (var cmdName in args) {
            final cmd = getCommand(cmdName);
            if (cmd == null) {
              embeds.add(EmbedBuilder()
                ..title = "Command not found"
                ..description = "Command `$cmdName` not found"
                ..color = DiscordColor.parseHexString("FF0000")
                ..timestamp = DateTime.now().toUtc());
            } else {
              embeds.add(EmbedBuilder()
                ..title = cmd.name
                ..description = cmd.description
                ..color = DiscordColor.parseHexString(
                    Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
                ..timestamp = DateTime.now().toUtc()
                ..fields = [
                  if (cmd.usage != null)
                    EmbedFieldBuilder(
                        name: "Usage",
                        value: Platform.environment['MAID_CHAN_PREFIX']! +
                            cmd.usage!,
                        isInline: false),
                  if (cmd.aliases.isNotEmpty)
                    EmbedFieldBuilder(
                        name: "Aliases",
                        value: cmd.aliases.join(", "),
                        isInline: false),
                  if (cmd.nsfw)
                    EmbedFieldBuilder(
                        name: "NSFW", value: "Yes", isInline: false),
                ]);
            }
          }
          await context.respond(MessageBuilder()..embeds = embeds);
        } else {
          Map<Category, List<String>> categories = {};
          for (var cmd in commands.values) {
            if (!categories.containsKey(cmd.category)) {
              categories[cmd.category] = [];
            }
            categories[cmd.category]!.add(cmd.name);
          }

          var embed = EmbedBuilder()
            ..title = "Maid-chan commands"
            ..description =
                "Use `${Platform.environment['MAID_CHAN_PREFIX']!}help [command name]` for more info about a specific command"
            ..color = DiscordColor.parseHexString(
                Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
            ..fields = [
              for (var category in categories.keys)
                EmbedFieldBuilder(
                    name: category.toString().split(".")[1],
                    value: categories[category]!.map((e) => "`$e`").join(", "),
                    isInline: false)
            ];
          await context.respond(MessageBuilder()..embeds = [embed]);
        }
      }),
      aliases: ["h"],
      usage: "help [optional: cmd name]",
      category: Category.bot);

  commandsPlugin.addCommand(help);

  commands["help"] = help;
  commandSet.add(help);

  for (var cmd in commandSet) {
    for (var alias in cmd.aliases) {
      aliases[alias] = cmd;
    }
  }
}

ExtendedChatCommand? getCommand(command) {
  if (commands.containsKey(command)) {
    return commands[command];
  } else if (aliases.containsKey(command)) {
    return aliases[command];
  }

  return null;
}
