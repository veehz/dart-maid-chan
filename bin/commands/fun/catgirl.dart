import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../command.dart';

final catgirl = ExtendedChatCommand(
  'catgirl',
  'Returns a random catgirl. Will only return NSFW catgirls in NSFW channels.',
  (ChatContext context) async {
    final rawUrl =
        'https://nekos.moe/api/v1/random/image?count=1&nsfw=${context.isNsfw ? 'true' : 'false'}';
    // Fetch from: 'https://nekos.moe/api/v1/random/image?count=1'
    final url = Uri.parse(rawUrl);
    // send a message first to let the user know we're working on it
    var message = await context.respond(MessageBuilder(
        content: 'Fetching catgirl...', replyId: context.message.id));
    final response = await http.get(url, headers: {
      'User-Agent': 'maid-chan/0.0.1',
    });
    if (response.statusCode != 200) {
      await message
          .edit(MessageUpdateBuilder(content: 'Failed to fetch catgirl.'));
      return;
    }
    final imageUrl = Uri.parse(
        'https://nekos.moe/image/${jsonDecode(response.body)['images'][0]['id']}');
    final embed = EmbedBuilder()
      ..color = DiscordColor.parseHexString(Platform.environment["DEFAULT_COLOUR"]!)
      ..image = EmbedImageBuilder(url: imageUrl);
    await message.edit(MessageUpdateBuilder(content: '', embeds: [embed]));
  },
  usage: 'catgirl',
  category: Category.fun,
);
