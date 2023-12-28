import '../command.dart';

final avatar = ExtendedChatCommand(
  'avatar',
  'Get a user\'s avatar',
  usage: 'avatar [user]',
  help: 'Get a user\'s avatar',
  category: Category.utility,
  id('avatar', (ChatContext context, [Member? input]) async {
    final CdnAsset avatar = switch (input) {
      Member(:final avatar?) => avatar,
      Member(:final id) => (await context.client.users[id].get()).avatar,
      null => context.user.avatar,
    };

    await context.respond(MessageBuilder(embeds: [
      EmbedBuilder(
        image: EmbedImageBuilder(url: avatar.url),
      )
    ]));
  }),
);
