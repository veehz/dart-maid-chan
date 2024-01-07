import '../command.dart';

final purge = ExtendedChatCommand(
  'purge',
  'Purge messages.',
  usage: 'purge <amount>',
  category: Category.moderation,
  id('purge', (ChatContext context, int amount) async {
    if(context.notGuild()) return;
    if(context.noPermission(Permissions.manageMessages)!) return;

    if (amount < 1) {
      context.respond(MessageBuilder(content: 'Amount must be greater than 0'));
      return;
    }

    if (amount > 100) {
      context.respond(MessageBuilder(content: 'Amount must be less than 100'));
      return;
    }

    final messages = await context.channel.messages.fetchMany(limit: amount);
    final snowflakes = messages.map((e) => e.id);
    context.channel.messages.bulkDelete(snowflakes);
  }),
);
