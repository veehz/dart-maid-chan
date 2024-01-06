import 'dart:async';

import '../command.dart';

final timer = ExtendedChatCommand(
  'timer',
  'Set a timer',
  usage: 'timer <seconds> [message]',
  category: Category.utility,
  id('timer', (ChatContext context, int seconds, [String? message]) {
    if (context is MessageChatContext) {
      // get full message
      message = context.message.content.split(' ').sublist(2).join(' ');
    }

    var msg = context.respond(MessageBuilder(content: 'Timer: $seconds'));
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      (await msg).edit(MessageUpdateBuilder(content: 'Timer: ${seconds - timer.tick}'));
      if (timer.tick == seconds) {
        timer.cancel();
        context.respond(
            MessageBuilder(
                content:
                    "<@${context.authorId!}> Time's up! ${message != null ? "Message: $message" : ""}"),
            level: const ResponseLevel(
                hideInteraction: false,
                isDm: false,
                mention: true,
                preserveComponentMessages: false));
      }
    });
  }),
);
