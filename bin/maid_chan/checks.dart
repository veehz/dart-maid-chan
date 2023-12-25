import 'package:nyxx_commands/nyxx_commands.dart';

GuildCheck guildOnly = GuildCheck.all(name: "guildOnly");
GuildCheck dmOnly = GuildCheck.none(name: "dmOnly");
GuildCheck disabled = GuildCheck.any([], name: "disabled");
