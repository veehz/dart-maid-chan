import 'dart:io';

import 'commands/command.dart';

// Import commands
// Anime
import 'commands/anime/anime.dart' as cmd;
// Bot
import 'commands/bot/ping.dart' as cmd;
import 'commands/bot/stats.dart' as cmd;
import 'commands/bot/switch_case.dart' as cmd;
import 'commands/bot/top.dart' as cmd;
// Fun
import 'commands/fun/catgirl.dart' as cmd;
// Kawaii
import 'commands/kawaii/cuddle.dart' as cmd;
import 'commands/kawaii/hug.dart' as cmd;
import 'commands/kawaii/kiss.dart' as cmd;
import 'commands/kawaii/pat.dart' as cmd;
import 'commands/kawaii/slap.dart' as cmd;
import 'commands/kawaii/tickle.dart' as cmd;
// Moderation
import 'commands/moderation/nick.dart' as cmd;
import 'commands/moderation/purge.dart' as cmd;
// Utility
import 'commands/utility/avatar.dart' as cmd;
import 'commands/utility/randint.dart' as cmd;
import 'commands/utility/rss.dart' as cmd;
import 'commands/utility/timer.dart' as cmd;
import 'commands/utility/translate.dart' as cmd;
import 'commands/utility/urban.dart' as cmd;
import 'commands/utility/youtube.dart' as cmd;

Set<MaidChanCommand> commandSet = {
  cmd.anime,
  cmd.ping,
  cmd.stats,
  cmd.switchCase,
  cmd.top,
  cmd.catgirl,
  cmd.catgirlnsfw,
  cmd.cuddle,
  cmd.hug,
  cmd.kiss,
  cmd.pat,
  cmd.slap,
  cmd.tickle,
  cmd.nick,
  cmd.purge,
  cmd.avatar,
  cmd.randint,
  cmd.rss,
  cmd.timer,
  if (Platform.environment["DEEPL_API_KEY"] != null) cmd.translate,
  cmd.urban,
  if (Platform.environment["GOOGLE_API_KEY"] != null) cmd.youtube,
};

// Do not need to adjust below when adding commands

Map<String, MaidChanCommand> commands = {};

Map<String, MaidChanCommand> aliases = {};

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
      if (context is MessageChatContext) {
        command = context.message.content.split(" ").sublist(1).join(" ");
      }

      if (command != null) {
        final args = command.split(" ");
        var cmd = getCommand(args[0]);
        String doYouMean = cmd != null ? cmd.name : "";

        for (int i = 1; i < args.length; i++) {
          if (cmd is ExtendedChatGroup) {
            cmd = cmd.children.firstWhere((e) => e.name == args[i])
                as MaidChanCommand?;
            if (cmd != null) {
              doYouMean += " ${cmd.name}";
            } else {
              break;
            }
          }
        }

        if (cmd == null) {
          await context.respond(MessageBuilder(embeds: [
            EmbedBuilder()
              ..title = "Command not found"
              ..description =
                  "Command `$command` not found. ${doYouMean.isNotEmpty ? "Did you mean `$doYouMean`?" : ""}}"
              ..color = DiscordColor.parseHexString("FF0000")
              ..timestamp = DateTime.now().toUtc()
          ]));
          return;
        }

        await context.respond(MessageBuilder(embeds: [
          EmbedBuilder()
            ..title = cmd.name
            ..description = cmd.help ?? cmd.description
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
              if (cmd is ExtendedChatGroup)
                EmbedFieldBuilder(
                    name: "Subcommands",
                    value: cmd.children.map((e) => "`${e.name}`").join(", "),
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

MaidChanCommand? getCommand(command) {
  if (commands.containsKey(command)) {
    return commands[command];
  } else if (aliases.containsKey(command)) {
    return aliases[command];
  }

  return null;
}
