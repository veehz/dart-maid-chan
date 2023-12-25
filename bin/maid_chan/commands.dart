import 'dart:io';

import 'commands/command.dart';

// Import commands
import 'commands/bot/ping.dart' as cmd;
import 'commands/fun/catgirl.dart' as cmd;
import 'commands/kawaii/hug.dart' as cmd;
import 'commands/moderation/nick.dart' as cmd;

Set<ExtendedChatCommand> commandSet = {
  cmd.ping,
  cmd.catgirl,
  cmd.catgirlnsfw,
  cmd.hug,
  cmd.nick,
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
    aliases: ["h"],
    usage: "help [optional: cmd name]",
    category: Category.bot,
    id('help', (ChatContext context, [String? command]) async {
      if (command != null) {
        final cmd = getCommand(command);
        if (cmd == null) {
          await context.respond(MessageBuilder(embeds: [
            EmbedBuilder()
              ..title = "Command not found"
              ..description = "Command `$command` not found"
              ..color = DiscordColor.parseHexString("FF0000")
              ..timestamp = DateTime.now().toUtc()
          ]));
          return;
        }
        await context.respond(MessageBuilder(embeds: [
          EmbedBuilder()
            ..title = cmd.name
            ..description =
                cmd.description + (cmd.help != null ? "\n${cmd.help}" : "")
            ..color = DiscordColor.parseHexString(
                Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
            ..timestamp = DateTime.now().toUtc()
            ..fields = [
              if (cmd.usage != null)
                EmbedFieldBuilder(
                    name: "Usage",
                    value:
                        Platform.environment['MAID_CHAN_PREFIX']! + cmd.usage!,
                    isInline: false),
              if (cmd.aliases.isNotEmpty)
                EmbedFieldBuilder(
                    name: "Aliases",
                    value: cmd.aliases.join(", "),
                    isInline: false),
              if (cmd.nsfw)
                EmbedFieldBuilder(name: "NSFW", value: "Yes", isInline: false),
              if (!cmd.dm && cmd.guild)
                EmbedFieldBuilder(
                    name: "Restrictions",
                    value: "Can only be used in a guild",
                    isInline: false),
              if (!cmd.guild && cmd.dm)
                EmbedFieldBuilder(
                    name: "Restrictions",
                    value: "Can only be used in a DM",
                    isInline: false),
              if (!cmd.guild && !cmd.dm)
                EmbedFieldBuilder(
                    name: "Restrictions",
                    value: "Cannot be used",
                    isInline: false),
            ]
        ]));
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
  );

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
