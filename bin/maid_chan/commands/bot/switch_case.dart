/// This is an example command just to see how ExtendedChatGroup would work
library;

import '../command.dart';

final switchCase = ExtendedChatGroup(
    'switchcase', 'Switch case to Upper or Lower',
    category: Category.bot,
    usage: 'switchcase <upper|lower> <text>',
    children: [
      ExtendedChatCommand(
          'upper',
          'Switch everything to upper case',
          usage: 'switchcase upper <text>',
          id('upper', (ChatContext context, String text) async {
            String actualText = text;
            if (context is MessageChatContext) {
              actualText =
                  context.message.content.split(' ').sublist(2).join(' ');
            }

            await context
                .respond(MessageBuilder(content: actualText.toUpperCase()));
          })),
      ExtendedChatCommand(
          'lower',
          'Switch everything to lower case',
          usage: 'switchcase lower <text>',
          id('lower', (ChatContext context, String text) async {
            String actualText = text;
            if (context is MessageChatContext) {
              actualText =
                  context.message.content.split(' ').sublist(2).join(' ');
            }

            await context
                .respond(MessageBuilder(content: actualText.toLowerCase()));
          })),
    ]);
