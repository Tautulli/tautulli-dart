final _apiKeyPattern = RegExp(r'apikey=[^&\s]+');

/// Replaces the `apikey` query value in [message] with a placeholder.
///
/// Network exceptions often stringify the full request URI, which carries the
/// API key; redacting keeps it out of error messages and logs.
String redactApiKey(String message) =>
    message.replaceAll(_apiKeyPattern, 'apikey=<redacted>');
