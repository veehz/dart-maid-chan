import '../../../api/anilist.dart' as anilist;

import '../command.dart';

final anime = ExtendedChatCommand(
  'anime',
  'Search for an anime on AniList',
  category: Category.anime,
  help:
      'Search for an anime on AniList. Will only return nsfw results in NSFW channels.',
  usage: 'anime <search term>',
  id('anime', (ChatContext context, String search) async {
    if (context is MessageChatContext) {
      // get full string
      var args = context.message.content.split(' ');
      args.removeAt(0);
      search = args.join(' ');
    }

    var (data, response) = await anilist.search(search,
        type: anilist.AnilistType.ANIME, isNsfw: context.isNsfw);
    if (data == null) {
      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          await context.respond(MessageBuilder(content: 'No results found.'));
        } else {
          await context
              .respond(MessageBuilder(content: 'Failed to fetch anime. AniList responded with ${response.statusCode}.'));
        }
      } else {
        await context.respond(MessageBuilder(content: response.body));
      }
      return;
    }

    final embed = EmbedBuilder(
      title:
          "${data['title']['english']} ${data['title']['native']} (${data['title']['romaji']})",
      url: Uri.parse(data['siteUrl']),
      description: anilist.anilistUnescapeHtml(data['description']),
      color: DiscordColor.parseHexString(data['coverImage']['color']),
      timestamp: DateTime.now().toUtc(),
      image:
          EmbedImageBuilder(url: Uri.parse(data['coverImage']['extraLarge'])),
      fields: [
        if (data['episodes'] != null)
          EmbedFieldBuilder(
              name: 'Episodes',
              value: data['episodes'].toString(),
              isInline: true),
        if (data['duration'] != null)
          EmbedFieldBuilder(
              name: 'Duration',
              value: data['duration'].toString(),
              isInline: true),
        if (data['format'] != null)
          EmbedFieldBuilder(
              name: 'Format', value: data['format'], isInline: true),
        if (data['status'] != null)
          EmbedFieldBuilder(
              name: 'Status', value: data['status'], isInline: true),
        if (data['startDate'] != null)
          EmbedFieldBuilder(
              name: 'Start Date',
              value:
                  '${data['startDate']['year']}-${data['startDate']['month']}-${data['startDate']['day']}',
              isInline: true),
        if (data['endDate'] != null && data['status'] != 'FINISHED')
          EmbedFieldBuilder(
              name: 'End Date',
              value:
                  '${data['endDate']['year']}-${data['endDate']['month']}-${data['endDate']['day']}',
              isInline: true),
        if (data['season'] != null && data['seasonYear'] != null)
          EmbedFieldBuilder(
              name: 'Season',
              value: '${data['season']} ${data['seasonYear']}',
              isInline: true),
        if (data['averageScore'] != null)
          EmbedFieldBuilder(
              name: 'Average Score',
              value: data['averageScore'].toString(),
              isInline: true),
        EmbedFieldBuilder(
            name: 'Links',
            value:
                '[AniList](${data['siteUrl']}) ${data['idMal'] != null ? ' | [MyAnimeList](https://myanimelist.net/anime/${data['idMal']})' : ''}',
            isInline: true)
      ],
    );

    await context.respond(MessageBuilder(embeds: [embed]));
  }),
);
