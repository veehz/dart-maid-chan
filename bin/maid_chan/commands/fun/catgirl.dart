import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../command.dart';

var catgirlSfw = <Uri>[];
var catgirlNsfw = <Uri>[];
const catgirlSyncAmount = 50;

final catgirl = ExtendedChatCommand(
  'catgirl',
  'Returns a random catgirl. Will only return NSFW catgirls in NSFW channels.',
  usage: 'catgirl',
  category: Category.fun,
  id('catgirl', (ChatContext context) async {
    Message? message;

    if (context.isNsfw && catgirlNsfw.isEmpty) {
      message =
          await context.respond(MessageBuilder(content: 'Fetching catgirl...'));
      final rawUrl =
          'https://nekos.moe/api/v1/random/image?count=$catgirlSyncAmount&nsfw=true';
      final url = Uri.parse(rawUrl);
      final response = await http.get(url, headers: {
        'User-Agent': 'maid-chan/0.1.0',
      });
      if (response.statusCode != 200) {
        await message
            .edit(MessageUpdateBuilder(content: 'Failed to fetch catgirls.'));
        return;
      }

      final images = jsonDecode(response.body)['images'];
      for (var image in images) {
        catgirlNsfw.add(Uri.parse('https://nekos.moe/image/${image['id']}'));
      }
    } else if (!context.isNsfw && catgirlSfw.isEmpty) {
      message =
          await context.respond(MessageBuilder(content: 'Fetching catgirl...'));
      final rawUrl =
          'https://nekos.moe/api/v1/random/image?count=$catgirlSyncAmount&nsfw=false';
      final url = Uri.parse(rawUrl);
      final response = await http.get(url, headers: {
        'User-Agent': 'maid-chan/0.1.0',
      });
      if (response.statusCode != 200) {
        await message
            .edit(MessageUpdateBuilder(content: 'Failed to fetch catgirls.'));
        return;
      }

      final images = jsonDecode(response.body)['images'];
      for (var image in images) {
        catgirlSfw.add(Uri.parse('https://nekos.moe/image/${image['id']}'));
      }
    }

    final imageUrl =
        context.isNsfw ? catgirlNsfw.removeLast() : catgirlSfw.removeLast();

    final embed = EmbedBuilder()
      ..color = DiscordColor.parseHexString(
          Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
      ..image = EmbedImageBuilder(url: imageUrl);

    if (message != null) {
      await message.edit(MessageUpdateBuilder(content: '', embeds: [embed]));
    } else {
      await context.respond(MessageBuilder(embeds: [embed]));
    }
  }),
);

final catgirlnsfw = ExtendedChatCommand(
  'catgirlnsfw',
  'Returns a random nsfw catgirl. Only in DMs.',
  guild: false,
  usage: 'catgirlnsfw',
  category: Category.fun,
  id('catgirlnsfw', (ChatContext context) async {
    var message =
        await context.respond(MessageBuilder(content: 'Fetching catgirl...'));

    if (catgirlNsfw.isEmpty) {
      final rawUrl =
          'https://nekos.moe/api/v1/random/image?count=$catgirlSyncAmount&nsfw=true';
      final url = Uri.parse(rawUrl);
      final response = await http.get(url, headers: {
        'User-Agent': 'maid-chan/0.1.0',
      });
      if (response.statusCode != 200) {
        await message
            .edit(MessageUpdateBuilder(content: 'Failed to fetch catgirls.'));
        return;
      }

      final images = jsonDecode(response.body)['images'];
      for (var image in images) {
        catgirlNsfw.add(Uri.parse('https://nekos.moe/image/${image['id']}'));
      }
    }

    final imageUrl = catgirlNsfw.removeLast();

    final embed = EmbedBuilder()
      ..color = DiscordColor.parseHexString(
          Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
      ..image = EmbedImageBuilder(url: imageUrl);
    await message.edit(MessageUpdateBuilder(content: '', embeds: [embed]));
  }),
);
