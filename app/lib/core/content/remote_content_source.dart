import 'content_source.dart';

typedef RawContentFetcher = Future<String> Function(Uri uri);

class RemoteContentSource implements ContentSource {
  const RemoteContentSource({
    required this.uri,
    required this.fetcher,
  });

  final Uri uri;
  final RawContentFetcher fetcher;

  @override
  Future<String> loadRawContent() {
    return fetcher(uri);
  }
}
