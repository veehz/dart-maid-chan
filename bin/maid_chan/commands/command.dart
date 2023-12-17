import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

export 'package:nyxx/nyxx.dart';
export 'package:nyxx_commands/nyxx_commands.dart';

extension Helper on ChatContext {
  get isNsfw => channel is Thread
      ? (channel as Thread).isNsfw
      : channel is GuildChannel
          ? (channel as GuildChannel).isNsfw
          : false;
  get message => (this as MessageChatContext).message;

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
}

enum Category { bot, fun, kawaii, moderation, utility, miscellaneous }

/// Class Command
class ExtendedChatCommand extends ChatCommand {
  /// Category of the command
  Category category;

  /// If the command is nsfw
  bool nsfw;

  /// Usage
  String? usage;

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
  }) : super(name, description, execute,
            aliases: aliases,
            children: children,
            checks: checks,
            singleChecks: singleChecks,
            options: options,
            localizedNames: localizedNames,
            localizedDescriptions: localizedDescriptions);
}
