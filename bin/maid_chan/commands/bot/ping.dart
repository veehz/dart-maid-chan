import '../command.dart';

// export an instance of the command, ping.
final ping = ExtendedChatCommand(
  'ping',
  'Pings the bot, fetch latency.',
  (ChatContext context) async {
    final basicLatency = context.client.httpHandler.latency.inMilliseconds;
    final realLatency = context.client.httpHandler.realLatency.inMilliseconds;
    final gatewayLatency = context.client.gateway.latency.inMilliseconds;
    await context.respond(MessageBuilder(
      content: 'Pong!\n'
          'Basic latency: $basicLatency ms\n'
          'Real latency: $realLatency ms\n'
          'Gateway latency: $gatewayLatency ms',
    ));
  },
  aliases: ['p'],
  usage: 'ping',
  category: Category.bot,
);