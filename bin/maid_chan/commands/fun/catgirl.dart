import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../command.dart';

var _catgirlSfw = <Uri>[];
var _catgirlNsfw = <Uri>[];
const _catgirlSyncAmount = 50;

final catgirl = ExtendedChatCommand(
  'catgirl',
  'Returns a random catgirl. Will only return NSFW catgirls in NSFW channels.',
  usage: 'catgirl',
  aliases: ['c', 'cg'],
  category: Category.fun,
  id('catgirl', (ChatContext context) async {
    Message? message;

    if (context.isNsfw && _catgirlNsfw.isEmpty) {
      message =
          await context.respond(MessageBuilder(content: 'Fetching catgirl...'));
      const rawUrl =
          'https://nekos.moe/api/v1/random/image?count=$_catgirlSyncAmount&nsfw=true';
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
        _catgirlNsfw.add(Uri.parse('https://nekos.moe/image/${image['id']}'));
      }
    } else if (!context.isNsfw && _catgirlSfw.isEmpty) {
      message =
          await context.respond(MessageBuilder(content: 'Fetching catgirl...'));
      const rawUrl =
          'https://nekos.moe/api/v1/random/image?count=$_catgirlSyncAmount&nsfw=false';
      final url = Uri.parse(rawUrl);
      final response = await http.get(url, headers: {
        'User-Agent': 'maid-chan/0.1.0',
      });
      if (response.statusCode != 200) {
        message
            .edit(MessageUpdateBuilder(content: 'Failed to fetch catgirls.'));
        return;
      }

      final images = jsonDecode(response.body)['images'];
      for (var image in images) {
        _catgirlSfw.add(Uri.parse('https://nekos.moe/image/${image['id']}'));
      }
    }

    final imageUrl =
        context.isNsfw ? _catgirlNsfw.removeLast() : _catgirlSfw.removeLast();

    final embed = EmbedBuilder()
      ..color = DiscordColor.parseHexString(
          Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
      ..image = EmbedImageBuilder(url: imageUrl);

    if (message != null) {
      message.edit(MessageUpdateBuilder(content: '', embeds: [embed]));
    } else {
      context.respond(MessageBuilder(embeds: [embed]));
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

    if (_catgirlNsfw.isEmpty) {
      const rawUrl =
          'https://nekos.moe/api/v1/random/image?count=$_catgirlSyncAmount&nsfw=true';
      final url = Uri.parse(rawUrl);
      final response = await http.get(url, headers: {
        'User-Agent': 'maid-chan/0.1.0',
      });
      if (response.statusCode != 200) {
        message
            .edit(MessageUpdateBuilder(content: 'Failed to fetch catgirls.'));
        return;
      }

      final images = jsonDecode(response.body)['images'];
      for (var image in images) {
        _catgirlNsfw.add(Uri.parse('https://nekos.moe/image/${image['id']}'));
      }
    }

    final imageUrl = _catgirlNsfw.removeLast();

    final embed = EmbedBuilder()
      ..color = DiscordColor.parseHexString(
          Platform.environment["MAID_CHAN_DEFAULT_COLOUR"]!)
      ..image = EmbedImageBuilder(url: imageUrl);
    message.edit(MessageUpdateBuilder(content: '', embeds: [embed]));
  }),
);
