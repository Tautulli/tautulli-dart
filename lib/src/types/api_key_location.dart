/// Where the API key (or device token) is placed on each request.
enum ApiKeyLocation {
  /// Send the key as the `apikey` query parameter (the default). Works on
  /// every server version, but the key appears in URLs — and therefore in
  /// server access logs, proxy logs, and browser tooling.
  query,

  /// Send the key as an `X-Api-Key` header instead, keeping it out of URLs.
  ///
  /// Requires a Tautulli server **newer than v2.17.2** — older servers only
  /// read the query parameter and reject header-only requests with
  /// "Parameter apikey is required". Enable this only when the server is
  /// known to support it.
  ///
  /// On the web, the header makes requests non-simple and triggers a CORS
  /// preflight; servers new enough to read the header also answer the
  /// preflight, so no extra caveat applies there. Image URLs from
  /// `buildImageUrl()` always embed the key as a query parameter regardless
  /// of this setting (image tags cannot send headers).
  header,
}
