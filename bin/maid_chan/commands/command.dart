import 'dart:io';
import 'dart:math';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'components/checks.dart' as predefined_checks;

export 'package:nyxx/nyxx.dart';
export 'package:nyxx_commands/nyxx_commands.dart';

final rng = Random(DateTime.now().millisecondsSinceEpoch);

final defaultTimeout = Duration(
    seconds:
        int.parse(Platform.environment["DEFAULT_TIMEOUT_SECONDS"] ?? "999"));

extension Helper on ChatContext {
  bool get isNsfw => channel is Thread
      ? (channel as Thread).isNsfw
      : channel is GuildChannel
          ? (channel as GuildChannel).isNsfw
          : false;
  Message? get message =>
      this is MessageChatContext ? (this as MessageChatContext).message : null;
  Snowflake? get authorId => this is MessageChatContext
      ? (this as MessageChatContext).message.author.id
      : this is InteractionChatContext
          ? (this as InteractionChatContext).member!.id
          : null;
  Future<User> get author => client.users[authorId!].get();

  // Support for text commands.
  List<User> get mentions => message?.mentions ?? [];

  /// Returns true if the channel is not nsfw.
  bool notNsfw() {
    if (!isNsfw) {
      respond(MessageBuilder(
        content: "This command can only be used in NSFW channels.",
      ));
      return true;
    }
    return false;
  }

  /// Returns true if the author has no permission to use the command.
  bool? noPermission(Flag<Permissions> permissions) {
    if (member == null) return null;

    if (!member!.permissions!.has(permissions)) {
      respond(MessageBuilder(
        content:
            "You do not have the required permissions to use this command.",
      ));
      return true;
    }
    return false;
  }

  /// Returns true if text command is used instead of slash command.
  /// If true, it will respond with a message telling the user to use slash commands.
  bool notSlash() {
    if (this is MessageChatContext) {
      respond(MessageBuilder(
        content:
            "This command can only be used as a slash command. Please use slash commands instead.",
      ));
      return true;
    }
    return false;
  }

  /// Returns true if the command is not used in a guild.
  /// If true, it will respond with a message telling the user to use in a guild.
  bool notGuild() {
    if (guild == null) {
      respond(MessageBuilder(
        content: "This command can only be used in a guild.",
      ));
      return true;
    }
    return false;
  }
}

enum Category {
  anime,
  bot,
  fun,
  kawaii,
  moderation,
  utility,
  miscellaneous,
}

mixin MaidChanCommand on ChatCommandComponent {
  /// Category of the command
  Category get category;

  /// If the command is nsfw
  bool get nsfw;

  /// Usage
  String? get usage;

  /// Help shown in the help menu. If null, description will be used.
  String? get help;

  /// Indicate if the command can be used in DMs (default: true)
  bool get dm;

  /// Indicate if the command can be used in guilds (default: true)
  bool get guild;
}

/// Class Command
class ExtendedChatCommand extends ChatCommand with MaidChanCommand {
  /// Category of the command
  @override
  Category category;

  /// If the command is nsfw
  @override
  bool nsfw;

  /// Usage
  @override
  String? usage;

  /// Help shown in the help menu. If null, description will be used.
  @override
  String? help;

  /// Indicate if the command can be used in DMs (default: true)
  @override
  bool dm = true;

  /// Indicate if the command can be used in guilds (default: true)
  @override
  bool guild = true;

  // We do not understand how ChatCommand works internally, so do not use super parameters.
  // ignore: use_super_parameters
  ExtendedChatCommand(
    String name,
    String description,
    Function execute, {
    Iterable<String> aliases = const [],
    Iterable<ChatCommandComponent> children = const [],
    Iterable<AbstractCheck> checks = const [],
    Iterable<AbstractCheck> singleChecks = const [],
    CommandOptions options = const CommandOptions(),
    Map<Locale, String>? localizedNames,
    Map<Locale, String>? localizedDescriptions,
    this.category = Category.miscellaneous,
    this.nsfw = false,
    this.usage,
    this.help,
    this.dm = true,
    this.guild = true,
  }) : super(name, description, execute,
            aliases: aliases,
            children: children,
            checks: [
              if (!dm && guild) predefined_checks.guildOnly,
              if (!guild && dm) predefined_checks.dmOnly,
              if (!guild && !dm) predefined_checks.disabled,
              ...checks
            ],
            singleChecks: singleChecks,
            options: options,
            localizedNames: localizedNames,
            localizedDescriptions: localizedDescriptions);
}

class ExtendedChatGroup extends ChatGroup with MaidChanCommand {
  /// Category of the command
  @override
  Category category;

  /// If the command is nsfw
  @override
  bool nsfw;

  /// Usage
  @override
  String? usage;

  /// Help shown in the help menu. If null, description will be used.
  @override
  String? help;

  /// Indicate if the command can be used in DMs (default: true)
  @override
  bool dm = true;

  /// Indicate if the command can be used in guilds (default: true)
  @override
  bool guild = true;

  // We do not understand how ChatGroup works internally, so do not use super parameters.
  // ignore: use_super_parameters
  ExtendedChatGroup(
    String name,
    String description, {
    List<String> aliases = const [],
    Iterable<ChatCommandComponent> children = const [],
    Iterable<AbstractCheck> checks = const [],
    CommandOptions options = const CommandOptions(),
    Map<Locale, String>? localizedNames,
    Map<Locale, String>? localizedDescriptions,
    this.category = Category.miscellaneous,
    this.nsfw = false,
    this.usage,
    this.help,
    this.dm = true,
    this.guild = true,
  }) : super(name, description,
            aliases: aliases,
            children: children,
            checks: [
              if (!dm && guild) predefined_checks.guildOnly,
              if (!guild && dm) predefined_checks.dmOnly,
              if (!guild && !dm) predefined_checks.disabled,
              ...checks
            ],
            options: options,
            localizedNames: localizedNames,
            localizedDescriptions: localizedDescriptions);
}
