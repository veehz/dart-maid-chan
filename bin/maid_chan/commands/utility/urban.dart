import 'dart:convert';
import 'package:http/http.dart' as http;

import '../command.dart';

final String _urbanDefine = 'https://api.urbandictionary.com/v0/define?term=';
final String _urbanRandom = 'https://api.urbandictionary.com/v0/random';

final urban = ExtendedChatCommand(
  'urban',
  'Get the definition from Urban Dictionary',
  usage: 'urban [word]',
  nsfw: true,
  category: Category.utility,
  id('urban', (ChatContext context, [String? input]) async {
    if (!context.isNsfw) {
      await context.respond(MessageBuilder(
          content: 'This command can only be used in NSFW channels.'));
      return;
    }

    bool foundWord = true;
    dynamic word;
    if (input == null) {
      // get the first word from random:
      final response = await http.get(Uri.parse(_urbanRandom));
      final json = jsonDecode(response.body);
      word = json['list'][0];
    } else {
      final response = await http.get(Uri.parse(_urbanDefine + input));
      final json = jsonDecode(response.body);
      if (json['list'].isEmpty) {
        foundWord = false;
      } else {
        word = json['list'][0];
      }
    }

    if (!foundWord) {
      await context.respond(MessageBuilder(content: 'Word $input not found.'));
    } else {
      await context.respond(MessageBuilder(embeds: [
        EmbedBuilder(
          title:
              "${input == null ? "Random " : ""}Urban Dictionary definition of ${word['word']}",
          url: Uri.parse(word['permalink']),
          description: word['definition'],
          fields: [
            if (word['example'] != null)
              EmbedFieldBuilder(
                name: 'Example',
                value: word['example'],
                isInline: false,
              ),
            if (word['author'] != null)
              EmbedFieldBuilder(
                name: 'Author',
                value: word['author'],
                isInline: false,
              ),
            if (word['thumbs_up'] != null && word['thumbs_down'] != null)
              EmbedFieldBuilder(
                name: 'Rating',
                value:
                    '${word['thumbs_up']} :thumbsup: | ${word['thumbs_down']} :thumbsdown:',
                isInline: false,
              ),
          ],
        )
      ]));
    }
  }),
);