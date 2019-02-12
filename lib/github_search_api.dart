import 'package:dio/dio.dart';

class GithubApi {
  final String baseUrl;
  final Dio dio;

  GithubApi({
    Dio dio,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  }) : this.dio = dio ?? new Dio();

  /// Search Github for repositories using the given term
  Future<SearchResult> search(String term, CancelToken token) async {
    if (term.isEmpty) {
      return new SearchResult.noTerm();
    } else {
      final response = await dio.get(baseUrl + term, cancelToken: token);
      return new SearchResult.fromJson(response.data['items']);
    }
  }

}

enum SearchResultKind { noTerm, empty, populated }

class SearchResult {
  final SearchResultKind kind;
  final List<SearchResultItem> items;

  SearchResult(this.kind, this.items);

  factory SearchResult.noTerm() =>
      new SearchResult(SearchResultKind.noTerm, <SearchResultItem>[]);

  factory SearchResult.fromJson(dynamic json) {
    final items = (json as List)
        .cast<Map<String, Object>>()
        .map((Map<String, Object> item) {
      return new SearchResultItem.fromJson(item);
    }).toList();

    return new SearchResult(
      items.isEmpty ? SearchResultKind.empty : SearchResultKind.populated,
      items,
    );
  }

  bool get isPopulated => kind == SearchResultKind.populated;

  bool get isEmpty => kind == SearchResultKind.empty;

  bool get isNoTerm => kind == SearchResultKind.noTerm;
}

class SearchResultItem {
  final String fullName;
  final String url;
  final String avatarUrl;

  SearchResultItem(this.fullName, this.url, this.avatarUrl);

  factory SearchResultItem.fromJson(Map<String, Object> json) {
    return new SearchResultItem(
      json['full_name'] as String,
      json["html_url"] as String,
      (json["owner"] as Map<String, Object>)["avatar_url"] as String,
    );
  }
}
