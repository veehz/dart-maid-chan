import '../command.dart';

final randint = ExtendedChatCommand(
  'randint',
  'Get a random number between two numbers',
  usage: 'randint [min=1] [max=6]',
  category: Category.utility,
  aliases: ['dice', 'roll'],
  id('randint', (ChatContext context, [int min = 1, int max = 6]) {
    if (min > max) {
      context.respond(MessageBuilder(content: 'min must be less than max'));
      return;
    }

    final number = rng.nextInt(max - min) + min;
    context.respond(MessageBuilder(content: number.toString()));
  }),
);
