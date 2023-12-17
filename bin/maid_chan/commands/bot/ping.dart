import '../command.dart';

// export an instance of the command, ping.
final ping = ExtendedChatCommand(
  'ping',
  'Pings the bot.',
  (ChatContext context) async {
    final basicLatency = context.client.httpHandler.latency.inMilliseconds;
    final realLatency = context.client.httpHandler.realLatency.inMilliseconds;
    final gatewayLatency = context.client.gateway.latency.inMilliseconds;
    await context.message.channel.sendMessage(MessageBuilder(
      content: '''Pong!
Basic latency: $basicLatency ms
Real latency: $realLatency ms
Gateway latency: $gatewayLatency ms''',
      replyId: context.message.id,
    ));
  },
  aliases: ['p'],
  usage: 'ping',
  category: Category.bot,
);
