import '../command.dart';

final nick = ExtendedChatCommand(
  'nick',
  'Change a user\'s nickname',
  dm: false,
  usage: 'nick <user> <new nickname>',
  help: 'Change a user\'s nickname',
  category: Category.moderation,
  id('nick', (ChatContext context, Member target, String newNick) async {
    if (context.notGuild() || context.notSlash()) return;
    if (context.noPermission(Permissions.manageNicknames)!) return;

    final oldNick = target.nick ?? target.user?.username ?? 'Unknown';
    try {
      await target.update(MemberUpdateBuilder(nick: newNick));
    } on HttpResponseError catch (e) {
      print(e.errorCode);
      context.respond(MessageBuilder(content: "Couldn't change nickname :/"));
      return;
    }
    context.respond(MessageBuilder(content: 'Successfully changed nickname of $oldNick to $newNick'));
  }),
);
