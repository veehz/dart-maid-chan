import '../command.dart';

final avatar = ExtendedChatCommand(
  'avatar',
  'Get a user\'s avatar',
  usage: 'avatar [user]',
  help: 'Get a user\'s avatar',
  category: Category.utility,
  id('avatar', (ChatContext context, [Member? input]) async {
    CdnAsset avatar =
        input?.avatar ?? input?.user?.avatar ?? context.user.avatar;

    print(avatar);
    print(context.message);

    await context.respond(MessageBuilder(embeds: [
      EmbedBuilder(
        image: EmbedImageBuilder(url: avatar.url),
      )
    ]));
  }),
);
