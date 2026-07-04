import '../executor.dart';
import '../models/newsletter/newsletter_config.dart';
import '../models/newsletter/newsletter_log_entry.dart';
import '../models/paged_result.dart';
import '../utils/cast.dart';

/// Commands: get_newsletters, get_newsletter_config, add_newsletter_config,
/// set_newsletter_config, delete_newsletter, get_newsletter_log,
/// delete_newsletter_log, notify_newsletter, delete_hosted_images
class NewsletterService {
  final TautulliExecutor _client;
  NewsletterService(TautulliExecutor client) : _client = client;

  /// Returns all configured newsletters.
  ///
  /// Set [includeDisabled] to `true` to also return disabled newsletters.
  Future<List<NewsletterConfig>> getNewsletters({bool? includeDisabled}) async {
    final params = <String, dynamic>{};
    if (includeDisabled != null) params['include_disabled'] = includeDisabled;
    final response = await _client.execute('get_newsletters', params: params);
    return Cast.dataList(
      response['data'],
      'get_newsletters',
    ).whereType<Map<String, dynamic>>().map(NewsletterConfig.fromJson).toList();
  }

  /// Returns the full configuration for a single newsletter.
  Future<NewsletterConfig> getNewsletterConfig({
    required int newsletterId,
  }) async {
    final response = await _client.execute(
      'get_newsletter_config',
      params: {'newsletter_id': newsletterId},
    );
    return NewsletterConfig.fromJson(
      Cast.dataMap(response['data'], 'get_newsletter_config'),
    );
  }

  /// Returns a paginated list of newsletter send log entries.
  Future<PagedResult<NewsletterLogEntry>> getNewsletterLog({
    int? newsletterId,
    String? search,
    int? start,
    int? length,
    String? orderColumn,
    String? orderDir,
  }) async {
    final params = <String, dynamic>{};
    if (newsletterId != null) params['newsletter_id'] = newsletterId;
    if (search != null) params['search'] = search;
    if (start != null) params['start'] = start;
    if (length != null) params['length'] = length;
    if (orderColumn != null) params['order_column'] = orderColumn;
    if (orderDir != null) params['order_dir'] = orderDir;

    final response = await _client.execute(
      'get_newsletter_log',
      params: params,
    );
    final data = Cast.dataMap(response['data'], 'get_newsletter_log');
    return PagedResult(
      data: Cast.dataList(data['data'], 'get_newsletter_log')
          .whereType<Map<String, dynamic>>()
          .map(NewsletterLogEntry.fromJson)
          .toList(),
      recordsTotal: Cast.castToInt(data['recordsTotal']),
      recordsFiltered: Cast.castToInt(data['recordsFiltered']),
    );
  }

  /// Adds a new newsletter configuration for the given [agentId].
  Future<void> addNewsletterConfig({required int agentId}) async {
    await _client.execute(
      'add_newsletter_config',
      params: {'agent_id': agentId},
    );
  }

  /// Updates the configuration for the newsletter identified by [newsletterId].
  ///
  /// Agent-specific settings can be passed via [extraParams].
  Future<void> setNewsletterConfig({
    required int newsletterId,
    required int agentId,
    Map<String, dynamic> extraParams = const {},
  }) async {
    final params = <String, dynamic>{
      'newsletter_id': newsletterId,
      'agent_id': agentId,
      ...extraParams,
    };
    await _client.execute('set_newsletter_config', params: params);
  }

  /// Deletes the newsletter identified by [newsletterId].
  Future<void> deleteNewsletter({required int newsletterId}) async {
    await _client.execute(
      'delete_newsletter',
      params: {'newsletter_id': newsletterId},
    );
  }

  /// Deletes all newsletter log entries.
  Future<void> deleteNewsletterLog() async {
    await _client.execute('delete_newsletter_log');
  }

  /// Sends a test newsletter immediately.
  ///
  /// [newsletterId] identifies which newsletter to send. Optional [subject],
  /// [body], and [message] override the newsletter's configured content.
  Future<void> notifyNewsletter({
    required int newsletterId,
    String? subject,
    String? body,
    String? message,
  }) async {
    final params = <String, dynamic>{'newsletter_id': newsletterId};
    if (subject != null) params['subject'] = subject;
    if (body != null) params['body'] = body;
    if (message != null) params['message'] = message;
    await _client.execute('notify_newsletter', params: params);
  }

  /// Deletes images hosted externally by a newsletter service.
  Future<void> deleteHostedImages({
    int? ratingKey,
    String? service,
    bool? deleteAll,
  }) async {
    final params = <String, dynamic>{};
    if (ratingKey != null) params['rating_key'] = ratingKey;
    if (service != null) params['service'] = service;
    if (deleteAll != null) params['delete_all'] = deleteAll;
    await _client.execute('delete_hosted_images', params: params);
  }
}
