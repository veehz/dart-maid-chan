import 'package:nyxx_commands/nyxx_commands.dart';

GuildCheck guildOnly = GuildCheck.all(name: "guildOnly");
GuildCheck dmOnly = GuildCheck.none(name: "dmOnly");
GuildCheck disabled = GuildCheck.any([], name: "disabled");
CooldownCheck apiCooldown = CooldownCheck(
    CooldownType.user, const Duration(seconds: 30),
    name: "apiCooldown");
