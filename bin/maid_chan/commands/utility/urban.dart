import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../checks.dart' show apiCooldown;
import '../command.dart';

const String _urbanDefine = 'https://api.urbandictionary.com/v0/define?term=';
const String _urbanRandom = 'https://api.urbandictionary.com/v0/random';

final urban = ExtendedChatCommand(
  'urban',
  'Get the definition from Urban Dictionary',
  usage: 'urban [word]',
  nsfw: true,
  category: Category.utility,
  checks: [apiCooldown],
  id('urban', (ChatContext context, [String? input]) async {
    if (!context.isNsfw) {
      context.respond(MessageBuilder(
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
      context.respond(MessageBuilder(content: 'Word $input not found.'));
    } else {
      context.respond(MessageBuilder(embeds: [
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
