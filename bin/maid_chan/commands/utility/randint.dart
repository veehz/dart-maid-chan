import '../command.dart';

final randint = ExtendedChatCommand(
  'randint',
  'Get a random number between two numbers',
  usage: 'randint [min=1] [max=6]',
  category: Category.utility,
  aliases: ['dice', 'roll'],
  id('randint', (ChatContext context, [int min = 1, int max = 6]) async {
    if (min > max) {
      context.respond(MessageBuilder(content: 'min must be less than max'));
      return;
    }

    var number = rng.nextInt(max - min) + min;

    ComponentId cid = ComponentId.generate(expirationTime: defaultTimeout);

    try {
      while (true) {
        number = rng.nextInt(max - min) + min;
        context.respond(MessageBuilder(embeds: [
          EmbedBuilder(
            title:
                (min == 1) ? '$max-sided Dice' : 'Random Integer [$min, $max]',
            description: 'You rolled a $number',
            timestamp: DateTime.now().toUtc(),
            footer: EmbedFooterBuilder(
              text: "Rolled by ${(await context.author).username}",
            ),
            color: DiscordColor.fromRgb(
              rng.nextInt(255),
              rng.nextInt(255),
              rng.nextInt(255),
            ),
          ),
        ], components: [
          ActionRowBuilder(components: [
            ButtonBuilder(
              style: ButtonStyle.primary,
              label: 'Roll again',
              customId: cid.toString(),
            ),
          ]),
        ]));

        // Wait for button press
        await context.awaitButtonPress(cid);
      }
    } on InteractionTimeoutException {
      // nyxx uses exceptions for timeouts
    }
  }),
);
