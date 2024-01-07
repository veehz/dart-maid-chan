import '../command.dart';

import '../../../api/deepl.dart';
import '../components/checks.dart' show apiCooldown;

final translate = ExtendedChatCommand(
  'translate',
  'Translate a text',
  usage: 'translate [target_lang] [text]',
  help:
      'Translate a text to a target language. Available languages can be found '
      '[here](https://developers.deepl.com/docs/resources/supported-languages#target-languages).',
  category: Category.utility,
  checks: [apiCooldown],
  id('translate', (ChatContext context, String targetLang, String input) async {
    String translationInput = input;
    if (context is MessageChatContext) {
      final args = context.message.content.split(' ');
      args.removeAt(0);
      args.removeAt(0);
      translationInput = args.join(' ');
    }

    if (translationInput.isEmpty) {
      context.respond(
          MessageBuilder(content: 'Please provide a text to translate'));
    }

    // check if targetLang is in languages
    if (!languages.containsKey(targetLang.toUpperCase())) {
      context.respond(MessageBuilder(
          content: 'Please provide a valid target language.'
              'You can find a list of valid languages '
              '[here](https://developers.deepl.com/docs/resources/supported-languages#target-languages).'));
    }

    final (result, response, success) =
        await translateText(translationInput, targetLang.toUpperCase());
    if (!success) {
      context.respond(MessageBuilder(content: result));
      return;
    }

    if (targetLang.toUpperCase() == 'EN') {
      context.respond(MessageBuilder(
          content: "Next time, please use EN-GB or EN-US instead of EN."));
    }

    if (targetLang.toLowerCase() == 'PT') {
      context.respond(MessageBuilder(
          content: "Next time, please use PT-BR or PT-PT instead of PT."));
    }

    context.respond(MessageBuilder(
        content:
            'Translated "$translationInput" (${response["translations"][0]["detected_source_language"]}) to ${targetLang.toUpperCase()}:\n${response["translations"][0]["text"]}'));
  }),
);
